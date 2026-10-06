import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // Seeded from the clock so IDs don't collide with notifications still
  // shown from a previous run; incremented so two in the same second don't
  // replace each other. Seconds since epoch fit Android's 32-bit IDs.
  static int _nextId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open Notification',
      // defaultIcon: AssetsLinuxIcon('assets/icons/app_icon.png'),
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(settings);
    _isInitialized = true;
  }

  static Future<void> show({
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'scoreboards_channel',
      'Scoreboards Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const linuxDetails = LinuxNotificationDetails(
       urgency: LinuxNotificationUrgency.critical,
    );

    const platform = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      linux: linuxDetails,
    );

    await _plugin.show(
      _nextId++,
      title,
      body,
      platform,
    );
  }
}