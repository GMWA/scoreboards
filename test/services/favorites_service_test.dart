import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoreboards/models/favorite_item.dart';
import 'package:scoreboards/services/favorites_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const team = FavoriteItem(
    id: 1,
    slug: 'team-a',
    name: 'Team A',
    logo: 'team-a.png',
    kind: FavoriteKind.team,
  );
  const otherTeam = FavoriteItem(
    id: 2,
    slug: 'team-b',
    name: 'Alpha Team',
    kind: FavoriteKind.team,
  );
  const competition = FavoriteItem(
    id: 10,
    slug: 'league-a',
    name: 'League A',
    kind: FavoriteKind.competition,
  );

  final service = FavoritesService.instance;
  // What each sync sent: [teams, editions].
  late List<List<List<int>>> synced;

  setUp(() {
    service.resetForTesting();
    synced = [];
    service.syncer = ({required teams, required editions}) async {
      synced.add([teams, editions]);
    };
  });

  Future<bool?> syncedFlag() async =>
      (await SharedPreferences.getInstance()).getBool('favorites_synced_v1');

  group('FavoritesService', () {
    test('starts with no favorites when prefs are empty', () async {
      SharedPreferences.setMockInitialValues({});

      await service.init();

      expect(service.hasAnyFavorites, isFalse);
      expect(service.followedTeams, isEmpty);
      expect(service.followedCompetitions, isEmpty);
    });

    test('init loads favorites previously persisted to prefs', () async {
      SharedPreferences.setMockInitialValues({
        'favorite_teams_v1': [jsonEncode(team.toJson())],
        'favorite_competitions_v1': [jsonEncode(competition.toJson())],
      });

      await service.init();

      expect(service.isTeamFollowed(team.id), isTrue);
      expect(service.isCompetitionFollowed(competition.id), isTrue);
      expect(service.isFollowed(team), isTrue);
      expect(service.isFollowed(competition), isTrue);
    });

    test('toggle adds then removes a favorite, persisting each change',
        () async {
      SharedPreferences.setMockInitialValues({});

      await service.toggle(team);
      expect(service.isFollowed(team), isTrue);

      var prefs = await SharedPreferences.getInstance();
      var stored = prefs.getStringList('favorite_teams_v1') ?? [];
      expect(stored.map((raw) => FavoriteItem.fromJson(jsonDecode(raw)).id),
          [team.id]);

      await service.toggle(team);
      expect(service.isFollowed(team), isFalse);

      prefs = await SharedPreferences.getInstance();
      stored = prefs.getStringList('favorite_teams_v1') ?? [];
      expect(stored, isEmpty);
    });

    test('keeps teams and competitions independent', () async {
      SharedPreferences.setMockInitialValues({});

      await service.toggle(team);
      await service.toggle(competition);

      expect(service.followedTeams, [team]);
      expect(service.followedCompetitions, [competition]);
      expect(service.allFollowed, [team, competition]);
    });

    test('followedTeams is sorted alphabetically by name', () async {
      SharedPreferences.setMockInitialValues({});

      await service.toggle(team); // "Team A"
      await service.toggle(otherTeam); // "Alpha Team"

      expect(service.followedTeams.map((t) => t.name), [
        otherTeam.name,
        team.name,
      ]);
    });

    test('remove is a no-op when the item is not followed', () async {
      SharedPreferences.setMockInitialValues({});
      await service.init();

      var notified = false;
      service.addListener(() => notified = true);

      await service.remove(team);

      expect(service.hasAnyFavorites, isFalse);
      expect(notified, isFalse);
    });

    test('remove drops a followed item and persists the change', () async {
      SharedPreferences.setMockInitialValues({});
      await service.toggle(team);

      await service.remove(team);

      expect(service.isFollowed(team), isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('favorite_teams_v1'), isEmpty);
    });
  });

  group('FavoritesService backend sync', () {
    test('a change sends the complete favorites', () async {
      SharedPreferences.setMockInitialValues({});

      await service.toggle(team);
      await service.toggle(competition);
      await service.syncNow();

      expect(synced.last, [[team.id], [competition.id]]);
      expect(await syncedFlag(), isTrue);
    });

    test('removing the last favorite syncs empty lists', () async {
      SharedPreferences.setMockInitialValues({});
      await service.toggle(team);

      await service.remove(team);
      await service.syncNow();

      expect(synced.last, [<int>[], <int>[]]);
    });

    test('a failed sync is retried on the next launch', () async {
      SharedPreferences.setMockInitialValues({});
      service.syncer = ({required teams, required editions}) async {
        throw Exception('offline');
      };

      await service.toggle(team);
      await service.syncNow();
      expect(await syncedFlag(), isFalse);

      // Next launch: prefs survive, in-memory state doesn't.
      service.resetForTesting();
      service.syncer = ({required teams, required editions}) async {
        synced.add([teams, editions]);
      };
      await service.init();
      await service.syncNow();

      expect(synced.first, [[team.id], <int>[]]);
      expect(await syncedFlag(), isTrue);
    });

    test('favorites saved before syncing existed are sent on launch',
        () async {
      SharedPreferences.setMockInitialValues({
        'favorite_teams_v1': [jsonEncode(team.toJson())],
      });

      await service.init();
      await service.syncNow();

      expect(synced.first, [[team.id], <int>[]]);
    });

    test('a fresh install with no favorites sends nothing', () async {
      SharedPreferences.setMockInitialValues({});

      await service.init();
      await Future<void>.delayed(Duration.zero);

      expect(synced, isEmpty);
    });

    test('an up-to-date device sends nothing on launch', () async {
      SharedPreferences.setMockInitialValues({
        'favorite_teams_v1': [jsonEncode(team.toJson())],
        'favorites_synced_v1': true,
      });

      await service.init();
      await Future<void>.delayed(Duration.zero);

      expect(synced, isEmpty);
    });

    test('a change during a sync is sent once that sync finishes', () async {
      SharedPreferences.setMockInitialValues({});
      await service.init();
      final firstRequest = Completer<void>();
      service.syncer = ({required teams, required editions}) async {
        synced.add([teams, editions]);
        if (synced.length == 1) await firstRequest.future;
      };

      await service.toggle(team); // starts a sync that hangs
      await service.toggle(otherTeam);
      await service.toggle(competition);
      expect(synced, hasLength(1));

      firstRequest.complete();
      await service.syncNow();

      expect(synced.first, [[team.id], <int>[]]);
      // The changes made meanwhile go out together, in one more request.
      expect(synced[1], [[team.id, otherTeam.id], [competition.id]]);
      expect(await syncedFlag(), isTrue);
    });
  });
}
