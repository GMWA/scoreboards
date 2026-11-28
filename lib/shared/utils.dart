/// Human label for a match's backend `round`: a bare number is a league
/// matchday; knockout rounds arrive as short codes.
String roundLabel(String round) {
  final value = round.trim();
  if (value.isEmpty) return value;
  if (int.tryParse(value) != null) return 'Matchday $value';
  switch (value.toUpperCase()) {
    case 'F':
      return 'Final';
    case 'SF':
      return 'Semi-final';
    case 'QF':
      return 'Quarter-final';
    case 'TP':
      return 'Third place';
    case 'R16':
      return 'Round of 16';
    case 'R32':
      return 'Round of 32';
  }
  return value;
}

/// "forward" -> "Forward", "national" -> "National" (backend values are
/// lowercase identifiers).
String capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
