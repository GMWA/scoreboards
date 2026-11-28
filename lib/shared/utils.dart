import 'package:scoreboards/l10n/app_localizations.dart';

/// Human label for a match's backend `round`: a bare number is a league
/// matchday; knockout rounds arrive as short codes.
String roundLabel(AppLocalizations l10n, String round) {
  final value = round.trim();
  if (value.isEmpty) return value;
  if (int.tryParse(value) != null) return l10n.roundMatchday(value);
  return switch (value.toUpperCase()) {
    'F' => l10n.roundFinal,
    'SF' => l10n.roundSemiFinal,
    'QF' => l10n.roundQuarterFinal,
    'TP' => l10n.roundThirdPlace,
    'R16' => l10n.roundOf16,
    'R32' => l10n.roundOf32,
    _ => value,
  };
}

/// A player's backend `position` ("forward"), in the app's language.
String positionLabel(AppLocalizations l10n, String position) =>
    switch (position) {
      'goalkeeper' => l10n.positionGoalkeeper,
      'defender' => l10n.positionDefender,
      'midfielder' => l10n.positionMidfielder,
      'forward' => l10n.positionForward,
      _ => capitalize(position),
    };

/// A team's backend `team_type` ("national"), in the app's language.
String teamTypeLabel(AppLocalizations l10n, String teamType) =>
    switch (teamType) {
      'club' => l10n.teamTypeClub,
      'national' => l10n.teamTypeNational,
      _ => capitalize(teamType),
    };

/// "forward" -> "Forward", "national" -> "National" (backend values are
/// lowercase identifiers).
String capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
