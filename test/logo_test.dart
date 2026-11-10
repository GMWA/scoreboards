import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/constants/commons.dart';

void main() {
  testWidgets('the logo asset loads and keeps its wide shape', (tester) async {
    final info = await tester
        .runAsync(() => vg.loadPicture(const SvgAssetLoader(iMGLOGO), null));
    expect(info!.size.width / info.size.height, closeTo(2402.68 / 512, 0.01));
    info.picture.dispose();

    await tester.pumpWidget(MaterialApp(
      home: Center(
          child: SvgPicture.asset(iMGLOGO,
              height: 26, semanticsLabel: 'Scoreboards')),
    ));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Scoreboards'), findsOneWidget);
  });
}
