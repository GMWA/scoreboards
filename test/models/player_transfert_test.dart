import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/transfert.dart';

void main() {
  group('PlayerTransfert', () {
    test('fromJson creates correct model with full data', () {
      final json = {
        'id': 1,
        'player': {
          'id': 50,
          'slug': 'lionel-mbappe',
          'firstname': 'Lionel',
          'lastname': 'Messi',
          'logo': null,
        },
        'team': {
          'id': 10,
          'slug': 'inter-miami',
          'name': 'Inter Miami',
          'logo': 'inter.png',
        },
        'start_date': '2023-07-01',
        'end_date': '2024-06-30',
        'fee': 15000000.50,
      };

      final transfert = PlayerTransfert.fromJson(json);

      expect(transfert.id, 1);

      expect(transfert.player.id, 50);
      expect(transfert.player.firstname, 'Lionel');
      expect(transfert.player.lastname, 'Messi');
      expect(transfert.player.avatar, null);

      expect(transfert.team.id, 10);
      expect(transfert.team.name, 'Inter Miami');
      expect(transfert.team.logo, 'inter.png');

      expect(transfert.startDate, DateTime(2023, 7, 1));
      expect(transfert.endDate, DateTime(2024, 6, 30));

      expect(transfert.fee, 15000000.50);
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 2,
        'player': {
          'id': 99,
          'slug': 'kyllian-mbappe',
          'firstname': 'Kylian',
          'lastname': 'Mbappé',
          'logo': 'mbappe.png',
        },
        'team': {
          'id': 5,
          'slug': 'real-madrid',
          'name': 'Real Madrid',
          'logo': null,
        },
        'start_date': null,
        'end_date': null,
        'fee': null,
      };

      final transfert = PlayerTransfert.fromJson(json);

      expect(transfert.id, 2);

      expect(transfert.player.firstname, 'Kylian');
      expect(transfert.player.lastname, 'Mbappé');

      expect(transfert.team.name, 'Real Madrid');
      expect(transfert.team.logo, null);

      expect(transfert.startDate, null);
      expect(transfert.endDate, null);
      expect(transfert.fee, null);
    });

    test('fromJson converts integer fee to double', () {
      final json = {
        'id': 3,
        'player': {
          'id': 77,
          'slug': 'erling-haaland',
          'firstname': 'Erling',
          'lastname': 'Haaland',
        },
        'team': {
          'id': 33,
          'slug': 'manchester-city',
          'name': 'Manchester City',
        },
        'start_date': '2022-07-01',
        'end_date': '2023-06-30',
        'fee': 100000000,
      };

      final transfert = PlayerTransfert.fromJson(json);

      expect(transfert.fee, isA<double>());
      expect(transfert.fee, 100000000.0);
    });
  });
}
