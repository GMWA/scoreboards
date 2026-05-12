import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl = dotenv.get('API_BASE_URL', fallback: '');
final String wsBaseUrl = dotenv.get('WEB_SOCKET_BASE_URL', fallback: '');

final Map<String, dynamic> urls = {
  'CHAMPIONSHIPS': {
    'ALL': '$baseUrl/championships/',
    'BY_ID': '$baseUrl/championships/#championshipId/',
  },
  'EDITIONS': {
    'ACTIVE': '$baseUrl/championships/editions/',
    'BY_SLUG': '$baseUrl/championships/editions/slug/',
    'RULES': '$baseUrl/edition/#editionId/rules/'
  },
  'STANDINGS': {
    'ALL': '$baseUrl/standings/',
    'CHAMPIONSHIP': '$baseUrl/edition/#editionId/standings/',
  },
  'TEAMS': {
    'ALL': '$baseUrl/teams/',
    'BY_EDITION': '$baseUrl/edition/#editionId/teams/',
    'BY_CHAMPIONSHIP_YEAR':
        '$baseUrl/championships/#championshipId/edition/#year/teams/',
    'BY_ID': '$baseUrl/teams/#teamId/',
    'BY_SLUG': '$baseUrl/teams/slug/',
    'STATS_BY_EDITION': '$baseUrl/teams/stats/edition/#editionId/',
    'HIGHLIGHT_BY_SLUG': '$baseUrl/teams/highlights/',
  },
  'PLAYERS': {
    'ALL': '$baseUrl/players/',
    'BY_SLUG': '$baseUrl/players/slug/',
    'BY_TEAM': '$baseUrl/teams/#teamId/players/',
    'STATS': '$baseUrl/players/stats/edition/#editionId/',
    'STATS_BY_EDITION': '$baseUrl/players/stats/edition/#editionId/',
    'STATS_BY_TEAM': '$baseUrl/players/stats/team/#teamId/',
    'STATS_BY_PLAYER': '$baseUrl/players/stats/player/#playerId/',
    'CONTRACT_BY_PLAYER': '$baseUrl/contrats/player/#playerId/',
    'TRANSFER_BY_PLAYER': '$baseUrl/transfers/player/#playerId/',
    'PLAYER_TEAM_HISTORY': '$baseUrl/players/#playerId/teams-history/'
  },
  'MATCHS': {
    'ALL': '$baseUrl/matchs/',
    'BY_ID': '$baseUrl/matchs/#matchId/',
    'BY_SLUG': '$baseUrl/matchs/slug/',
    'LIVE': '$baseUrl/matchs/live/',
    'BY_DAY': '$baseUrl/matchs/day/?date=#date',
    'BY_EDITION': '$baseUrl/matchs/edition/#editionId/',
    'BY_CHAMPIONSHIP_EDITION':
        '$baseUrl/matchs/championship/#championshipId/edition/#editionId/',
    'SUBTITUTIONS': '$baseUrl/matchs/#matchId/substitutions/',
  },
  'DEVICES': {
    'REGISTER': '$baseUrl/devices/',
  },
  'NOTIFICATIONS': {
    'WEBSOCKET': '$wsBaseUrl/ws/notifications/#deviceId/',
  },
};
