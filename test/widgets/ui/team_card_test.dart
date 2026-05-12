import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/widgets/ui/team_card.dart';
import 'package:scoreboards/models/team.dart';
import 'package:scoreboards/models/stadium.dart';

void main() {
  group("TeamCard Widget Tests", () {
    late Team baseTeam;

    setUp(() {
      baseTeam = Team(
        id: 1,
        name: "FC Example",
        slug: "fc-example",
        logo: null,
        teamType: "club",
        coach: "Test Coach",
        stadium: Stadium(
            id: 2,
            name: "Camp Nou",
            slug: "camp-nou",
            city: "Barcelona",
            country: "Spain",
            capacity: 25000,
            address: "",
            isOpened: true
          ),
        league: "Elite League",
        country: "Testland",
        confederation: "UEFA",
      );
    });

    testWidgets("renders team name and stadium", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TeamCard(team: baseTeam),
        ),
      );

      expect(find.text("FC Example"), findsOneWidget);
      expect(find.text("Stadium: Camp Nou"), findsOneWidget);
    });

    testWidgets("shows default icon when logo is null",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TeamCard(
            team: Team(
              id: 1,
              name: "No Logo FC",
              slug: "no-logo-fc",
              coach: "",
              teamType: "",
              league: "",
              country: "",
              confederation: "",
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets("loads Image.network when logo exists",
        (WidgetTester tester) async {
      final teamWithLogo = Team(
        id: 1,
        name: "FC Example",
        slug: "fc-example",
        logo: "https://fake-url/logo.png",
        teamType: "club",
        coach: "Test Coach",
        stadium: Stadium(
            id: 2,
            name: "Camp no",
            slug: "camp-nou",
            city: "Barcelona",
            country: "Spain",
            address: "",
            capacity: 25000,
            isOpened: true),
        league: "Elite League",
        country: "Testland",
        confederation: "UEFA",
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TeamCard(team: teamWithLogo),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);

      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect(imageWidget.image, isA<NetworkImage>());
    });

    testWidgets("shows image fallback icon on errorBuilder",
        (WidgetTester tester) async {
      final teamWithLogo = Team(
        id: 1,
        name: "FC Example",
        slug: "fc-example",
        logo: "https://fake/fail.png",
        teamType: "club",
        coach: "Test Coach",
        stadium: Stadium(
            id: 2,
            name: "Camp Nou",
            slug: "camp-nou",
            city: "Barcelona",
            country: "Spain",
            address: "",
            capacity: 25000,
            isOpened: true
          ),
        league: "Elite League",
        country: "Testland",
        confederation: "UEFA",
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TeamCard(team: teamWithLogo),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });
  });
}
