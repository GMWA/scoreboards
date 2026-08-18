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

  setUp(() {
    service.resetForTesting();
  });

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
}
