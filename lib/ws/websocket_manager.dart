import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:scoreboards/services/notification_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';


final logger = Logger();

/// Keeps one notification websocket open, reconnecting with exponential
/// backoff when it drops.
class WebSocketManager {
  static const Duration initialRetryDelay = Duration(seconds: 2);
  static const Duration maxRetryDelay = Duration(minutes: 1);

  WebSocketManager({
    @visibleForTesting WebSocketChannel Function(Uri uri)? connector,
  }) : _connector = connector ?? WebSocketChannel.connect;

  final WebSocketChannel Function(Uri uri) _connector;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  Duration _retryDelay = initialRetryDelay;
  bool _closed = false;

  void connect(String url, {ServiceInstance? service}) {
    _closed = false;
    _open(url, service);
  }

  /// Closes the socket and stops reconnecting.
  void close() {
    _closed = true;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
  }

  void _open(String url, ServiceInstance? service) {
    // Drop the previous socket's listeners so its late events can't
    // schedule a second reconnect.
    _subscription?.cancel();
    _channel?.sink.close();

    try {
      final channel = _connector(Uri.parse(url));
      _channel = channel;
      logger.i("WS Connecting: $url");

      channel.ready.then<void>(
        (_) {
          _retryDelay = initialRetryDelay;
        },
        onError: (Object _) {}, // reported through the stream below
      );

      _subscription = channel.stream.listen(
        (event) => _handleMessage(event, service),
        // A failure usually produces an error and then a close; both funnel
        // into the same guarded reconnect, so only one is scheduled.
        onError: (err) {
          logger.i("WS Error: $err");
          _scheduleReconnect(url, service);
        },
        onDone: () {
          logger.i("WS Closed");
          _scheduleReconnect(url, service);
        },
      );
    } catch (e) {
      logger.i("WS Connection Exception: $e");
      _scheduleReconnect(url, service);
    }
  }

  void _scheduleReconnect(String url, ServiceInstance? service) {
    if (_closed || (_reconnectTimer?.isActive ?? false)) return;

    final delay = _retryDelay;
    final doubled = _retryDelay * 2;
    _retryDelay = doubled > maxRetryDelay ? maxRetryDelay : doubled;
    _reconnectTimer = Timer(delay, () => _open(url, service));
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
        logger.i("Linux UI Update: $event");
      }
    } catch (e) {
      logger.i("Error parsing message: $e");
    }
  }
}
