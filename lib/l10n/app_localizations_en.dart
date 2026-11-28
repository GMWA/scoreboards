// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navScores => 'Scores';

  @override
  String get navLeagues => 'Leagues';

  @override
  String get navTeams => 'Teams';

  @override
  String get navBlogs => 'Blogs';

  @override
  String get navSettings => 'Settings';

  @override
  String get retry => 'Retry';

  @override
  String get connectionError => 'Connection Error';

  @override
  String get loadError => 'An error occurred while loading!';

  @override
  String get liveBadge => 'LIVE';

  @override
  String get fullTimeShort => 'FT';

  @override
  String get resultUnknown => 'RESULT UNKNOWN';

  @override
  String penaltiesScore(String home, String away) {
    return '($home - $away PEN)';
  }

  @override
  String penaltiesScoreShort(String home, String away) {
    return '($home-$away PEN)';
  }

  @override
  String get filterAll => 'All';

  @override
  String get filterLive => '● Live';

  @override
  String get filterUpcoming => 'Upcoming';

  @override
  String get filterFinished => 'Finished';

  @override
  String get noMatchesInView => 'No matches in this view.';

  @override
  String get failedToLoadMatches => 'Failed to load matches.';

  @override
  String get followTeam => 'Follow a team';

  @override
  String roundMatchday(String number) {
    return 'Matchday $number';
  }

  @override
  String get roundFinal => 'Final';

  @override
  String get roundSemiFinal => 'Semi-final';

  @override
  String get roundQuarterFinal => 'Quarter-final';

  @override
  String get roundThirdPlace => 'Third place';

  @override
  String get roundOf16 => 'Round of 16';

  @override
  String get roundOf32 => 'Round of 32';

  @override
  String get matchNotFound => 'Could not find match details.';

  @override
  String get matchCenter => 'MATCH CENTER';

  @override
  String get shareMatch => 'Share match';

  @override
  String get tabTimeline => 'Timeline';

  @override
  String get tabStats => 'Stats';

  @override
  String get tabLineups => 'Lineups';

  @override
  String get tabMotm => 'MOTM';

  @override
  String get statusLive => 'Live';

  @override
  String get statusFullTime => 'Full Time';

  @override
  String get statusScheduled => 'Scheduled';

  @override
  String get statusPostponed => 'Postponed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusAbandoned => 'Abandoned';

  @override
  String get statusAwarded => 'Awarded';

  @override
  String get noMatchEvents => 'No match events yet';

  @override
  String get unknownPlayer => 'Unknown Player';

  @override
  String get ownGoal => 'Own Goal';

  @override
  String assistBy(String name) {
    return 'Asst: $name';
  }

  @override
  String get secondYellow => 'Second yellow';

  @override
  String get staffHeadCoach => 'Head coach';

  @override
  String get staffAssistantCoach => 'Assistant coach';

  @override
  String get staffOther => 'Staff';

  @override
  String get lineupsNotPublished => 'Lineups have not been published yet.';

  @override
  String get substitutes => 'SUBSTITUTES';

  @override
  String get statPossession => 'Possession';

  @override
  String get statShots => 'Shots';

  @override
  String get statShotsOnTarget => 'Shots on target';

  @override
  String get statCorners => 'Corners';

  @override
  String get statFouls => 'Fouls';

  @override
  String get statOffsides => 'Offsides';

  @override
  String get statSaves => 'Saves';

  @override
  String get statYellowCards => 'Yellow cards';

  @override
  String get statRedCards => 'Red cards';

  @override
  String statsSource(String note) {
    return 'Source: $note';
  }

  @override
  String statComparison(String label, String home, String away) {
    return '$label: $home to $away';
  }

  @override
  String get motmVoteFailed => 'Could not record your vote.';

  @override
  String get motmLoadFailed => 'Could not load Man of the Match voting.';

  @override
  String get motmOpensWithLineups =>
      'Man of the Match voting opens once lineups are published.';

  @override
  String get motmTie => 'It\'s a tie!';

  @override
  String motmVotesCast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes cast',
      one: '1 vote cast',
    );
    return '$_temp0';
  }

  @override
  String motmWinner(String name) {
    return '$name won Man of the Match';
  }

  @override
  String motmWinnerVotes(int votes, int total) {
    return '$votes of $total votes';
  }

  @override
  String get motmVotingClosed => 'Voting has closed';

  @override
  String get motmNoVotes => 'No votes were cast';

  @override
  String get motmVoteTitle => 'Vote for Man of the Match';

  @override
  String motmVotingCloses(String date) {
    return 'Voting closes $date';
  }

  @override
  String get motmFinalizing => 'Result is being finalized';

  @override
  String get competitionsTitle => 'Competitions';

  @override
  String get noCompetitions => 'No championships found.';

  @override
  String get liveCompetitions => 'Live Competitions';

  @override
  String get archive => 'Archive';

  @override
  String get competitionLoadFailed => 'Could not load this competition.';

  @override
  String get tabStandings => 'Standings';

  @override
  String get tabTeams => 'Teams';

  @override
  String get tabMatches => 'Matches';

  @override
  String get tabPlayerStats => 'P. Stats';

  @override
  String get matchesLoadFailed => 'Error loading matches';

  @override
  String get noMatchesAvailable => 'No matches available';

  @override
  String get moreMatchesLoadFailed => 'Could not load more matches';

  @override
  String get statsLoadFailed => 'Failed to load stats';

  @override
  String get topScorers => 'TOP GOAL SCORERS';

  @override
  String get showLess => 'SHOW LESS';

  @override
  String get viewFullList => 'VIEW FULL LIST';

  @override
  String get standingsLoadFailed => 'Error loading standings.';

  @override
  String get noStandings => 'No standings available yet.';

  @override
  String get standingsTeam => 'TEAM';

  @override
  String get standingsPoints => 'PTS';

  @override
  String get standingsPlayed => 'P';

  @override
  String get standingsWon => 'W';

  @override
  String get standingsDrawn => 'D';

  @override
  String get standingsLost => 'L';

  @override
  String get standingsGoalDifference => 'GD';

  @override
  String get participatingTeams => 'PARTICIPATING TEAMS';

  @override
  String get teamsLoadFailed => 'Error loading teams';

  @override
  String get noTeamsThisSeason => 'No teams found for this season.';

  @override
  String get searchTeams => 'Search teams';

  @override
  String get noTeamsFound => 'No teams found.';

  @override
  String get teamNotFound => 'Team not found.';

  @override
  String get overview => 'OVERVIEW';

  @override
  String get teamType => 'Team Type';

  @override
  String get homeStadium => 'Home Stadium';

  @override
  String get teamTypeClub => 'Club';

  @override
  String get teamTypeNational => 'National';

  @override
  String get playerProfile => 'Player Profile';

  @override
  String get playerLoadFailed => 'Could not load this player.';

  @override
  String jerseyNumber(String number) {
    return 'No. $number';
  }

  @override
  String playerAge(int age) {
    return 'Age $age';
  }

  @override
  String get playerGoals => 'Goals';

  @override
  String get playerAssists => 'Assists';

  @override
  String get playerYellowCards => 'Yellow Cards';

  @override
  String get playerRedCards => 'Red Cards';

  @override
  String get noSeasonStats => 'No season stats available for this player yet.';

  @override
  String get currentClub => 'Current Club';

  @override
  String clubSince(String date) {
    return 'Since $date';
  }

  @override
  String get positionGoalkeeper => 'Goalkeeper';

  @override
  String get positionDefender => 'Defender';

  @override
  String get positionMidfielder => 'Midfielder';

  @override
  String get positionForward => 'Forward';

  @override
  String get noArticles => 'No articles found.';

  @override
  String get articleNotFound => 'Article not found.';

  @override
  String get linkOpenFailed => 'Could not open this link.';

  @override
  String get shareArticle => 'Share article';

  @override
  String articleViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count views',
      one: '1 view',
    );
    return '$_temp0';
  }

  @override
  String get relatedMatches => 'Related matches';

  @override
  String get favoriteTeams => 'Favorite Teams';

  @override
  String get favoriteCompetitions => 'Favorite Competitions';

  @override
  String get noFavoriteTeams =>
      'You haven\'t followed any teams yet. Tap the star on a team\'s card or profile to follow it.';

  @override
  String get noFavoriteCompetitions =>
      'You haven\'t followed any competitions yet. Tap the star on a competition\'s card or page to follow it.';

  @override
  String get unfollow => 'Unfollow';

  @override
  String followingNotice(String name) {
    return 'You\'ll get notifications for $name. Turn them off in Settings.';
  }

  @override
  String get preferences => 'PREFERENCES';

  @override
  String get manageFollowedTeams => 'Manage your followed squads';

  @override
  String get manageFollowedCompetitions => 'Manage your followed leagues';

  @override
  String followedCount(int count) {
    return '$count followed';
  }

  @override
  String get language => 'Language';

  @override
  String get languagePhone => 'Phone language';

  @override
  String get about => 'About';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutOpenFailed => 'Could not open the About page.';

  @override
  String get notificationsSection => 'NOTIFICATIONS';

  @override
  String get matchNotifications => 'Match Notifications';

  @override
  String get matchNotificationsSubtitle =>
      'For the teams and competitions you follow';

  @override
  String get matchNotificationsHint =>
      'Kick-off reminders, goals and results. Tap the star on a team or competition to follow it.';

  @override
  String get allowNotifications =>
      'Allow notifications for Scoreboards in your phone settings.';
}
