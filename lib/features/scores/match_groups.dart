import 'package:scoreboards/shared/models/match.dart';
import 'package:scoreboards/shared/models/match_enums.dart';

/// The match list's filter chips.
enum ScoreFilter { all, live, upcoming, finished }

/// One competition's block on the Scores screen.
class MatchGroup {
  MatchGroup({
    required this.editionId,
    required this.slug,
    required this.label,
    required this.logo,
  });

  final int editionId;
  final String slug;
  final String label;
  final String? logo;
  final List<MatchBase> matches = [];
}

/// The matches [filter] keeps, live ones first, grouped by competition in
/// order of their first match.
List<MatchGroup> groupMatches(List<MatchBase> matches, ScoreFilter filter) {
  final kept = matches.where((m) => switch (filter) {
        ScoreFilter.all => true,
        ScoreFilter.live => m.status == MatchStatus.ongoing,
        ScoreFilter.upcoming =>
          m.status == MatchStatus.planned || m.status == MatchStatus.scheduled,
        ScoreFilter.finished => m.status == MatchStatus.completed ||
            m.status == MatchStatus.awarded ||
            m.status == MatchStatus.resultUnknown,
      });

  // Live matches float to the top, regardless of scheduled kickoff order:
  // the thing people most want to see first on a day with mixed
  // live/upcoming/finished matches. Partitioned (not List.sort, which
  // isn't guaranteed stable) so relative order within each group is
  // otherwise preserved.
  final live = <MatchBase>[];
  final rest = <MatchBase>[];
  for (final m in kept) {
    (m.status == MatchStatus.ongoing ? live : rest).add(m);
  }

  final groups = <int, MatchGroup>{};
  for (final match in [...live, ...rest]) {
    final edition = match.edition;
    groups
        .putIfAbsent(
          edition.id,
          () => MatchGroup(
            editionId: edition.id,
            slug: edition.slug,
            label: (edition.label ?? edition.year).toString(),
            logo: edition.championship.logo,
          ),
        )
        .matches
        .add(match);
  }
  return groups.values.toList();
}
