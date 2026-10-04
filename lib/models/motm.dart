import 'package:scoreboards/models/match_team.dart';
import 'package:scoreboards/models/player.dart';

class MotmWindow {
  final bool isOpen;
  final DateTime opensAt;
  final DateTime closesAt;
  final bool hasClosed;

  MotmWindow({
    required this.isOpen,
    required this.opensAt,
    required this.closesAt,
    required this.hasClosed,
  });

  factory MotmWindow.fromJson(Map<String, dynamic> json) {
    return MotmWindow(
      isOpen: json['is_open'],
      opensAt: DateTime.parse(json['opens_at']).toLocal(),
      closesAt: DateTime.parse(json['closes_at']).toLocal(),
      hasClosed: json['has_closed'],
    );
  }
}

class MotmCandidate {
  final PlayerLookup player;
  final MatchTeam team;
  final bool isStarting;
  final bool isCaptain;
  final String? position;

  MotmCandidate({
    required this.player,
    required this.team,
    required this.isStarting,
    required this.isCaptain,
    this.position,
  });

  factory MotmCandidate.fromJson(Map<String, dynamic> json) {
    return MotmCandidate(
      player: PlayerLookup.fromJson(json['player']),
      team: MatchTeam.fromJson(json['team']),
      isStarting: json['is_starting'],
      isCaptain: json['is_captain'],
      position: json['position'],
    );
  }
}

class MotmTallyEntry {
  final PlayerLookup player;
  final int votes;

  MotmTallyEntry({required this.player, required this.votes});

  factory MotmTallyEntry.fromJson(Map<String, dynamic> json) {
    return MotmTallyEntry(
      player: PlayerLookup.fromJson(json['player']),
      votes: json['votes'],
    );
  }
}

class MotmVote {
  final PlayerLookup player;
  final DateTime updatedAt;

  MotmVote({required this.player, required this.updatedAt});

  factory MotmVote.fromJson(Map<String, dynamic> json) {
    return MotmVote(
      player: PlayerLookup.fromJson(json['player']),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
    );
  }
}

class MotmResult {
  final PlayerLookup? fanWinner;
  final int winnerVotes;
  final int totalVotes;
  final bool isTie;
  final DateTime finalizedAt;

  MotmResult({
    this.fanWinner,
    required this.winnerVotes,
    required this.totalVotes,
    required this.isTie,
    required this.finalizedAt,
  });

  factory MotmResult.fromJson(Map<String, dynamic> json) {
    return MotmResult(
      fanWinner: json['fan_winner'] != null
          ? PlayerLookup.fromJson(json['fan_winner'])
          : null,
      winnerVotes: json['winner_votes'],
      totalVotes: json['total_votes'],
      isTie: json['is_tie'],
      finalizedAt: DateTime.parse(json['finalized_at']).toLocal(),
    );
  }
}

class MotmSummary {
  final MotmWindow window;
  final List<MotmCandidate> candidates;
  final List<MotmTallyEntry> tally;
  final int totalVotes;
  final MotmVote? yourVote;
  final MotmResult? result;

  MotmSummary({
    required this.window,
    required this.candidates,
    required this.tally,
    required this.totalVotes,
    this.yourVote,
    this.result,
  });

  factory MotmSummary.fromJson(Map<String, dynamic> json) {
    return MotmSummary(
      window: MotmWindow.fromJson(json['window']),
      candidates: (json['candidates'] as List? ?? [])
          .map((c) => MotmCandidate.fromJson(c))
          .toList(),
      tally: (json['tally'] as List? ?? [])
          .map((t) => MotmTallyEntry.fromJson(t))
          .toList(),
      totalVotes: json['total_votes'],
      yourVote:
          json['your_vote'] != null ? MotmVote.fromJson(json['your_vote']) : null,
      result: json['result'] != null ? MotmResult.fromJson(json['result']) : null,
    );
  }

  /// Vote count for [playerId], or 0 if nobody has voted for them yet.
  int votesFor(int playerId) {
    return tally
        .firstWhere(
          (t) => t.player.id == playerId,
          orElse: () => MotmTallyEntry(
            player: PlayerLookup(id: playerId, slug: '', firstname: '', lastname: ''),
            votes: 0,
          ),
        )
        .votes;
  }
}
