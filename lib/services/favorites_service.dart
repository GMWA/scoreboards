import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoreboards/models/favorite_item.dart';

/// Local, device-only "follow" store for teams and competitions.
///
/// This is the mechanism the redesign concept calls "Favorites" — one
/// follow toggle, usable from a team card, an edition card, a match card,
/// or a detail screen header, that feeds:
///  - the "Following" row on the Scores screen
///  - the Favorites management list in Settings
///  - (future) which teams/competitions notification prefs apply to
///
/// Backed by shared_preferences (already a dependency) rather than a
/// backend endpoint, since favorites don't need to sync across devices for
/// this to be useful, and it works fully offline.
class FavoritesService extends ChangeNotifier {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  static const _teamsKey = 'favorite_teams_v1';
  static const _competitionsKey = 'favorite_competitions_v1';

  SharedPreferences? _prefs;
  final Map<int, FavoriteItem> _teams = {};
  final Map<int, FavoriteItem> _competitions = {};
  bool _loaded = false;

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
    final map = kind == FavoriteKind.team ? _teams : _competitions;
    final key = kind == FavoriteKind.team ? _teamsKey : _competitionsKey;
    await _prefs!
        .setStringList(key, map.values.map((e) => jsonEncode(e.toJson())).toList());
  }
}
