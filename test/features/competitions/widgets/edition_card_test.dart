import 'package:flutter/material.dart';
import 'package:scoreboards/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/shared/models/editions.dart';
import 'package:scoreboards/features/competitions/widgets/edition_card.dart';

import '../../../helpers/harness.dart';

void main() {
  group('EditionCard Widget Tests', () {
    testWidgets('renders edition information correctly', (WidgetTester tester) async {
      // Arrange test data
      final championship = ChampionshipEdition(
        id: 1,
        name: 'Premier League',
        logo: 'https://example.com/logo.png',
        country: 'England',
      );

      final edition = Edition(
        id: 10,
        slug: "premier-league-2024-2025",
        label: '2024/25',
        year: '2024',
        championship: championship,
        isCurrent: false
      );

      // Pump the widget
      await pumpWithProviders(tester, 
        MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: EditionCard(edition: edition),
          ),
        ),
      );

      expect(find.text('2024/25'), findsOneWidget);

      expect(find.text('England'), findsOneWidget);

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      final championship = ChampionshipEdition(
        id: 1,
        name: 'Premier League',
        logo: 'https://example.com/logo.png',
        country: 'England',
      );

      final edition = Edition(
        id: 10,
        slug: "premier-league-2024-2025",
        label: '2024/25',
        year: '2024',
        championship: championship,
        isCurrent: true
      );

      await pumpWithProviders(tester, 
        MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: EditionCard(
              edition: edition,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(EditionCard));
      await tester.pump();

      expect(tapped, true);
    });
  });
}
