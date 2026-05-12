import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/subtitution.dart';

void main() {
  group('Substitution Model Tests', () {
    test('Substitution.fromJson parses all fields correctly', () {
      final json = {
        "id": 1,
        "match": 100,
        "minute": 65,
        "stoppage_minute": 2,
        "reason": "Tactical",
        "team": {
          "id": 10,
          "slug": "team-a",
          "name": "Team A",
          "logo": null,
          "stadium": {
            'id': 4,
            'slug': 'big-league',
            'name': 'Big Stadium',
            'city': 'hannover',
            'country': 'germany',
            'capacity': 15000,
            'is_opened': true,
            'opened_year': 2025
          },
          "country": "England"
        },
        "player_in": {
          "id": 50,
          "slug": "john-doe",
          "firstname": "John",
          "lastname": "Doe",
          "avatar": null,
          "jersey_number": 9
        },
        "player_out": {
          "id": 51,
          "slug": "mike-smith",
          "firstname": "Mike",
          "lastname": "Smith",
          "avatar": null,
          "jersey_number": 7
        }
      };

      final substitution = Substitution.fromJson(json);

      expect(substitution.id, 1);
      expect(substitution.match, 100);
      expect(substitution.minute, 65);
      expect(substitution.stoppageMinute, 2);
      expect(substitution.reason, "Tactical");
      expect(substitution.team.id, 10);
      expect(substitution.team.name, "Team A");
      expect(substitution.playerIn.firstname, "John");
      expect(substitution.playerIn.lastname, "Doe");
      expect(substitution.playerIn.jerseyNumber, 9);
      expect(substitution.playerOut.firstname, "Mike");
      expect(substitution.playerOut.lastname, "Smith");
      expect(substitution.playerOut.jerseyNumber, 7);
    });

    test('Substitution.fromJson handles null optional fields', () {
      final json = {
        "id": 2,
        "match": 101,
        "minute": 80,
        "stoppage_minute": null,
        "reason": null,
        "team": {
          "id": 20,
          "slug": "team-b",
          "name": "Team B",
          "logo": null,
          "stadium": null,
          "country": "France"
        },
        "player_in": {
          "id": 60,
          "slug": "alex-brown",
          "firstname": "Alex",
          "lastname": "Brown",
          "avatar": null,
          "jersey_number": null
        },
        "player_out": {
          "id": 61,
          "slug": "tom-white",
          "firstname": "Tom",
          "lastname": "White",
          "avatar": null,
          "jersey_number": null
        }
      };
      final substitution = Substitution.fromJson(json);
      expect(substitution.stoppageMinute, isNull);
      expect(substitution.reason, isNull);
    });
  });
}
