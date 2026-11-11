import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoreboards/models/favorite_item.dart';
import 'package:scoreboards/services/favorites_sync.dart';

typedef FavoritesSyncer = Future<void> Function({
  required List<int> teams,
  required List<int> editions,
});

/// Local, device-only "follow" store for teams and competitions.
///
/// This is the mechanism the redesign concept calls "Favorites" — one
/// follow toggle, usable from a team card, an edition card, a match card,
/// or a detail screen header, that feeds:
///  - the "Following" row on the Scores screen
///  - the Favorites management list in Settings
///  - (future) which teams/competitions notification prefs apply to
///
/// Backed by shared_preferences, so following works instantly and
/// offline. The device's favorites are also copied to the backend (for
/// statistics on who follows what) in the background after each change; a
/// failed copy is retried on the next launch.
class FavoritesService extends ChangeNotifier {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  static const _teamsKey = 'favorite_teams_v1';
  static const _competitionsKey = 'favorite_competitions_v1';
  // false: the backend may not have the latest favorites. Missing: never
  // synced, which only matters when there are favorites to send.
  static const _syncedKey = 'favorites_synced_v1';

  /// Replaced in tests, so they don't reach the network.
  @visibleForTesting
  FavoritesSyncer syncer = syncFavoritesToBackend;

  SharedPreferences? _prefs;
  final Map<int, FavoriteItem> _teams = {};
  final Map<int, FavoriteItem> _competitions = {};
  bool _loaded = false;
  // Counts local changes, so a sync knows whether it sent the latest.
  int _changes = 0;
  Future<void> _syncChain = Future.value();
  Future<void>? _queuedSync;

  Future<void> init() async {
    if (_loaded) return;
    _prefs = await SharedPreferences.getInstance();

    for (final raw in _prefs!.getStringList(_teamsKey) ?? const []) {
      final item = FavoriteItem.fromJson(jsonDecode(raw));
      _teams[item.id] = item;
    }
    for (final raw in _prefs!.getStringList(_competitionsKey) ?? const []) {
      final item = FavoriteItem.fromJson(jsonDecode(raw));
      _competitions[item.id] = item;
    }

    _loaded = true;
    notifyListeners();

    final synced = _prefs!.getBool(_syncedKey);
    if (synced == false || (synced == null && hasAnyFavorites)) {
      unawaited(syncNow());
    }
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
    final changesSeen = _changes;
    try {
      await syncer(
        teams: _teams.keys.toList(),
        editions: _competitions.keys.toList(),
      );
    } catch (e) {
      // Offline or the backend is down: the flag stays false, so the next
      // launch tries again.
      debugPrint('Favorites sync failed: $e');
      return;
    }
    // A change made during the request has its own sync queued; only mark
    // the backend up to date if it has what is stored now.
    if (_changes == changesSeen) await _prefs?.setBool(_syncedKey, true);
  }

  bool isTeamFollowed(int id) => _teams.containsKey(id);
  bool isCompetitionFollowed(int id) => _competitions.containsKey(id);

  bool isFollowed(FavoriteItem item) => item.kind == FavoriteKind.team
      ? isTeamFollowed(item.id)
      : isCompetitionFollowed(item.id);

  List<FavoriteItem> get followedTeams =>
      _teams.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  List<FavoriteItem> get followedCompetitions =>
      _competitions.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  /// Combined, for the Scores screen's "Following" row — teams first (the
  /// more common thing to follow day-to-day), then competitions.
  List<FavoriteItem> get allFollowed => [
        ...followedTeams,
        ...followedCompetitions,
      ];

  bool get hasAnyFavorites => _teams.isNotEmpty || _competitions.isNotEmpty;

  /// Clears in-memory state so [init] re-reads from prefs. Since this is a
  /// singleton, tests need this to get a clean slate between cases.
  @visibleForTesting
  void resetForTesting() {
    _prefs = null;
    _teams.clear();
    _competitions.clear();
    _loaded = false;
    _changes = 0;
    _syncChain = Future.value();
    _queuedSync = null;
  }

  Future<void> toggle(FavoriteItem item) async {
    await init();
    final map = item.kind == FavoriteKind.team ? _teams : _competitions;
    if (map.containsKey(item.id)) {
      map.remove(item.id);
    } else {
      map[item.id] = item;
    }
    await _persist(item.kind);
    notifyListeners();
  }

  Future<void> remove(FavoriteItem item) async {
    await init();
    final map = item.kind == FavoriteKind.team ? _teams : _competitions;
    if (map.remove(item.id) != null) {
      await _persist(item.kind);
      notifyListeners();
    }
  }

  Future<void> _persist(FavoriteKind kind) async {
    if (_prefs == null) return;
    _changes++;
    final map = kind == FavoriteKind.team ? _teams : _competitions;
    final key = kind == FavoriteKind.team ? _teamsKey : _competitionsKey;
    await _prefs!
        .setStringList(key, map.values.map((e) => jsonEncode(e.toJson())).toList());
    await _prefs!.setBool(_syncedKey, false);
    unawaited(syncNow());
  }
}
