import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:scoreboards/services/device_service.dart';
import 'package:scoreboards/ws/websocket_manager.dart';
import 'package:scoreboards/services/notification_service.dart';

WebSocketChannel? _channel;

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
    return; 
  }

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'scoreboards_channel',
      initialNotificationTitle: 'Scoreboards',
      initialNotificationContent: 'Realtime notifications active',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final deviceId = await DeviceService().getOrRegisterDevice();
  final wsUrl = urls['NOTIFICATIONS']['WEBSOCKET']
          .replaceAll('#deviceId', deviceId.toString());

  WebSocketManager().connect(wsUrl, service: service);
}

void _connectWebSocket(String url, ServiceInstance service) {
  try {
    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel!.stream.listen(
      (event) async {
        try {
          final data = jsonDecode(event);
          final title = data["title"] ?? "Scoreboards";
          final body = data["body"] ?? data["message"] ?? "";

          await LocalNotificationService.show(
            title: title,
            body: body,
          );

          service.invoke("notification", {"payload": event});
        } catch (e) {
          print("Error processing WS message: $e");
        }
      },
      onError: (err) {
        print("WS ERROR (BG): $err");
        _reconnect(url, service);
      },
      onDone: () {
        print("WS CLOSED... reconnecting");
        _reconnect(url, service);
      },
    );
  } catch (e) {
    print("WS Connection Error: $e");
    _reconnect(url, service);
  }
}

void _reconnect(String url, ServiceInstance service) async {
  await Future.delayed(const Duration(seconds: 3));
  _connectWebSocket(url, service);
}