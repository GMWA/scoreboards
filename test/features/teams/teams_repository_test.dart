import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/core/api/api_exception.dart';
import 'package:scoreboards/features/teams/teams_repository.dart';
import 'package:scoreboards/features/teams/teams_providers.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fixtures.dart';

void main() {
  test('all walks every page of teams', () async {
    final (:dio, :api) = fakeDio((o) async {
      final page = o.queryParameters['page'] as int;
      return jsonBody(200, {
        'next': page == 1 ? 'next' : null,
        'results': [teamJson(page, 'T$page')],
      });
    });

    final teams = await TeamsRepository(dio).all();

    expect(teams.map((t) => t.name), ['T1', 'T2']);
    expect(api.requests.first.path, '/teams/');
  });

  test('all fails when the backend does', () async {
    final (:dio, api: _) = fakeDio((_) async => jsonBody(500, {}));

    expect(TeamsRepository(dio).all(), throwsA(isA<ApiException>()));
  });

  test('bySlug and byEdition use their endpoints', () async {
    final (:dio, :api) = fakeDio((o) async => o.path.startsWith('/teams/slug/')
        ? jsonBody(200, teamJson(1, 'Lions'))
        : jsonBody(200, [teamJson(2, 'Eagles')]));
    final repo = TeamsRepository(dio);

    expect((await repo.bySlug('lions')).name, 'Lions');
    expect((await repo.byEdition(4)).single.name, 'Eagles');
    expect(api.requests.map((r) => r.path),
        ['/teams/slug/lions/', '/edition/4/teams/']);
  });

  test('teamsMatching finds a name part, ignoring case', () async {
    final (:dio, api: _) = fakeDio((_) async => jsonBody(200, [
          teamJson(1, 'Canon Yaounde'),
          teamJson(2, 'Cotonsport'),
        ]));
    final teams = await TeamsRepository(dio).byEdition(1);

    expect(teamsMatching(teams, 'YAOU').map((t) => t.name), ['Canon Yaounde']);
    expect(teamsMatching(teams, ''), hasLength(2));
  });
}
