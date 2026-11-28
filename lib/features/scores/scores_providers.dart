import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/features/match/match_repository.dart';
import 'package:scoreboards/shared/models/match.dart';

/// The matches of a calendar [day], or the live ones when [day] is null.
/// Days are compared by date, so pass midnight (see [scoresDay]).
final scoresProvider =
    FutureProvider.autoDispose.family<List<MatchBase>, DateTime?>((ref, day) {
  final repo = ref.watch(matchRepositoryProvider);
  return day == null ? repo.live() : repo.byDay(day);
});

/// The [scoresProvider] key for [date]'s day.
DateTime scoresDay(DateTime date) => DateTime(date.year, date.month, date.day);
