import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/shared/utils.dart';

void main() {
  group('roundLabel', () {
    test('numbers are matchdays, codes are knockout rounds', () {
      expect(roundLabel('22'), 'Matchday 22');
      expect(roundLabel('F'), 'Final');
      expect(roundLabel('sf'), 'Semi-final');
      expect(roundLabel('QF'), 'Quarter-final');
      expect(roundLabel('TP'), 'Third place');
      expect(roundLabel('R16'), 'Round of 16');
    });

    test('unknown and empty values pass through', () {
      expect(roundLabel('Group A'), 'Group A');
      expect(roundLabel(''), '');
    });
  });

  test('capitalize upper-cases the first letter only', () {
    expect(capitalize('forward'), 'Forward');
    expect(capitalize('national'), 'National');
    expect(capitalize(''), '');
  });
}
