import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// main.dart turns off google_fonts' runtime fetching, so every family and
// weight the app asks for must be bundled in google_fonts/. Otherwise that
// text silently falls back to the default font.
const _weightNames = {
  400: 'Regular',
  500: 'Medium',
  600: 'SemiBold',
  700: 'Bold',
  800: 'ExtraBold',
};

void main() {
  test('every GoogleFonts style used in lib/ has a bundled font file', () {
    final needed = <String>{};
    final sources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in sources) {
      final src = file.readAsStringSync();
      for (final call in RegExp(r'GoogleFonts\.(\w+)\(').allMatches(src)) {
        final family = call.group(1)!;
        if (family.endsWith('TextTheme')) continue;
        // The call's arguments, up to the matching parenthesis.
        var depth = 1, end = call.end;
        while (depth > 0 && end < src.length) {
          if (src[end] == '(') depth++;
          if (src[end] == ')') depth--;
          end++;
        }
        final args = src.substring(call.end, end);
        final italic = args.contains('FontStyle.italic');
        final weights = RegExp(r'FontWeight\.w(\d+)')
            .allMatches(args)
            .map((m) => int.parse(m.group(1)!))
            .toList();
        if (args.contains('FontWeight.bold')) weights.add(700);
        if (weights.isEmpty) weights.add(400);

        final name = family[0].toUpperCase() + family.substring(1);
        for (final weight in weights) {
          final variant = italic
              ? (weight == 400 ? 'Italic' : '${_weightNames[weight]}Italic')
              : _weightNames[weight];
          needed.add('google_fonts/$name-$variant.ttf');
        }
      }
    }

    expect(needed, isNotEmpty);
    final missing = needed.where((path) => !File(path).existsSync());
    expect(missing, isEmpty,
        reason: 'download them as described in google_fonts/README.md');
  });
}
