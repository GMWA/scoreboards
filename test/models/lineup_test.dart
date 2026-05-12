import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/lineup.dart';

void main() {
  group('MatchLineup Model Tests', () {
    test('MatchLineup.fromJson parses all fields correctly', () {
      final json = {
        "id": 1,
        "match": 100,
        "minutes_played": 65,
        "is_starting": true,
        "is_captain": false,
        "points": 5,
        "team": {
          "id": 10,
          "slug": "team-a",
          "name": "Team A",
          "logo": null,
          "stadium": "Team A Stadium",
          "country": "England"
        },
        "player": {
          "id": 50,
          "slug": "john-doe",
          "firstname": "John",
          "lastname": "Doe",
          "avatar": null,
          "jersey_number": 9
        }
      };

      final lineup = MatchLineup.fromJson(json);

      expect(lineup.id, 1);
      expect(lineup.match, 100);
      expect(lineup.minutesPlayed, 65);
      expect(lineup.team.id, 10);
      expect(lineup.team.name, "Team A");
      expect(lineup.isStarting, true);
      expect(lineup.player.firstname, "John");
      expect(lineup.player.lastname, "Doe");
      expect(lineup.player.jerseyNumber, 9);
    });

    test('MatchLineup.fromJson handles null optional fields', () {
      final json = {
        "id": 2,
        "match": 101,
        "minutes_played": 80,
        "is_starting": false,
        "is_captain": true,
        "points": 7.0,
        "position": "forward",
        "team": {
          "id": 20,
          "slug": "team-b",
          "name": "Team B",
          "logo": null,
          "stadium": null,
          "country": "France"
        },
        "player": {
          "id": 60,
          "slug": "alex-brown",
          "firstname": "Alex",
          "lastname": "Brown",
          "avatar": null,
          "jersey_number": null
        },
      };
      final lineup = MatchLineup.fromJson(json);
      expect(lineup.team.logo, isNull);
      expect(lineup.isStarting, false);
      expect(lineup.position, "forward");
    });
  });
}
