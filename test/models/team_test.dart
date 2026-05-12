import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/team.dart';

void main() {
  group('Team model', () {
    test('fromJson should create a valid Team object', () {
      final json = {
        'id': 1,
        'slug': 'fc-example',
        'name': 'FC Example',
        'team_type': 'Club',
        'logo': 'example.png',
        'coach': 'John Coach',
        'stadium': {
          'id': 4,
          'slug': 'big-league',
          'name': 'Big Stadium',
          'city': 'hannover',
          'country': 'germany',
          'capacity': 15000,
          'is_opened': true,
          'opened_year': "2025"
        },
        'league': 'Premier League',
        'country': 'Cameroon',
        'confederation': 'CAF',
      };

      final team = Team.fromJson(json);

      expect(team.id, 1);
      expect(team.slug, 'fc-example');
      expect(team.name, 'FC Example');
      expect(team.teamType, 'Club');
      expect(team.logo, 'example.png');
      expect(team.coach, 'John Coach');
      expect(team.stadium!.name, 'Big Stadium');
      expect(team.league, 'Premier League');
      expect(team.country, 'Cameroon');
      expect(team.confederation, 'CAF');
    });

    test('fromJson should handle null optional fields', () {
      final json = {
        'id': 2,
        'slug': 'no-logo-fc',
        'name': 'No Logo FC',
        'team_type': 'National Team',
        'coach': 'Coach X',
      };

      final team = Team.fromJson(json);

      expect(team.id, 2);
      expect(team.name, 'No Logo FC');
      expect(team.teamType, 'National Team');
      expect(team.logo, null);
      expect(team.stadium, null);
      expect(team.league, null);
      expect(team.country, null);
      expect(team.confederation, null);
    });
  });

  group('PlayerTeam model', () {
    test('fromJson should create valid PlayerTeam object', () {
      final json = {
        'id': 10,
        'slug': 'alex-walker',
        'firstname': 'Alex',
        'lastname': 'Walker',
        'jersey_number': 9,
        'logo': 'player_logo.png',
      };

      final playerTeam = PlayerTeam.fromJson(json);

      expect(playerTeam.id, 10);
      expect(playerTeam.firstname, 'Alex');
      expect(playerTeam.lastname, 'Walker');
      expect(playerTeam.jerseyNumber, 9);
      expect(playerTeam.logo, 'player_logo.png');
    });

    test('fromJson should fall back to team_logo when logo is null', () {
      final json = {
        'id': 11,
        'slug': 'mike-johnson',
        'firstname': 'Mike',
        'lastname': 'Johnson',
        'jersey_number': 7,
        'logo': null,
        'team_logo': 'fallback_logo.png',
      };

      final playerTeam = PlayerTeam.fromJson(json);

      expect(playerTeam.logo, 'fallback_logo.png');
    });
  });

  group('TeamLookup model', () {
    test('fromJson should create valid TeamLookup object', () {
      final json = {
        'id': 5,
        'slug': 'simple-team',
        'name': 'Simple Team',
        'logo': 'simple.png',
      };

      final lookup = TeamLookup.fromJson(json);

      expect(lookup.id, 5);
      expect(lookup.name, 'Simple Team');
      expect(lookup.logo, 'simple.png');
    });

    test('fromJson should handle missing name by using empty string', () {
      final json = {
        'id': 6,
        'slug': 'no-name',
        'logo': 'no_name.png',
      };

      final lookup = TeamLookup.fromJson(json);

      expect(lookup.id, 6);
      expect(lookup.name, '');
      expect(lookup.logo, 'no_name.png');
    });
  });
}
