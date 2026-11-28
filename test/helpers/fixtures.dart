/// JSON as the backend sends it, for repository and screen tests.
library;

Map<String, dynamic> teamRef(int id, String name) =>
    {'id': id, 'slug': 'team-$id', 'name': name};

Map<String, dynamic> teamJson(int id, String name) => {
      ...teamRef(id, name),
      'team_type': 'club',
      'coach': 'Coach',
    };

Map<String, dynamic> editionJson({
  int id = 1,
  String slug = 'cup-2026',
  String label = 'Cup 2026',
  String? competitionType,
}) =>
    {
      'id': id,
      'slug': slug,
      'year': '2026',
      'label': label,
      'start_date': '2026-01-01',
      'end_date': '2026-12-31',
      'is_current': true,
      if (competitionType != null) 'competition_type': competitionType,
      'championship': {'id': 1, 'name': 'Cup', 'country': 'Cameroun'},
    };

Map<String, dynamic> matchJson(
  int id, {
  DateTime? kickoff,
  String status = 'planned',
  Map<String, dynamic>? edition,
  Map<String, dynamic>? home,
  Map<String, dynamic>? away,
}) =>
    {
      'id': id,
      'slug': 'match-$id',
      'date':
          (kickoff ?? DateTime.utc(2026, 10, 4, 18)).toUtc().toIso8601String(),
      'location': 'Stadium',
      'round': '1',
      'status': status,
      'edition': edition ?? editionJson(),
      'home_team': home ?? teamRef(1, 'Home FC'),
      'away_team': away ?? teamRef(2, 'Away FC'),
      'score_final_home': 0,
      'score_final_away': 0,
    };

Map<String, dynamic> playerRef(int id, String lastname) => {
      'id': id,
      'slug': 'p$id',
      'firstname': 'Test',
      'lastname': lastname,
      'jersey_number': id,
    };

Map<String, dynamic> playerJson(int id, String lastname) => {
      ...playerRef(id, lastname),
      'position': 'forward',
      'nationality': 'Cameroun',
      'date_of_birth': '2000-01-01',
    };

Map<String, dynamic> playerStatsJson(int playerId, String lastname,
        {int goals = 0, Map<String, dynamic>? team}) =>
    {
      'player': playerRef(playerId, lastname),
      'team': team ?? teamRef(1, 'Home FC'),
      'goals': goals,
      'assists': 0,
      'yellow_cards': 0,
      'red_cards': 0,
    };

Map<String, dynamic> standingJson(int teamId, String name,
        {required int points, int goalsFor = 0, int goalsAgainst = 0}) =>
    {
      'id': teamId,
      'participation': {
        'id': teamId,
        'team': teamRef(teamId, name),
        'group': null
      },
      'points': points,
      'matches_played': 10,
      'wins': 0,
      'draws': 0,
      'losses': 0,
      'goals_for': goalsFor,
      'goals_against': goalsAgainst,
    };
