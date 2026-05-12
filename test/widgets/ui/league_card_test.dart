import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/championship.dart';
import 'package:scoreboards/widgets/ui/league_card.dart';

void main() {
  group('LeagueCard Widget Tests', () {
    testWidgets('renders championship info', (WidgetTester tester) async {
      // Arrange
      final championship = Championship(
        id: 1,
        name: 'La Liga',
        logo: 'https://example.com/la-liga.png',
        country: 'Spain',
        editions: []
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeagueCard(championship: championship),
          ),
        ),
      );

      expect(find.text('La Liga'), findsOneWidget);

      expect(find.text('Spain'), findsOneWidget);

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('triggers onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      final championship = Championship(
        id: 2,
        name: 'Serie A',
        logo: 'https://example.com/serie-a.png',
        country: 'Italy',
        editions: []
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeagueCard(
              championship: championship,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(LeagueCard));
      await tester.pump();

      expect(tapped, true);
    });
  });
}
