import 'package:flutter/material.dart';
import 'package:scoreboards/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/shared/widgets/logo.dart';

void main() {
  group('Logo Widget Tests', () {
    testWidgets('shows default icon when url is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(body: Logo(url: null)),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);

      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
    });

    testWidgets('loads network image when url is provided', (WidgetTester tester) async {
      const testUrl = 'https://example.com/logo.png';

      await tester.pumpWidget(
        const MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(body: Logo(url: testUrl)),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);

      expect(find.byIcon(Icons.sports_soccer), findsNothing);

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.backgroundImage, isNotNull);
      expect(avatar.backgroundImage.toString(), contains(testUrl));
    });
  });
}
