import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/goal.dart';

void main() {
  group('GoalPlayer model', () {
    test('fromJson should create a valid GoalPlayer object', () {
      final json = {
        'id': 7,
        'slug': 'samuel-etoo',
        'firstname': 'Samuel',
        'lastname': 'Eto\'o',
        'logo': 'player.png',
        'jersey_number': 9,
      };

      final player = GoalPlayer.fromJson(json);

      expect(player.id, 7);
      expect(player.slug, 'samuel-etoo');
      expect(player.firstname, 'Samuel');
      expect(player.lastname, 'Eto\'o');
      expect(player.logo, 'player.png');
      expect(player.jerseyNumber, 9);
    });

    test('fromJson should handle null optional fields', () {
      final json = {
        'id': 8,
        'slug': 'leonel-messi',
        'firstname': 'Lionel',
        'lastname': 'Messi',
        'logo': null,
        'jersey_number': null,
      };

      final player = GoalPlayer.fromJson(json);

      expect(player.id, 8);
      expect(player.slug, 'leonel-messi');
      expect(player.firstname, 'Lionel');
      expect(player.lastname, 'Messi');
      expect(player.logo, null);
      expect(player.jerseyNumber, null);
    });
  });
}
