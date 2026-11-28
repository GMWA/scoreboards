import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/core/providers.dart';
import 'package:scoreboards/features/favorites/favorite_item.dart';
import 'package:scoreboards/features/favorites/favorites_repository.dart';

/// The teams and competitions this device follows.
@immutable
class Favorites {
  const Favorites({this.teams = const {}, this.competitions = const {}});

  final Map<int, FavoriteItem> teams;
  final Map<int, FavoriteItem> competitions;

  bool isTeamFollowed(int id) => teams.containsKey(id);
  bool isCompetitionFollowed(int id) => competitions.containsKey(id);

  bool isFollowed(FavoriteItem item) => item.kind == FavoriteKind.team
      ? isTeamFollowed(item.id)
      : isCompetitionFollowed(item.id);

  List<FavoriteItem> get followedTeams => _sorted(teams);
  List<FavoriteItem> get followedCompetitions => _sorted(competitions);

  List<FavoriteItem> followed(FavoriteKind kind) =>
      kind == FavoriteKind.team ? followedTeams : followedCompetitions;

  /// For the Scores screen's "Following" row: teams first (the more common
  /// thing to follow day to day), then competitions.
  List<FavoriteItem> get allFollowed =>
      [...followedTeams, ...followedCompetitions];

  bool get isEmpty => teams.isEmpty && competitions.isEmpty;

  static List<FavoriteItem> _sorted(Map<int, FavoriteItem> items) =>
      items.values.toList()..sort((a, b) => a.name.compareTo(b.name));
}

/// Follows and unfollows, from any star in the app.
///
/// Stored on the device (shared_preferences), so following works at once
/// and offline. The favorites are also copied to the backend after each
/// change (statistics on who follows what, and whom to notify); a failed
/// copy is retried on the next launch.
final favoritesProvider =
    NotifierProvider<FavoritesController, Favorites>(FavoritesController.new);

class FavoritesController extends Notifier<Favorites> {
  static const _teamsKey = 'favorite_teams_v1';
  static const _competitionsKey = 'favorite_competitions_v1';
  // false: the backend may not have the latest favorites. Missing: never
  // synced, which only matters when there are favorites to send.
  static const _syncedKey = 'favorites_synced_v1';

  // Counts local changes, so a sync knows whether it sent the latest.
  int _changes = 0;
  Future<void> _syncChain = Future.value();
  Future<void>? _queuedSync;

  @override
  Favorites build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final favorites = Favorites(
      teams: _read(_teamsKey),
      competitions: _read(_competitionsKey),
    );

    final synced = prefs.getBool(_syncedKey);
    if (synced == false || (synced == null && !favorites.isEmpty)) {
      Future.microtask(syncNow);
    }
    return favorites;
  }

  Map<int, FavoriteItem> _read(String key) {
    final rows = ref.read(sharedPreferencesProvider).getStringList(key) ?? [];
    final items = rows.map((raw) => FavoriteItem.fromJson(jsonDecode(raw)));
    return {for (final item in items) item.id: item};
  }

  Future<void> toggle(FavoriteItem item) async {
    final current = state.isFollowed(item);
    await _set(item, follow: !current);
  }

  Future<void> remove(FavoriteItem item) async {
    if (state.isFollowed(item)) await _set(item, follow: false);
  }

  Future<void> _set(FavoriteItem item, {required bool follow}) async {
    final isTeam = item.kind == FavoriteKind.team;
    final items = {...isTeam ? state.teams : state.competitions};
    if (follow) {
      items[item.id] = item;
    } else {
      items.remove(item.id);
    }
    state = isTeam
        ? Favorites(teams: items, competitions: state.competitions)
        : Favorites(teams: state.teams, competitions: items);

    _changes++;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setStringList(
      isTeam ? _teamsKey : _competitionsKey,
      items.values.map((e) => jsonEncode(e.toJson())).toList(),
    );
    await prefs.setBool(_syncedKey, false);
    unawaited(syncNow());
  }

  /// Sends the current favorites to the backend. Syncs run one at a time;
  /// calls made while one runs queue a single follow-up, which reads the
  /// state when it starts, so the backend ends up with the latest
  /// favorites. Never throws.
  Future<void> syncNow() {
    return _queuedSync ??= _syncChain = _syncChain.then((_) {
      _queuedSync = null;
      return _syncOnce();
    });
  }

  Future<void> _syncOnce() async {
    if (!ref.mounted) return;
    final changesSeen = _changes;
    final prefs = ref.read(sharedPreferencesProvider);
    try {
      await ref.read(favoritesRepositoryProvider).sync(
            teams: state.teams.keys.toList(),
            editions: state.competitions.keys.toList(),
          );
    } catch (e) {
      // Offline or the backend is down: the flag stays false, so the next
      // launch tries again.
      debugPrint('Favorites sync failed: $e');
      return;
    }
    // A change made during the request has its own sync queued; only mark
    // the backend up to date if it has what is stored now.
    if (_changes == changesSeen) await prefs.setBool(_syncedKey, true);
  }
}
