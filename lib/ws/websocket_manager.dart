import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:scoreboards/services/notification_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class WebSocketManager {
  WebSocketChannel? _channel;

  void connect(String url, {ServiceInstance? service}) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      print("WS Connected: $url");

      _channel!.stream.listen(
        (event) async {
          print("WS Message: $event");
          _handleMessage(event, service);
        },
        onError: (err) {
          print("WS Error: $err");
          _reconnect(url, service);
        },
        onDone: () {
          print("WS Closed");
          _reconnect(url, service);
        },
      );
    } catch (e) {
      print("WS Connection Exception: $e");
      _reconnect(url, service);
    }
  }

  void _handleMessage(dynamic event, ServiceInstance? service) async {
    try {
      final data = jsonDecode(event);
      final title = data["title"] ?? "Scoreboards";
      final body = data["body"] ?? data["message"] ?? "";

      await LocalNotificationService.show(
        title: title,
        body: body,
      );

      if (service != null) {
        service.invoke("notification", {"payload": event});
      } else {
        print("Linux UI Update: $event");
      }
    } catch (e) {
      print("Error parsing message: $e");
    }
  }

  void _reconnect(String url, ServiceInstance? service) async {
    await Future.delayed(const Duration(seconds: 3));
    connect(url, service: service);
  }
}
