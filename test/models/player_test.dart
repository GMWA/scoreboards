import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/player.dart';

void main() {
  group('PlayerLookup', () {
    test('fromJson creates correct model', () {
      final json = {
        'id': 1,
        'slug': 'kylian-mbappe',
        'firstname': 'Kylian',
        'lastname': 'Mbappé',
        'avatar': 'mbappe.png',
        'jersey_number': 7,
      };

      final player = PlayerLookup.fromJson(json);

      expect(player.id, 1);
      expect(player.slug, 'kylian-mbappe');
      expect(player.firstname, 'Kylian');
      expect(player.lastname, 'Mbappé');
      expect(player.avatar, 'mbappe.png');
      expect(player.jerseyNumber, 7);
    });
  });

  group('Player', () {
    test('fromJson creates correct model', () {
      final json = {
        'id': 10,
        'slug': 'lionel-messi',
        'firstname': 'Lionel',
        'lastname': 'Messi',
        'position': 'Forward',
        'nationality': 'Argentina',
        'date_of_birth': '1987-06-24',
        'jersey_number': 10,
        'matricule': 'LM10',
        'avatar': 'messi.png',
      };

      final player = Player.fromJson(json);

      expect(player.id, 10);
      expect(player.slug, 'lionel-messi');
      expect(player.firstname, 'Lionel');
      expect(player.lastname, 'Messi');
      expect(player.position, 'Forward');
      expect(player.nationality, 'Argentina');
      expect(player.dateOfBirth, DateTime(1987, 6, 24));
      expect(player.jerseyNumber, 10);
      expect(player.matricule, 'LM10');
      expect(player.avatar, 'messi.png');
    });
  });

  group('PlayerStats', () {
    test('fromJson creates correct model', () {
      final json = {
        'player': {
          'id': 1,
          'slug': 'kylian-mbappe',
          'firstname': 'Kylian',
          'lastname': 'Mbappé',
        },
        'goals': 20,
        'assists': 10,
        'yellow_cards': 3,
        'red_cards': 1,
        'team': {
          'id': 5,
          'slug': 'psg',
          'name': 'PSG',
        }
      };

      final stats = PlayerStats.fromJson(json);

      expect(stats.goals, 20);
      expect(stats.assists, 10);
      expect(stats.yellowCards, 3);
      expect(stats.redCards, 1);
      expect(stats.player.firstname, 'Kylian');
      expect(stats.playerTeam.name, 'PSG');
    });
  });

  group('PlayerTeamHistory', () {
    test('fromJson creates correct model', () {
      final json = {
        'team': {
          'id': 1,
          'slug': 'real-madrid',
          'name': 'Real Madrid'
        },
        'start_date': '2020-07-01',
        'end_date': '2023-06-30'
      };

      final history = PlayerTeamHistory.fromJson(json);

      expect(history.startDate, DateTime(2020, 7, 1));
      expect(history.endDate, DateTime(2023, 6, 30));
      expect(history.team.name, 'Real Madrid');
    });

    test('handles null endDate', () {
      final json = {
        'team': {'id': 2, 'slug': 'psg', 'name': 'PSG'},
        'start_date': '2023-07-01',
        'end_date': null
      };

      final history = PlayerTeamHistory.fromJson(json);

      expect(history.endDate, null);
      expect(history.team.name, 'PSG');
    });
  });

  group('PlayerContract', () {
    test('fromJson creates correct model', () {
      final json = {
        'id': 1,
        'player': {
          'id': 10,
          'slug': 'lionel-messi',
          'firstname': 'Lionel',
          'lastname': 'Messi'
        },
        'team': {'id': 5, 'slug': 'psg', 'name': 'PSG'},
        'start_date': '2023-07-01',
        'end_date': '2024-06-30',
        'fee': 50000000
      };

      final contract = PlayerContract.fromJson(json);

      expect(contract.startDate, DateTime(2023, 7, 1));
      expect(contract.endDate, DateTime(2024, 6, 30));
      expect(contract.fee, 50000000.0);
      expect(contract.player.firstname, 'Lionel');
      expect(contract.team.name, 'PSG');
    });

    test('handles null endDate and fee', () {
      final json = {
        'id': 2,
        'player': {
          'id': 1,
          'slug': 'kyllian-mbappe',
          'firstname': 'Kylian',
          'lastname': 'Mbappé'
        },
        'team': {'id': 10, 'slug': 'psg', 'name': 'PSG'},
        'start_date': '2023-07-01',
        'end_date': null,
        'fee': null
      };

      final contract = PlayerContract.fromJson(json);

      expect(contract.endDate, null);
      expect(contract.fee, null);
    });
  });
}
