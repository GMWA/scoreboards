import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Shows notifications from inside the app: Android doesn't display a push
/// that arrives while the app is open, so PushService shows it here.
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// The Android channel for match notifications. The manifest makes it
  /// the default for pushes shown while the app is closed, so both kinds
  /// share one entry in the phone's notification settings.
  static const channelId = 'match_notifications';
  static const _channelName = 'Match notifications';

  // Created at low importance by the removed background service. An app
  // can't raise a channel's importance once it exists, so match
  // notifications use a new channel and this one is deleted.
  static const _oldChannelId = 'scoreboards_channel';

  static bool _isInitialized = false;

  // Seeded from the clock so IDs don't collide with notifications still
  // shown from a previous run; incremented so two in the same second don't
  // replace each other. Seconds since epoch fit Android's 32-bit IDs.
  static int _nextId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// [onTap] gets the payload of a notification shown by [show] when the
  /// user taps it while the app is running.
  static Future<void> initialize({ValueChanged<String>? onTap}) async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');

    // Don't prompt at launch: permission is asked for only when the user
    // turns notifications on (see PushService).
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open Notification',
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) onTap?.call(payload);
      },
    );

    // Created up front, so a push arriving before the app ever showed a
    // notification itself lands in this channel, not "Miscellaneous".
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(const AndroidNotificationChannel(
      channelId,
      _channelName,
      importance: Importance.max,
    ));
    await android?.deleteNotificationChannel(_oldChannelId);
    _isInitialized = true;
  }

  /// The payload of the notification [show]ed earlier whose tap launched
  /// the app, if any.
  static Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return details.notificationResponse?.payload;
  }

  /// Notifications with the same [tag] replace each other, like pushes
  /// with the same group (one match's notifications).
  static Future<void> show({
    required String title,
    required String body,
    String? payload,
    String? tag,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _channelName,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      tag: tag,
    );

    final iosDetails = DarwinNotificationDetails(threadIdentifier: tag);

    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.critical,
    );

    final platform = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      linux: linuxDetails,
    );

    await _plugin.show(
      // Android replaces a notification with the same tag *and* id.
      tag != null ? tag.hashCode & 0x7fffffff : _nextId++,
      title,
      body,
      platform,
      payload: payload,
    );
  }
}
