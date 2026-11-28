import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/core/api/api_exception.dart';
import 'package:scoreboards/features/match/match_repository.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fixtures.dart';

void main() {
  group('byDay', () {
    test('asks for the day in ISO format and reads the matches', () async {
      final day = DateTime(2026, 11, 19);
      final (:dio, :api) = fakeDio((_) async => jsonBody(200, [
            matchJson(1, kickoff: DateTime(2026, 11, 19, 15)),
          ]));

      final matches = await MatchRepository(dio).byDay(day);

      expect(matches.single.id, 1);
      // The day's UTC days, as YYYY-MM-DD (the legacy DD-MM-YYYY is
      // deprecated on the backend).
      expect(api.requests.map((r) => r.path).toSet(), {'/matchs/day/'});
      expect(api.requests.map((r) => r.queryParameters['date']),
          contains('2026-11-19'));
    });

    test('keeps only the local calendar day, once each, by kickoff', () async {
      final day = DateTime(2026, 11, 19);
      final (:dio, api: _) = fakeDio((_) async => jsonBody(200, [
            matchJson(3, kickoff: DateTime(2026, 11, 19, 20)),
            matchJson(1, kickoff: DateTime(2026, 11, 18, 20)),
            matchJson(2, kickoff: DateTime(2026, 11, 19, 9)),
          ]));

      final matches = await MatchRepository(dio).byDay(day);

      expect(matches.map((m) => m.id), [2, 3]);
    });

    test('fails when the backend does', () async {
      final (:dio, api: _) = fakeDio((_) async => jsonBody(500, {}));

      expect(MatchRepository(dio).byDay(DateTime(2026)),
          throwsA(isA<ApiException>()));
    });
  });

  test('live reads the live matches', () async {
    final (:dio, :api) = fakeDio((_) async => jsonBody(200, [
          matchJson(5, status: 'ongoing'),
        ]));

    expect((await MatchRepository(dio).live()).single.id, 5);
    expect(api.requests.single.path, '/matchs/live/');
  });

  test('bySlug reads one match', () async {
    final (:dio, :api) = fakeDio((_) async => jsonBody(200, matchJson(7)));

    final match = await MatchRepository(dio).bySlug('match-7');

    expect(match.id, 7);
    expect(match.homeTeam.name, 'Home FC');
    expect(api.requests.single.path, '/matchs/slug/match-7/');
  });

  group('byEditionPage', () {
    test('asks for a small page and says if more follow', () async {
      final (:dio, :api) = fakeDio((_) async => jsonBody(200, {
            'next': 'https://x/?page=2',
            'results': [matchJson(1)],
          }));

      final page = await MatchRepository(dio).byEditionPage(4);

      expect(page.items.single.id, 1);
      expect(page.nextPage, 2);
      expect(api.requests.single.path, '/matchs/edition/4/');
      expect(api.requests.single.queryParameters, {'page_size': 20, 'page': 1});
    });

    test('asks for the page it is given', () async {
      final (:dio, :api) =
          fakeDio((_) async => jsonBody(200, {'next': null, 'results': []}));

      final page = await MatchRepository(dio).byEditionPage(4, page: 3);

      expect(page.nextPage, isNull);
      expect(api.requests.single.queryParameters['page'], 3);
    });
  });
}
