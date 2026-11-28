import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/features/competitions/competitions_repository.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fixtures.dart';

void main() {
  test('activeEditions reads the editions', () async {
    final (:dio, :api) =
        fakeDio((_) async => jsonBody(200, [editionJson(label: 'Elite One')]));

    final editions = await CompetitionsRepository(dio).activeEditions();

    expect(editions.single.label, 'Elite One');
    expect(api.requests.single.path, '/championships/editions/');
  });

  test('editionBySlug reads one edition', () async {
    final (:dio, :api) = fakeDio((_) async => jsonBody(200, editionJson()));

    expect((await CompetitionsRepository(dio).editionBySlug('cup-2026')).id, 1);
    expect(api.requests.single.path, '/championships/editions/slug/cup-2026/');
  });

  test('standings come in table order', () async {
    final (:dio, :api) = fakeDio((_) async => jsonBody(200, [
          standingJson(1, 'Third', points: 10),
          standingJson(2, 'Second', points: 12, goalsFor: 1),
          standingJson(3, 'First', points: 12, goalsFor: 5),
        ]));

    final standings = await CompetitionsRepository(dio).standings(9);

    expect(standings.map((s) => s.participation.team.name),
        ['First', 'Second', 'Third']);
    expect(api.requests.single.path, '/edition/9/standings/');
  });

  test('standingRules reads the rules', () async {
    final (:dio, :api) = fakeDio((_) async => jsonBody(200, []));

    expect(await CompetitionsRepository(dio).standingRules(9), isEmpty);
    expect(api.requests.single.path, '/edition/9/rules/');
  });
}
