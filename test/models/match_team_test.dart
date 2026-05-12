import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/match_team.dart';

void main() {
  group('MatchTeam', () {
    test('fromJson creates correct model', () {
      final json = {
        'id': 5,
        'slug': 'fc-barcelona',
        'name': 'FC Barcelona',
        'logo': 'barca.png',
        'stadium': 'Camp Nou',
        'country': 'Spain',
      };

      final team = MatchTeam.fromJson(json);

      expect(team.id, 5);
      expect(team.slug, 'fc-barcelona');
      expect(team.name, 'FC Barcelona');
      expect(team.logo, 'barca.png');
      expect(team.stadium, 'Camp Nou');
      expect(team.country, 'Spain');
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 10,
        'slug': 'chelsea',
        'name': 'Chelsea',
        'logo': null,
        'stadium': null,
        'country': null,
      };

      final team = MatchTeam.fromJson(json);

      expect(team.id, 10);
      expect(team.slug, 'chelsea');
      expect(team.name, 'Chelsea');
      expect(team.logo, null);
      expect(team.stadium, null);
      expect(team.country, null);
    });
  });
}
