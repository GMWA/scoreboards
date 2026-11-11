import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoreboards/services/device_service.dart';
import 'package:scoreboards/services/notification_service.dart';

/// What PushService needs from Firebase Cloud Messaging; tests replace it.
abstract class PushMessaging {
  /// Asks the user (Android 13+, iOS); true when notifications may be shown.
  Future<bool> requestPermission();

  /// Whether notifications may be shown, without asking.
  Future<bool> hasPermission();

  /// This install's FCM token; null when the phone can't receive pushes
  /// (no Google Play services).
  Future<String?> getToken();

  Stream<String> get onTokenRefresh;
}

class FirebasePushMessaging implements PushMessaging {
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  static bool _allowed(NotificationSettings settings) =>
      settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;

  @override
  Future<bool> requestPermission() async =>
      _allowed(await _fcm.requestPermission());

  @override
  Future<bool> hasPermission() async =>
      _allowed(await _fcm.getNotificationSettings());

  // The backend sends to FCM registration tokens (firebase-admin's
  // send_each_for_multicast). register()/onRegistered, which replace these,
  // give a Firebase Installation ID for FCM's newer direct send instead,
  // which the backend doesn't use: keep these until it does.
  @override
  // ignore: deprecated_member_use
  Future<String?> getToken() => _fcm.getToken();

  @override
  // ignore: deprecated_member_use
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;
}

/// The Firebase project's client settings, from the .env file; null when
/// they aren't set (push notifications are then off). Only Android is set
/// up so far: iOS also needs an APNs key and the push capability.
FirebaseOptions? firebaseOptionsFromEnv() {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
  String value(String key) => dotenv.get(key, fallback: '').trim();

  final apiKey = value('FIREBASE_API_KEY');
  final appId = value('FIREBASE_ANDROID_APP_ID');
  final senderId = value('FIREBASE_MESSAGING_SENDER_ID');
  final projectId = value('FIREBASE_PROJECT_ID');
  if ([apiKey, appId, senderId, projectId].any((v) => v.isEmpty)) return null;

  return FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: senderId,
    projectId: projectId,
  );
}

/// The screen a notification opens, from the data the backend sends with
/// it ({type, match_id, match_slug}); null keeps the current screen.
String? routeForPushData(Map<String, dynamic> data) {
  final slug = data['match_slug'];
  if (slug is String && slug.isNotEmpty) return '/matchs/details/$slug';
  return null;
}

/// Push notifications from the backend (kick-off reminders, goals,
/// results) for the teams and competitions the user follows.
///
/// The backend sends to the token stored on this device, so turning
/// notifications on or off is a matter of giving it the token or null.
/// What the backend has is remembered, and [syncToken] runs at every
/// launch, so a change made offline reaches it later.
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  /// The user's choice: true, false, or missing when never asked.
  static const enabledKey = 'notif_master';
  // The token the backend has for this device; '' when it has none.
  static const _sentTokenKey = 'push_token_sent';

  PushMessaging? _messaging;
  StreamSubscription<String>? _tokenRefresh;
  Future<void> _syncChain = Future.value();
  Future<void>? _queuedSync;

  /// Where to go once the app is shown, if a notification launched it.
  String? _pendingRoute;

  /// False when Firebase isn't configured or couldn't start: the app then
  /// hides the notification setting.
  bool get isAvailable => _messaging != null;

  /// Sets up Firebase and the handlers. [openRoute] shows a screen, for a
  /// notification tapped while the app runs. Never throws.
  Future<void> init({required ValueChanged<String> openRoute}) async {
    final options = firebaseOptionsFromEnv();
    if (options == null) return;
    try {
      await Firebase.initializeApp(options: options);

      FirebaseMessaging.onMessage.listen(_showInForeground);
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final route = routeForPushData(message.data);
        if (route != null) openRoute(route);
      });
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _pendingRoute = routeForPushData(initial.data);

      await attach(FirebasePushMessaging());
    } catch (e) {
      debugPrint('Push notifications unavailable: $e');
    }
  }

  @visibleForTesting
  Future<void> attach(PushMessaging messaging) async {
    _messaging = messaging;
    _tokenRefresh = messaging.onTokenRefresh.listen((_) => syncToken());
    unawaited(syncToken());
  }

  @visibleForTesting
  Future<void> resetForTesting() async {
    await _tokenRefresh?.cancel();
    _tokenRefresh = null;
    _messaging = null;
    _syncChain = Future.value();
    _queuedSync = null;
    _pendingRoute = null;
  }

  /// The route a notification tap launched the app with; returned once.
  String? takePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  /// Whether notifications are on: the user turned them on and the phone
  /// still allows them (they can be blocked in the phone's settings).
  Future<bool> isEnabled() async {
    final messaging = _messaging;
    if (messaging == null) return false;
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getBool(enabledKey) ?? false) &&
        await messaging.hasPermission();
  }

  /// Turns notifications on or off. Turning them on asks for permission;
  /// returns false (and stays off) if it isn't given.
  Future<bool> setEnabled(bool enabled) async {
    final messaging = _messaging;
    if (messaging == null) return false;
    final prefs = await SharedPreferences.getInstance();

    if (enabled && !await messaging.requestPermission()) {
      await prefs.setBool(enabledKey, false);
      unawaited(syncToken());
      return false;
    }
    await prefs.setBool(enabledKey, enabled);
    unawaited(syncToken());
    return enabled;
  }

  /// After the user follows something: if they were never asked about
  /// notifications, asks now, since that's what following is for. Returns
  /// whether notifications were just turned on.
  Future<bool> offerAfterFollow() async {
    if (_messaging == null) return false;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(enabledKey) != null) return false;
    return setEnabled(true);
  }

  /// Gives the backend this install's token when notifications are on, or
  /// null when they're off, unless it already has that. Runs one at a
  /// time; calls made meanwhile queue one more run, which reads the state
  /// when it starts. A failure (offline) is retried at the next launch.
  /// Never throws.
  Future<void> syncToken() {
    return _queuedSync ??= _syncChain = _syncChain.then((_) {
      _queuedSync = null;
      return _syncTokenOnce();
    });
  }

  Future<void> _syncTokenOnce() async {
    final messaging = _messaging;
    if (messaging == null) return;
    final prefs = await SharedPreferences.getInstance();

    String? token;
    if (prefs.getBool(enabledKey) ?? false) {
      try {
        token = await messaging.getToken();
      } catch (e) {
        debugPrint('Could not get the push token: $e');
        return;
      }
    }

    if ((token ?? '') == (prefs.getString(_sentTokenKey) ?? '')) return;
    if (await DeviceService().update({'push_token': token})) {
      await prefs.setString(_sentTokenKey, token ?? '');
    }
  }

  /// Android doesn't show a push that arrives while the app is open.
  Future<void> _showInForeground(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    final matchId = message.data['match_id'];
    await LocalNotificationService.show(
      title: notification.title ?? '',
      body: notification.body ?? '',
      payload: routeForPushData(message.data),
      tag: matchId != null ? 'match-$matchId' : null,
    );
  }
}
