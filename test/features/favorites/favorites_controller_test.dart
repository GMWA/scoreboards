import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoreboards/core/providers.dart';
import 'package:scoreboards/features/favorites/favorite_item.dart';
import 'package:scoreboards/features/favorites/favorites_controller.dart';
import 'package:scoreboards/features/favorites/favorites_repository.dart';

import '../../helpers/harness.dart';

/// Records what each sync sent, as [teams, editions].
class FakeFavoritesRepository implements FavoritesRepository {
  final synced = <List<List<int>>>[];
  Future<void> Function()? onSync;

  @override
  Future<void> sync({
    required List<int> teams,
    required List<int> editions,
  }) async {
    synced.add([teams, editions]);
    await onSync?.call();
  }
}

const team = FavoriteItem(
  id: 1,
  slug: 'team-a',
  name: 'Team A',
  logo: 'team-a.png',
  kind: FavoriteKind.team,
);
const otherTeam = FavoriteItem(
    id: 2, slug: 'team-b', name: 'Alpha Team', kind: FavoriteKind.team);
const competition = FavoriteItem(
    id: 10, slug: 'league-a', name: 'League A', kind: FavoriteKind.competition);

void main() {
  late SharedPreferences prefs;
  late FakeFavoritesRepository backend;

  /// Starts the app with the preferences as they are (a new launch).
  ProviderContainer launch() {
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      favoritesRepositoryProvider.overrideWithValue(backend),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  Future<void> install([Map<String, Object> values = const {}]) async {
    prefs = await testPrefs(values);
    backend = FakeFavoritesRepository();
  }

  bool? syncedFlag() => prefs.getBool('favorites_synced_v1');

  group('following', () {
    setUp(install);

    test('starts with no favorites', () {
      final favorites = launch().read(favoritesProvider);

      expect(favorites.isEmpty, isTrue);
      expect(favorites.followedTeams, isEmpty);
      expect(favorites.followedCompetitions, isEmpty);
    });

    test('loads the favorites stored on the device', () async {
      await install({
        'favorite_teams_v1': [jsonEncode(team.toJson())],
        'favorite_competitions_v1': [jsonEncode(competition.toJson())],
      });

      final favorites = launch().read(favoritesProvider);

      expect(favorites.isTeamFollowed(team.id), isTrue);
      expect(favorites.isCompetitionFollowed(competition.id), isTrue);
      expect(favorites.isFollowed(team), isTrue);
      expect(favorites.isFollowed(competition), isTrue);
    });

    test('toggle follows then unfollows, storing each change', () async {
      final container = launch();
      final controller = container.read(favoritesProvider.notifier);

      await controller.toggle(team);
      expect(container.read(favoritesProvider).isFollowed(team), isTrue);
      expect(
        prefs
            .getStringList('favorite_teams_v1')!
            .map((raw) => FavoriteItem.fromJson(jsonDecode(raw)).id),
        [team.id],
      );

      await controller.toggle(team);
      expect(container.read(favoritesProvider).isFollowed(team), isFalse);
      expect(prefs.getStringList('favorite_teams_v1'), isEmpty);
    });

    test('keeps teams and competitions apart, teams sorted by name', () async {
      final container = launch();
      final controller = container.read(favoritesProvider.notifier);

      await controller.toggle(team); // "Team A"
      await controller.toggle(otherTeam); // "Alpha Team"
      await controller.toggle(competition);

      final favorites = container.read(favoritesProvider);
      expect(favorites.followedTeams, [otherTeam, team]);
      expect(favorites.followedCompetitions, [competition]);
      expect(favorites.allFollowed, [otherTeam, team, competition]);
    });

    test('remove does nothing when the item is not followed', () async {
      final container = launch();
      final before = container.read(favoritesProvider);

      await container.read(favoritesProvider.notifier).remove(team);

      expect(identical(container.read(favoritesProvider), before), isTrue);
      expect(backend.synced, isEmpty);
    });

    test('remove unfollows and stores the change', () async {
      final container = launch();
      final controller = container.read(favoritesProvider.notifier);
      await controller.toggle(team);

      await controller.remove(team);

      expect(container.read(favoritesProvider).isFollowed(team), isFalse);
      expect(prefs.getStringList('favorite_teams_v1'), isEmpty);
    });
  });

  group('backend sync', () {
    setUp(install);

    test('a change sends the complete favorites', () async {
      final controller = launch().read(favoritesProvider.notifier);

      await controller.toggle(team);
      await controller.toggle(competition);
      await controller.syncNow();

      expect(backend.synced.last, [
        [team.id],
        [competition.id]
      ]);
      expect(syncedFlag(), isTrue);
    });

    test('removing the last favorite sends empty lists', () async {
      final controller = launch().read(favoritesProvider.notifier);
      await controller.toggle(team);

      await controller.remove(team);
      await controller.syncNow();

      expect(backend.synced.last, [<int>[], <int>[]]);
    });

    test('a failed sync is sent again at the next launch', () async {
      backend.onSync = () async => throw Exception('offline');
      final controller = launch().read(favoritesProvider.notifier);

      await controller.toggle(team);
      await controller.syncNow();
      expect(syncedFlag(), isFalse);

      backend = FakeFavoritesRepository();
      launch().read(favoritesProvider);
      await Future<void>.delayed(Duration.zero);
      await pumpEventQueue();

      expect(backend.synced.first, [
        [team.id],
        <int>[]
      ]);
      expect(syncedFlag(), isTrue);
    });

    test('favorites saved before syncing existed are sent at launch', () async {
      await install({
        'favorite_teams_v1': [jsonEncode(team.toJson())],
      });

      launch().read(favoritesProvider);
      await pumpEventQueue();

      expect(backend.synced.first, [
        [team.id],
        <int>[]
      ]);
    });

    test('a fresh install with no favorites sends nothing', () async {
      launch().read(favoritesProvider);
      await pumpEventQueue();

      expect(backend.synced, isEmpty);
    });

    test('an up-to-date device sends nothing at launch', () async {
      await install({
        'favorite_teams_v1': [jsonEncode(team.toJson())],
        'favorites_synced_v1': true,
      });

      launch().read(favoritesProvider);
      await pumpEventQueue();

      expect(backend.synced, isEmpty);
    });

    test('a change during a sync is sent once that sync finishes', () async {
      final controller = launch().read(favoritesProvider.notifier);
      final firstRequest = Completer<void>();
      backend.onSync = () async {
        if (backend.synced.length == 1) await firstRequest.future;
      };

      await controller.toggle(team);
      await pumpEventQueue(); // its sync starts, and hangs
      await controller.toggle(otherTeam);
      await controller.toggle(competition);
      expect(backend.synced, hasLength(1));

      firstRequest.complete();
      await controller.syncNow();

      expect(backend.synced.first, [
        [team.id],
        <int>[]
      ]);
      // The changes made meanwhile go out together, in one more request.
      expect(backend.synced[1], [
        [team.id, otherTeam.id],
        [competition.id]
      ]);
      expect(syncedFlag(), isTrue);
    });
  });
}
