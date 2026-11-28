import 'package:flutter/material.dart';
import 'package:scoreboards/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/shared/assets.dart';

void main() {
  testWidgets('the logo asset loads and keeps its wide shape', (tester) async {
    final info = await tester
        .runAsync(() => vg.loadPicture(const SvgAssetLoader(logoAsset), null));
    expect(info!.size.width / info.size.height, closeTo(2402.68 / 512, 0.01));
    info.picture.dispose();

    await tester.pumpWidget(MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Center(
          child: SvgPicture.asset(logoAsset,
              height: 26, semanticsLabel: 'Scoreboards')),
    ));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Scoreboards'), findsOneWidget);
  });
}
