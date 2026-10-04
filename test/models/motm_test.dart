import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/models/motm.dart';

void main() {
  final candidateJson = {
    "player": {
      "id": 50,
      "slug": "john-doe",
      "firstname": "John",
      "lastname": "Doe",
      "avatar": null,
      "jersey_number": 9,
    },
    "team": {
      "id": 10,
      "slug": "team-a",
      "name": "Team A",
      "logo": null,
      "stadium": null,
      "country": "England",
    },
    "is_starting": true,
    "is_captain": false,
    "position": "forward",
  };

  group('MotmWindow', () {
    test('fromJson parses all fields', () {
      final window = MotmWindow.fromJson({
        "is_open": true,
        "opens_at": "2026-10-04T12:00:00Z",
        "closes_at": "2026-10-04T18:00:00Z",
        "has_closed": false,
      });

      expect(window.isOpen, true);
      expect(window.hasClosed, false);
    });
  });

  group('MotmCandidate', () {
    test('fromJson parses nested player and team', () {
      final candidate = MotmCandidate.fromJson(candidateJson);

      expect(candidate.player.firstname, "John");
      expect(candidate.player.lastname, "Doe");
      expect(candidate.team.name, "Team A");
      expect(candidate.isStarting, true);
      expect(candidate.isCaptain, false);
      expect(candidate.position, "forward");
    });
  });

  group('MotmTallyEntry', () {
    test('fromJson parses player and votes', () {
      final entry = MotmTallyEntry.fromJson({
        "player": candidateJson["player"],
        "votes": 7,
      });

      expect(entry.player.id, 50);
      expect(entry.votes, 7);
    });
  });

  group('MotmVote', () {
    test('fromJson parses player and updated_at', () {
      final vote = MotmVote.fromJson({
        "player": candidateJson["player"],
        "updated_at": "2026-10-04T13:00:00Z",
      });

      expect(vote.player.id, 50);
      expect(vote.updatedAt, isA<DateTime>());
    });
  });

  group('MotmResult', () {
    test('fromJson parses a winner result', () {
      final result = MotmResult.fromJson({
        "fan_winner": candidateJson["player"],
        "winner_votes": 42,
        "total_votes": 60,
        "is_tie": false,
        "finalized_at": "2026-10-04T20:00:00Z",
      });

      expect(result.fanWinner?.id, 50);
      expect(result.winnerVotes, 42);
      expect(result.totalVotes, 60);
      expect(result.isTie, false);
    });

    test('fromJson handles a null fan_winner (tie)', () {
      final result = MotmResult.fromJson({
        "fan_winner": null,
        "winner_votes": 0,
        "total_votes": 10,
        "is_tie": true,
        "finalized_at": "2026-10-04T20:00:00Z",
      });

      expect(result.fanWinner, isNull);
      expect(result.isTie, true);
    });
  });

  group('MotmSummary', () {
    test('fromJson parses the full payload', () {
      final summary = MotmSummary.fromJson({
        "window": {
          "is_open": true,
          "opens_at": "2026-10-04T12:00:00Z",
          "closes_at": "2026-10-04T18:00:00Z",
          "has_closed": false,
        },
        "candidates": [candidateJson],
        "tally": [
          {"player": candidateJson["player"], "votes": 5},
        ],
        "total_votes": 5,
        "your_vote": {
          "player": candidateJson["player"],
          "updated_at": "2026-10-04T13:00:00Z",
        },
        "result": null,
      });

      expect(summary.window.isOpen, true);
      expect(summary.candidates, hasLength(1));
      expect(summary.tally, hasLength(1));
      expect(summary.totalVotes, 5);
      expect(summary.yourVote?.player.id, 50);
      expect(summary.result, isNull);
      expect(summary.votesFor(50), 5);
      expect(summary.votesFor(999), 0);
    });

    test('fromJson handles missing optional fields and empty lists', () {
      final summary = MotmSummary.fromJson({
        "window": {
          "is_open": false,
          "opens_at": "2026-10-04T12:00:00Z",
          "closes_at": "2026-10-04T18:00:00Z",
          "has_closed": true,
        },
        "candidates": [],
        "tally": [],
        "total_votes": 0,
        "your_vote": null,
        "result": null,
      });

      expect(summary.candidates, isEmpty);
      expect(summary.tally, isEmpty);
      expect(summary.yourVote, isNull);
      expect(summary.votesFor(1), 0);
    });
  });
}
