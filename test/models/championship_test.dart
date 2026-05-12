import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/championship.dart';

void main() {
  group('Championship', () {
    test('fromJson creates correct model with editions', () {
      final json = {
        'id': 1,
        'name': 'UEFA Champions League',
        'country': 'Europe',
        'logo': 'ucl.png',
        'editions': [
          {
            'id': 101,
            'slug': 'uefa-champions-league-2023',
            'championship': {
              'id': 1,
              'name': 'UEFA Champions League',
              'country': 'Europe',
              'logo': 'ucl.png',
            },
            'year': '2023',
            'label': '2023/24',
            'start_date': '2023-09-01',
            'end_date': '2024-06-10',
            'is_current': true,
          },
          {
            'id': 100,
            'slug': 'usefa-champions-league-2022',
            'championship': {
              'id': 1,
              'name': 'UEFA Champions League',
              'country': 'Europe',
              'logo': 'ucl.png',
            },
            'year': '2022',
            'label': '2022/23',
            'start_date': '2022-09-01',
            'end_date': '2023-06-10',
            'is_current': false,
          },
        ]
      };

      final championship = Championship.fromJson(json);

      // Basic fields
      expect(championship.id, 1);
      expect(championship.name, 'UEFA Champions League');
      expect(championship.country, 'Europe');
      expect(championship.logo, 'ucl.png');

      // Editions list
      expect(championship.editions.length, 2);

      final firstEdition = championship.editions[0];
      expect(firstEdition.id, 101);
      expect(firstEdition.year, '2023');
      expect(firstEdition.label, '2023/24');
      expect(firstEdition.isCurrent, true);
      expect(firstEdition.startDate, DateTime(2023, 9, 1));

      final secondEdition = championship.editions[1];
      expect(secondEdition.id, 100);
      expect(secondEdition.year, '2022');
      expect(secondEdition.isCurrent, false);

      // Nested championship inside Edition
      expect(firstEdition.championship.name, 'UEFA Champions League');
      expect(firstEdition.championship.country, 'Europe');
    });
  });
}
