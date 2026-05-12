import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/goal.dart';
import 'package:scoreboards/enums/goals.dart';

void main() {
  group('Goal model', () {
    test('fromJson should create a valid Goal object with scorer and assist', () {
      final json = {
        'id': 100,
        'match': 55,
        'team': {'id': 10, 'slug': 'team-b', 'name': 'Team B'},
        'minute': 42,
        'stoppage_minute': 1,
        'is_csc': false,
        'is_penalty': true,
        'status': 'valid',
        'goal_type': 'penalty',
        'scorer': {
          'id': 7,
          'slug': 'samuel-etoo',
          'firstname': 'Samuel',
          'lastname': 'Eto\'o',
          'logo': 'eto.png',
          'jersey_number': 9,
        },
        'assister': {
          'id': 8,
          'slug': 'lionel-messi',
          'firstname': 'Lionel',
          'lastname': 'Messi',
          'logo': 'messi.png',
          'jersey_number': 10,
        },
      };

      final goal = Goal.fromJson(json);

      expect(goal.id, 100);
      expect(goal.matchId, 55);
      expect(goal.minute, 42);
      expect(goal.stoppageMinute, 1);
      expect(goal.isOwnGoal, false);
      expect(goal.isPenalty, true);
      expect(goal.status, GoalStatus.valid);
      expect(goal.goalType, GoalType.penalty);
      expect(goal.isValid, true);

      expect(goal.scorer?.firstname, 'Samuel');
      expect(goal.assist?.firstname, 'Lionel');
    });

    test('fromJson should handle null scorer and assist and use defaults', () {
      final json = {
        'id': 101,
        'match': 56,
        'team': {'id': 11, 'slug': 'team-a', 'name': 'Team A'},
        'minute': 10,
        // stoppage_minute missing to test default value
        'is_csc': true,
        'is_penalty': false,
        'scorer': null,
        'assister': null,
      };

      final goal = Goal.fromJson(json);

      expect(goal.stoppageMinute, 0);
      expect(goal.status, GoalStatus.valid);
      expect(goal.scorer, isNull);
      expect(goal.assist, isNull);
    });

    test('fromJson should handle Penalty Shootout goals (null minute)', () {
      final json = {
        'id': 105,
        'match': 60,
        'team': {'id': 10, 'slug': 'team-b', 'name': 'Team B'},
        'minute': 12,
        'stoppage_minute': 0,
        'is_csc': false,
        'is_penalty': false,
        'status': 'valid',
        'goal_type': 'pso',
        'shootout_order': 3,
        'scorer': {
          'id': 9,
          'slug': 'harry-kane',
          'firstname': 'Harry',
          'lastname': 'Kane'
        },
      };

      final goal = Goal.fromJson(json);

      expect(goal.minute, 12);
      expect(goal.goalType, GoalType.penaltyShootout);
      expect(goal.status, GoalStatus.valid);
      expect(goal.shootoutOrder, 3);
      expect(goal.displayTime, "PSO");
    });
  });
}