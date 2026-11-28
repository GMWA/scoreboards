import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/features/match/match_repository.dart';
import 'package:scoreboards/shared/models/match.dart';

/// An edition's matches as loaded so far, a page at a time.
@immutable
class EditionMatchesState {
  const EditionMatchesState({
    this.matches = const [],
    this.nextPage = 1,
    this.isLoading = false,
    this.failed = false,
  });

  final List<MatchBase> matches;

  /// The page to load next; null once every page is loaded.
  final int? nextPage;
  final bool isLoading;

  /// The last page request failed (a retry loads it again).
  final bool failed;

  bool get hasMore => nextPage != null;
}

final editionMatchesProvider = NotifierProvider.autoDispose
    .family<EditionMatchesController, EditionMatchesState, int>(
        EditionMatchesController.new);

class EditionMatchesController extends Notifier<EditionMatchesState> {
  EditionMatchesController(this.editionId);

  final int editionId;
  bool _inFlight = false;

  @override
  EditionMatchesState build() {
    Future.microtask(loadNextPage);
    return const EditionMatchesState(isLoading: true);
  }

  /// Loads the next page, unless one is loading or all are loaded.
  Future<void> loadNextPage() async {
    if (!ref.mounted) return;
    final page = state.nextPage;
    if (_inFlight || page == null) return;
    _inFlight = true;

    state = EditionMatchesState(
      matches: state.matches,
      nextPage: page,
      isLoading: true,
    );
    try {
      final result = await ref
          .read(matchRepositoryProvider)
          .byEditionPage(editionId, page: page);
      if (!ref.mounted) return;
      state = EditionMatchesState(
        matches: [...state.matches, ...result.items],
        nextPage: result.nextPage,
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = EditionMatchesState(
        matches: state.matches,
        nextPage: page,
        failed: true,
      );
    } finally {
      _inFlight = false;
    }
  }
}
