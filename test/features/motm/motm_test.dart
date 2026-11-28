import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/core/api/api_exception.dart';
import 'package:scoreboards/features/motm/motm_controller.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/harness.dart';
import '../../helpers/motm_fixture.dart';

void main() {
  const path = '/api/v1/matchs/7/player-of-the-match/';
  late List<String> calls;

  setUp(() => calls = []);

  /// The backend: summaries, votes and retractions, or [refuse] them.
  FakeHandler backend({int? refuse}) => (o) async {
        expect(o.uri.path, path);
        calls.add(
            '${o.method} ${o.queryParameters['device_id'] ?? sentJson(o)}');
        if (refuse != null && o.method != 'GET') {
          return jsonBody(refuse, {'detail': 'Voting has closed.'});
        }
        final voted = o.method == 'POST';
        return jsonBody(
            o.method == 'POST' ? 201 : 200,
            motmSummaryJson(
              yourVote: voted
                  ? {
                      'player': motmSummaryJson()['candidates'][0]['player'],
                      'updated_at': '2026-10-04T13:00:00Z',
                    }
                  : null,
            ));
      };

  test("the summary is this device's", () async {
    final container =
        await testContainer(api: backend(), prefs: {'device_id': 'device-1'});

    final summary = await container.read(motmProvider(7).future);

    expect(summary.candidates.single.player.lastname, 'Doe');
    expect(summary.totalVotes, 3);
    expect(calls, ['GET device-1']);
  });

  test('a vote, then the same tap again takes it back', () async {
    final container =
        await testContainer(api: backend(), prefs: {'device_id': 'device-1'});
    // The voting tab keeps the provider alive while it shows.
    container.listen(motmProvider(7), (_, __) {});
    final summary = await container.read(motmProvider(7).future);
    final candidate = summary.candidates.single;
    final controller = container.read(motmProvider(7).notifier);

    await controller.toggleVote(candidate);
    expect(container.read(motmProvider(7)).value!.yourVote?.player.id, 50);

    await controller.toggleVote(candidate);
    expect(container.read(motmProvider(7)).value!.yourVote, isNull);

    expect(calls, [
      'GET device-1',
      'POST {device_id: device-1, player_id: 50}',
      'DELETE {device_id: device-1}',
    ]);
  });

  test('a refused vote says why and changes nothing', () async {
    final container = await testContainer(
        api: backend(refuse: 409), prefs: {'device_id': 'device-1'});
    container.listen(motmProvider(7), (_, __) {});
    final summary = await container.read(motmProvider(7).future);
    final controller = container.read(motmProvider(7).notifier);

    await expectLater(
      controller.toggleVote(summary.candidates.single),
      throwsA(isA<ApiException>()
          .having((e) => e.message, 'message', 'Voting has closed.')),
    );
    expect(container.read(motmProvider(7)).value, same(summary));
  });
}
