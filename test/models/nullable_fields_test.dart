import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/disciplinary_card.dart';
import 'package:scoreboards/models/goal.dart';
import 'package:scoreboards/models/player.dart';
import 'package:scoreboards/models/stadium.dart';
import 'package:scoreboards/models/team.dart';

// Each fixture sets to null the fields the backend declares as nullable,
// so a schema/model mismatch fails here instead of crashing a whole screen.
void main() {
  const team = {'id': 10, 'slug': 'team-a', 'name': 'Team A'};

  test('PlayerLookup tolerates null names', () {
    final p = PlayerLookup.fromJson(
        {'id': 1, 'slug': 'p', 'firstname': null, 'lastname': null});

    expect(p.firstname, '');
    expect(p.lastname, '');
  });

  test('Player tolerates null optional profile fields', () {
    final p = Player.fromJson({
      'id': 1,
      'slug': 'p',
      'firstname': null,
      'lastname': 'Doe',
      'position': 'forward',
      'nationality': null,
      'date_of_birth': null,
      'jersey_number': null,
      'matricule': null,
    });

    expect(p.firstname, '');
    expect(p.nationality, isNull);
    expect(p.dateOfBirth, isNull);
    expect(p.jerseyNumber, isNull);
    expect(p.matricule, isNull);
  });

  test('Goal tolerates a null minute and null scorer names', () {
    final g = Goal.fromJson({
      'id': 1,
      'match': 5,
      'team': team,
      'minute': null,
      'goal_type': 'pso',
      'status': 'valid',
      'scorer': {'id': 7, 'slug': 's', 'firstname': null, 'lastname': null},
    });

    expect(g.minute, 0);
    expect(g.scorer!.firstname, '');
  });

  test('DisciplinaryCard tolerates a null minute', () {
    final c = DisciplinaryCard.fromJson({
      'id': 1,
      'card_type': 'yellow',
      'minute': null,
      'team': team,
      'is_second_yellow': false,
    });

    expect(c.minute, 0);
  });

  test('Stadium tolerates null city, country and capacity', () {
    final s = Stadium.fromJson({
      'id': 1,
      'name': 'Arena',
      'slug': 'arena',
      'city': null,
      'country': null,
      'capacity': null,
      'is_opened': true,
    });

    expect(s.city, '');
    expect(s.country, '');
    expect(s.capacity, isNull);
  });

  test('Team tolerates a null coach', () {
    final t = Team.fromJson({
      'id': 1,
      'slug': 'team-a',
      'name': 'Team A',
      'team_type': 'club',
      'coach': null,
    });

    expect(t.coach, isNull);
  });

  test('PlayerTeam tolerates null names and jersey number', () {
    final p = PlayerTeam.fromJson({
      'id': 1,
      'slug': 'p',
      'firstname': null,
      'lastname': null,
      'jersey_number': null,
    });

    expect(p.firstname, '');
    expect(p.jerseyNumber, isNull);
  });
}
