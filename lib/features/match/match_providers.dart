import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/features/match/match_repository.dart';
import 'package:scoreboards/shared/models/match.dart';

/// A match with its events, lineups and statistics.
final matchProvider = FutureProvider.autoDispose.family<Match, String>(
  (ref, slug) => ref.watch(matchRepositoryProvider).bySlug(slug),
);
