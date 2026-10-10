import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/ws/websocket_manager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class _FakeSink implements WebSocketSink {
  @override
  Future close([int? closeCode, String? closeReason]) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// A socket that never connects: each attempt reports an error and then
/// closes, the way a refused connection does.
class _FailingChannel implements WebSocketChannel {
  final _controller = StreamController<dynamic>();

  _FailingChannel() {
    scheduleMicrotask(() {
      _controller.addError(Exception('connection refused'));
      _controller.close();
    });
  }

  @override
  Stream get stream => _controller.stream;

  @override
  WebSocketSink get sink => _FakeSink();

  @override
  Future<void> get ready => Future.error(Exception('connection refused'));

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  testWidgets('an error followed by a close reconnects once, with backoff',
      (tester) async {
    final attempts = <Duration>[];
    var elapsed = Duration.zero;

    final manager = WebSocketManager(connector: (_) {
      attempts.add(elapsed);
      return _FailingChannel();
    });

    manager.connect('wss://example.com/ws/');
    // Advance simulated time in 1s steps across several retry cycles.
    // Advance first so an attempt made during a pump is stamped with the
    // end of that second.
    for (var i = 0; i < 20; i++) {
      elapsed += const Duration(seconds: 1);
      await tester.pump(const Duration(seconds: 1));
    }
    manager.close();

    // Without the guard, each failure scheduled two reconnects, so attempts
    // doubled every cycle. With it: initial connect, then retries after
    // 2s, 4s and 8s (at t=2, 6, 14), and the next would be at t=30.
    expect(attempts.map((d) => d.inSeconds), [0, 2, 6, 14]);
  });

  testWidgets('close() stops further reconnects', (tester) async {
    var attempts = 0;
    final manager = WebSocketManager(connector: (_) {
      attempts++;
      return _FailingChannel();
    });

    manager.connect('wss://example.com/ws/');
    await tester.pump();
    manager.close();
    await tester.pump(const Duration(minutes: 5));

    expect(attempts, 1);
  });
}
