import 'dart:convert';
import 'package:scoreboards/constants/urls.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:scoreboards/services/device_service.dart';

class NotificationWebSocket {
  WebSocketChannel? _channel;
  Function(Map<String, dynamic> message)? onMessage;

  Future<void> connect() async {
    final deviceId = await DeviceService().getOrRegisterDevice();
    final url = urls['NOTIFICATIONS']['WEBSOCKET']
          .replaceAll('#deviceId', deviceId.toString());

    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel!.stream.listen(
      (event) {
        try {
          final data = jsonDecode(event);
          if (onMessage != null) onMessage!(data);
        } catch (e) {
          print("Invalid WS message: $event");
        }
      },
      onDone: () {
        print("WebSocket closed. Reconnecting...");
        reconnect();
      },
      onError: (err) {
        print("WebSocket error: $err");
        reconnect();
      },
    );
  }

  void reconnect() async {
    await Future.delayed(Duration(seconds: 2));
    connect();
  }

  void send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void close() {
    _channel?.sink.close();
  }
}
