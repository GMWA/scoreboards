import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/shared/utils.dart';

import '../helpers/l10n.dart';

void main() {
  group('roundLabel', () {
    test('numbers are matchdays, codes are knockout rounds', () {
      expect(roundLabel(en, '22'), 'Matchday 22');
      expect(roundLabel(en, 'F'), 'Final');
      expect(roundLabel(en, 'sf'), 'Semi-final');
      expect(roundLabel(en, 'QF'), 'Quarter-final');
      expect(roundLabel(en, 'TP'), 'Third place');
      expect(roundLabel(en, 'R16'), 'Round of 16');
    });

    test('in French', () {
      expect(roundLabel(fr, '22'), 'Journée 22');
      expect(roundLabel(fr, 'SF'), 'Demi-finale');
      expect(roundLabel(fr, 'R16'), 'Huitièmes de finale');
    });

    test('unknown and empty values pass through', () {
      expect(roundLabel(en, 'Group A'), 'Group A');
      expect(roundLabel(en, ''), '');
    });
  });

  test('positions and team types are translated', () {
    expect(positionLabel(en, 'forward'), 'Forward');
    expect(positionLabel(fr, 'goalkeeper'), 'Gardien');
    expect(positionLabel(fr, 'winger'), 'Winger');
    expect(teamTypeLabel(en, 'national'), 'National');
    expect(teamTypeLabel(fr, 'club'), 'Club');
    expect(teamTypeLabel(fr, 'national'), 'Sélection nationale');
  });

  test('capitalize upper-cases the first letter only', () {
    expect(capitalize('forward'), 'Forward');
    expect(capitalize('national'), 'National');
    expect(capitalize(''), '');
  });
}
