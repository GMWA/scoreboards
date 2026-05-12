import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/standing.dart';

void main() {
  group('Participation model', () {
    test('fromJson should create a valid Participation object', () {
      final json = {
        'id': 101,
        'team': {
          'id': 1,
          'slug': 'fc-example',
          'name': 'FC Example',
          'logo': 'example.png',
        },
        'group': 'A',
      };

      final participation = Participation.fromJson(json);

      expect(participation.id, 101);
      expect(participation.group, 'A');

      // Nested TeamLookup
      expect(participation.team.id, 1);
      expect(participation.team.name, 'FC Example');
      expect(participation.team.logo, 'example.png');
    });

    test('fromJson should handle null group', () {
      final json = {
        'id': 102,
        'team': {
          'id': 2,
          'slug': 'team-no-group',
          'name': 'Team NoGroup',
          'logo': null,
        },
        'group': null,
      };

      final participation = Participation.fromJson(json);

      expect(participation.id, 102);
      expect(participation.group, null);
      expect(participation.team.logo, null);
    });
  });

  group('Standing model', () {
    test('fromJson should create a valid Standing object', () {
      final json = {
        'id': 200,
        'participation': {
          'id': 101,
          'team': {
            'id': 10,
            'slug': 'standing-fc',
            'name': 'Standing FC',
            'logo': 'standing.png'
          },
          'group': 'B',
        },
        'points': 25,
        'matches_played': 10,
        'wins': 8,
        'draws': 1,
        'losses': 1,
        'goals_for': 18,
        'goals_against': 6,
      };

      final standing = Standing.fromJson(json);

      expect(standing.id, 200);
      expect(standing.points, 25);
      expect(standing.played, 10);
      expect(standing.wins, 8);
      expect(standing.drawn, 1);
      expect(standing.losses, 1);
      expect(standing.goalsFor, 18);
      expect(standing.goalsAgainst, 6);

      expect(standing.goalsDifference, 18 - 6);

      final participation = standing.participation;
      expect(participation.id, 101);
      expect(participation.group, 'B');

      expect(participation.team.id, 10);
      expect(participation.team.name, 'Standing FC');
      expect(participation.team.logo, 'standing.png');
    });

    test('fromJson should handle negative goal difference correctly', () {
      final json = {
        'id': 201,
        'participation': {
          'id': 102,
          'team': {
            'id': 20,
            'slug': 'losing-team',
            'name': 'Losing Team',
            'logo': null,
          },
          'group': null,
        },
        'points': 5,
        'matches_played': 7,
        'wins': 1,
        'draws': 2,
        'losses': 4,
        'goals_for': 5,
        'goals_against': 10,
      };

      final standing = Standing.fromJson(json);

      expect(standing.goalsDifference, 5 - 10);
      expect(standing.goalsDifference, -5);
    });
  });
}
