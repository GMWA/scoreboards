import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/card.dart';

void main() {
  group('Card', () {
    test('fromJson creates correct model with player and reason', () {
      final json = {
        'id': 1,
        'card_type': 'Yellow',
        'minute': 35,
        'stoppage_minute': 2,
        'player': {
          'id': 10,
          'slug': 'lionel-messi',
          'firstname': 'Lionel',
          'lastname': 'Messi',
          'avatar': 'messi.png',
          'jersey_number': 10,
        },
        'team': {
          'id': 5,
          'slug': 'team-b',
          'name': 'Team B'
        },
        'reason': 'Foul',
        'is_second_yellow': false,
      };

      final card = Card.fromJson(json);

      expect(card.id, 1);
      expect(card.cardType, 'Yellow');
      expect(card.minute, 35);
      expect(card.stoppageMinute, 2);
      expect(card.team.id, 5);
      expect(card.isSecondYellow, false);
      expect(card.reason, 'Foul');

      expect(card.player?.firstname, 'Lionel');
      expect(card.player?.lastname, 'Messi');
      expect(card.player?.jerseyNumber, 10);
    });

    test('fromJson handles null player and reason', () {
      final json = {
        'id': 2,
        'card_type': 'Red',
        'minute': 75,
        'stoppage_minute': 0,
        'player': null,
        'team': {
          'id': 3,
          'slug': 'team-a',
          'name': 'Team A'
        },
        'reason': null,
        'is_second_yellow': true,
      };

      final card = Card.fromJson(json);

      expect(card.id, 2);
      expect(card.cardType, 'Red');
      expect(card.minute, 75);
      expect(card.stoppageMinute, 0);
      expect(card.team.id, 3);
      expect(card.isSecondYellow, true);
      expect(card.reason, null);
      expect(card.player, null);
    });
  });
}
