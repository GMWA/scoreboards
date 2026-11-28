import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/features/players/players_repository.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fixtures.dart';

void main() {
  test('each read uses its endpoint', () async {
    final (:dio, :api) = fakeDio((o) async => switch (o.path) {
          '/players/slug/p1/' => jsonBody(200, playerJson(1, 'Mbougain')),
          '/players/1/teams-history/' => jsonBody(200, [
              {'team': teamJson(3, 'Club'), 'start_date': '2022-01-01'},
            ]),
          _ => jsonBody(200, [playerStatsJson(1, 'Mbougain', goals: 6)]),
        });
    final repo = PlayersRepository(dio);

    expect((await repo.bySlug('p1')).lastname, 'Mbougain');
    expect((await repo.teamsHistory(1)).single.team.name, 'Club');
    expect((await repo.statsByEdition(2)).single.goals, 6);
    expect((await repo.statsByTeam(3)).single.goals, 6);
    expect(api.requests.map((r) => r.path).skip(2),
        ['/players/stats/edition/2/', '/players/stats/team/3/']);
  });
}
