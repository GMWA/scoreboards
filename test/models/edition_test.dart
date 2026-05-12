import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/editions.dart';

void main() {
  group('ChampionshipEdition', () {
    test('fromJson creates correct model', () {
      final json = {
        'id': 1,
        'name': 'Premier League',
        'country': 'England',
        'logo': 'premier.png',
      };

      final edition = ChampionshipEdition.fromJson(json);

      expect(edition.id, 1);
      expect(edition.name, 'Premier League');
      expect(edition.country, 'England');
      expect(edition.logo, 'premier.png');
    });
  });

  group('MatchEdition', () {
    test('fromJson creates correct model', () {
      final json = {
        'id': 10,
        'slug': 'premier-league-2025',
        'championship': {
          'id': 1,
          'name': 'Premier League',
          'country': 'England',
          'logo': null
        },
        'year': '2024',
        'label': 'Season 2024',
        'start_date': '2024-08-01',
        'end_date': '2025-05-15',
        'is_current': true,
      };

      final edition = MatchEdition.fromJson(json);

      expect(edition.id, 10);
      expect(edition.slug, 'premier-league-2025');
      expect(edition.year, '2024');
      expect(edition.label, 'Season 2024');
      expect(edition.isCurrent, true);

      expect(edition.startDate, DateTime(2024, 8, 1));
      expect(edition.endDate, DateTime(2025, 5, 15));

      expect(edition.championship.id, 1);
      expect(edition.championship.name, 'Premier League');
    });
  });

  group('Edition', () {
    test('fromJson creates correct model', () {
      final json = {
        'id': 20,
        'slug': 'la-liga-2024',
        'championship': {
          'id': 2,
          'name': 'La Liga',
          'country': 'Spain',
          'logo': 'laliga.png',
        },
        'year': '2023',
        'label': null,
        'start_date': '2023-08-10',
        'end_date': '2024-05-30',
        'is_current': false,
      };

      final edition = Edition.fromJson(json);

      expect(edition.id, 20);
      expect(edition.slug, 'la-liga-2024');
      expect(edition.year, '2023');
      expect(edition.label, null);
      expect(edition.isCurrent, false);

      expect(edition.startDate, DateTime(2023, 8, 10));
      expect(edition.endDate, DateTime(2024, 5, 30));

      expect(edition.championship.name, 'La Liga');
      expect(edition.championship.country, 'Spain');
      expect(edition.championship.logo, 'laliga.png');
    });
  });
}
