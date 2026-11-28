import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @navScores.
  ///
  /// In en, this message translates to:
  /// **'Scores'**
  String get navScores;

  /// No description provided for @navLeagues.
  ///
  /// In en, this message translates to:
  /// **'Leagues'**
  String get navLeagues;

  /// No description provided for @navTeams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get navTeams;

  /// No description provided for @navBlogs.
  ///
  /// In en, this message translates to:
  /// **'Blogs'**
  String get navBlogs;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get connectionError;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading!'**
  String get loadError;

  /// No description provided for @liveBadge.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveBadge;

  /// No description provided for @fullTimeShort.
  ///
  /// In en, this message translates to:
  /// **'FT'**
  String get fullTimeShort;

  /// No description provided for @resultUnknown.
  ///
  /// In en, this message translates to:
  /// **'RESULT UNKNOWN'**
  String get resultUnknown;

  /// No description provided for @penaltiesScore.
  ///
  /// In en, this message translates to:
  /// **'({home} - {away} PEN)'**
  String penaltiesScore(String home, String away);

  /// No description provided for @penaltiesScoreShort.
  ///
  /// In en, this message translates to:
  /// **'({home}-{away} PEN)'**
  String penaltiesScoreShort(String home, String away);

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterLive.
  ///
  /// In en, this message translates to:
  /// **'● Live'**
  String get filterLive;

  /// No description provided for @filterUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get filterUpcoming;

  /// No description provided for @filterFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get filterFinished;

  /// No description provided for @noMatchesInView.
  ///
  /// In en, this message translates to:
  /// **'No matches in this view.'**
  String get noMatchesInView;

  /// No description provided for @failedToLoadMatches.
  ///
  /// In en, this message translates to:
  /// **'Failed to load matches.'**
  String get failedToLoadMatches;

  /// No description provided for @followTeam.
  ///
  /// In en, this message translates to:
  /// **'Follow a team'**
  String get followTeam;

  /// No description provided for @roundMatchday.
  ///
  /// In en, this message translates to:
  /// **'Matchday {number}'**
  String roundMatchday(String number);

  /// No description provided for @roundFinal.
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get roundFinal;

  /// No description provided for @roundSemiFinal.
  ///
  /// In en, this message translates to:
  /// **'Semi-final'**
  String get roundSemiFinal;

  /// No description provided for @roundQuarterFinal.
  ///
  /// In en, this message translates to:
  /// **'Quarter-final'**
  String get roundQuarterFinal;

  /// No description provided for @roundThirdPlace.
  ///
  /// In en, this message translates to:
  /// **'Third place'**
  String get roundThirdPlace;

  /// No description provided for @roundOf16.
  ///
  /// In en, this message translates to:
  /// **'Round of 16'**
  String get roundOf16;

  /// No description provided for @roundOf32.
  ///
  /// In en, this message translates to:
  /// **'Round of 32'**
  String get roundOf32;

  /// No description provided for @matchNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find match details.'**
  String get matchNotFound;

  /// No description provided for @matchCenter.
  ///
  /// In en, this message translates to:
  /// **'MATCH CENTER'**
  String get matchCenter;

  /// No description provided for @shareMatch.
  ///
  /// In en, this message translates to:
  /// **'Share match'**
  String get shareMatch;

  /// No description provided for @tabTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get tabTimeline;

  /// No description provided for @tabStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get tabStats;

  /// No description provided for @tabLineups.
  ///
  /// In en, this message translates to:
  /// **'Lineups'**
  String get tabLineups;

  /// No description provided for @tabMotm.
  ///
  /// In en, this message translates to:
  /// **'MOTM'**
  String get tabMotm;

  /// No description provided for @statusLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get statusLive;

  /// No description provided for @statusFullTime.
  ///
  /// In en, this message translates to:
  /// **'Full Time'**
  String get statusFullTime;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

  /// No description provided for @statusPostponed.
  ///
  /// In en, this message translates to:
  /// **'Postponed'**
  String get statusPostponed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusAbandoned.
  ///
  /// In en, this message translates to:
  /// **'Abandoned'**
  String get statusAbandoned;

  /// No description provided for @statusAwarded.
  ///
  /// In en, this message translates to:
  /// **'Awarded'**
  String get statusAwarded;

  /// No description provided for @noMatchEvents.
  ///
  /// In en, this message translates to:
  /// **'No match events yet'**
  String get noMatchEvents;

  /// No description provided for @unknownPlayer.
  ///
  /// In en, this message translates to:
  /// **'Unknown Player'**
  String get unknownPlayer;

  /// No description provided for @ownGoal.
  ///
  /// In en, this message translates to:
  /// **'Own Goal'**
  String get ownGoal;

  /// No description provided for @assistBy.
  ///
  /// In en, this message translates to:
  /// **'Asst: {name}'**
  String assistBy(String name);

  /// No description provided for @secondYellow.
  ///
  /// In en, this message translates to:
  /// **'Second yellow'**
  String get secondYellow;

  /// No description provided for @staffHeadCoach.
  ///
  /// In en, this message translates to:
  /// **'Head coach'**
  String get staffHeadCoach;

  /// No description provided for @staffAssistantCoach.
  ///
  /// In en, this message translates to:
  /// **'Assistant coach'**
  String get staffAssistantCoach;

  /// No description provided for @staffOther.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffOther;

  /// No description provided for @lineupsNotPublished.
  ///
  /// In en, this message translates to:
  /// **'Lineups have not been published yet.'**
  String get lineupsNotPublished;

  /// No description provided for @substitutes.
  ///
  /// In en, this message translates to:
  /// **'SUBSTITUTES'**
  String get substitutes;

  /// No description provided for @statPossession.
  ///
  /// In en, this message translates to:
  /// **'Possession'**
  String get statPossession;

  /// No description provided for @statShots.
  ///
  /// In en, this message translates to:
  /// **'Shots'**
  String get statShots;

  /// No description provided for @statShotsOnTarget.
  ///
  /// In en, this message translates to:
  /// **'Shots on target'**
  String get statShotsOnTarget;

  /// No description provided for @statCorners.
  ///
  /// In en, this message translates to:
  /// **'Corners'**
  String get statCorners;

  /// No description provided for @statFouls.
  ///
  /// In en, this message translates to:
  /// **'Fouls'**
  String get statFouls;

  /// No description provided for @statOffsides.
  ///
  /// In en, this message translates to:
  /// **'Offsides'**
  String get statOffsides;

  /// No description provided for @statSaves.
  ///
  /// In en, this message translates to:
  /// **'Saves'**
  String get statSaves;

  /// No description provided for @statYellowCards.
  ///
  /// In en, this message translates to:
  /// **'Yellow cards'**
  String get statYellowCards;

  /// No description provided for @statRedCards.
  ///
  /// In en, this message translates to:
  /// **'Red cards'**
  String get statRedCards;

  /// No description provided for @statsSource.
  ///
  /// In en, this message translates to:
  /// **'Source: {note}'**
  String statsSource(String note);

  /// No description provided for @statComparison.
  ///
  /// In en, this message translates to:
  /// **'{label}: {home} to {away}'**
  String statComparison(String label, String home, String away);

  /// No description provided for @motmVoteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not record your vote.'**
  String get motmVoteFailed;

  /// No description provided for @motmLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load Man of the Match voting.'**
  String get motmLoadFailed;

  /// No description provided for @motmOpensWithLineups.
  ///
  /// In en, this message translates to:
  /// **'Man of the Match voting opens once lineups are published.'**
  String get motmOpensWithLineups;

  /// No description provided for @motmTie.
  ///
  /// In en, this message translates to:
  /// **'It\'s a tie!'**
  String get motmTie;

  /// No description provided for @motmVotesCast.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 vote cast} other{{count} votes cast}}'**
  String motmVotesCast(int count);

  /// No description provided for @motmWinner.
  ///
  /// In en, this message translates to:
  /// **'{name} won Man of the Match'**
  String motmWinner(String name);

  /// No description provided for @motmWinnerVotes.
  ///
  /// In en, this message translates to:
  /// **'{votes} of {total} votes'**
  String motmWinnerVotes(int votes, int total);

  /// No description provided for @motmVotingClosed.
  ///
  /// In en, this message translates to:
  /// **'Voting has closed'**
  String get motmVotingClosed;

  /// No description provided for @motmNoVotes.
  ///
  /// In en, this message translates to:
  /// **'No votes were cast'**
  String get motmNoVotes;

  /// No description provided for @motmVoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Vote for Man of the Match'**
  String get motmVoteTitle;

  /// No description provided for @motmVotingCloses.
  ///
  /// In en, this message translates to:
  /// **'Voting closes {date}'**
  String motmVotingCloses(String date);

  /// No description provided for @motmFinalizing.
  ///
  /// In en, this message translates to:
  /// **'Result is being finalized'**
  String get motmFinalizing;

  /// No description provided for @competitionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Competitions'**
  String get competitionsTitle;

  /// No description provided for @noCompetitions.
  ///
  /// In en, this message translates to:
  /// **'No championships found.'**
  String get noCompetitions;

  /// No description provided for @liveCompetitions.
  ///
  /// In en, this message translates to:
  /// **'Live Competitions'**
  String get liveCompetitions;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @competitionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this competition.'**
  String get competitionLoadFailed;

  /// No description provided for @tabStandings.
  ///
  /// In en, this message translates to:
  /// **'Standings'**
  String get tabStandings;

  /// No description provided for @tabTeams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get tabTeams;

  /// No description provided for @tabMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get tabMatches;

  /// No description provided for @tabPlayerStats.
  ///
  /// In en, this message translates to:
  /// **'P. Stats'**
  String get tabPlayerStats;

  /// No description provided for @matchesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Error loading matches'**
  String get matchesLoadFailed;

  /// No description provided for @noMatchesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No matches available'**
  String get noMatchesAvailable;

  /// No description provided for @moreMatchesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load more matches'**
  String get moreMatchesLoadFailed;

  /// No description provided for @statsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load stats'**
  String get statsLoadFailed;

  /// No description provided for @topScorers.
  ///
  /// In en, this message translates to:
  /// **'TOP GOAL SCORERS'**
  String get topScorers;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'SHOW LESS'**
  String get showLess;

  /// No description provided for @viewFullList.
  ///
  /// In en, this message translates to:
  /// **'VIEW FULL LIST'**
  String get viewFullList;

  /// No description provided for @standingsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Error loading standings.'**
  String get standingsLoadFailed;

  /// No description provided for @noStandings.
  ///
  /// In en, this message translates to:
  /// **'No standings available yet.'**
  String get noStandings;

  /// No description provided for @standingsTeam.
  ///
  /// In en, this message translates to:
  /// **'TEAM'**
  String get standingsTeam;

  /// No description provided for @standingsPoints.
  ///
  /// In en, this message translates to:
  /// **'PTS'**
  String get standingsPoints;

  /// No description provided for @standingsPlayed.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get standingsPlayed;

  /// No description provided for @standingsWon.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get standingsWon;

  /// No description provided for @standingsDrawn.
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get standingsDrawn;

  /// No description provided for @standingsLost.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get standingsLost;

  /// No description provided for @standingsGoalDifference.
  ///
  /// In en, this message translates to:
  /// **'GD'**
  String get standingsGoalDifference;

  /// No description provided for @participatingTeams.
  ///
  /// In en, this message translates to:
  /// **'PARTICIPATING TEAMS'**
  String get participatingTeams;

  /// No description provided for @teamsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Error loading teams'**
  String get teamsLoadFailed;

  /// No description provided for @noTeamsThisSeason.
  ///
  /// In en, this message translates to:
  /// **'No teams found for this season.'**
  String get noTeamsThisSeason;

  /// No description provided for @searchTeams.
  ///
  /// In en, this message translates to:
  /// **'Search teams'**
  String get searchTeams;

  /// No description provided for @noTeamsFound.
  ///
  /// In en, this message translates to:
  /// **'No teams found.'**
  String get noTeamsFound;

  /// No description provided for @teamNotFound.
  ///
  /// In en, this message translates to:
  /// **'Team not found.'**
  String get teamNotFound;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'OVERVIEW'**
  String get overview;

  /// No description provided for @teamType.
  ///
  /// In en, this message translates to:
  /// **'Team Type'**
  String get teamType;

  /// No description provided for @homeStadium.
  ///
  /// In en, this message translates to:
  /// **'Home Stadium'**
  String get homeStadium;

  /// No description provided for @teamTypeClub.
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get teamTypeClub;

  /// No description provided for @teamTypeNational.
  ///
  /// In en, this message translates to:
  /// **'National'**
  String get teamTypeNational;

  /// No description provided for @playerProfile.
  ///
  /// In en, this message translates to:
  /// **'Player Profile'**
  String get playerProfile;

  /// No description provided for @playerLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this player.'**
  String get playerLoadFailed;

  /// No description provided for @jerseyNumber.
  ///
  /// In en, this message translates to:
  /// **'No. {number}'**
  String jerseyNumber(String number);

  /// No description provided for @playerAge.
  ///
  /// In en, this message translates to:
  /// **'Age {age}'**
  String playerAge(int age);

  /// No description provided for @playerGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get playerGoals;

  /// No description provided for @playerAssists.
  ///
  /// In en, this message translates to:
  /// **'Assists'**
  String get playerAssists;

  /// No description provided for @playerYellowCards.
  ///
  /// In en, this message translates to:
  /// **'Yellow Cards'**
  String get playerYellowCards;

  /// No description provided for @playerRedCards.
  ///
  /// In en, this message translates to:
  /// **'Red Cards'**
  String get playerRedCards;

  /// No description provided for @noSeasonStats.
  ///
  /// In en, this message translates to:
  /// **'No season stats available for this player yet.'**
  String get noSeasonStats;

  /// No description provided for @currentClub.
  ///
  /// In en, this message translates to:
  /// **'Current Club'**
  String get currentClub;

  /// No description provided for @clubSince.
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String clubSince(String date);

  /// No description provided for @positionGoalkeeper.
  ///
  /// In en, this message translates to:
  /// **'Goalkeeper'**
  String get positionGoalkeeper;

  /// No description provided for @positionDefender.
  ///
  /// In en, this message translates to:
  /// **'Defender'**
  String get positionDefender;

  /// No description provided for @positionMidfielder.
  ///
  /// In en, this message translates to:
  /// **'Midfielder'**
  String get positionMidfielder;

  /// No description provided for @positionForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get positionForward;

  /// No description provided for @noArticles.
  ///
  /// In en, this message translates to:
  /// **'No articles found.'**
  String get noArticles;

  /// No description provided for @articleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Article not found.'**
  String get articleNotFound;

  /// No description provided for @linkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open this link.'**
  String get linkOpenFailed;

  /// No description provided for @shareArticle.
  ///
  /// In en, this message translates to:
  /// **'Share article'**
  String get shareArticle;

  /// No description provided for @articleViews.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 view} other{{count} views}}'**
  String articleViews(int count);

  /// No description provided for @relatedMatches.
  ///
  /// In en, this message translates to:
  /// **'Related matches'**
  String get relatedMatches;

  /// No description provided for @favoriteTeams.
  ///
  /// In en, this message translates to:
  /// **'Favorite Teams'**
  String get favoriteTeams;

  /// No description provided for @favoriteCompetitions.
  ///
  /// In en, this message translates to:
  /// **'Favorite Competitions'**
  String get favoriteCompetitions;

  /// No description provided for @noFavoriteTeams.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t followed any teams yet. Tap the star on a team\'s card or profile to follow it.'**
  String get noFavoriteTeams;

  /// No description provided for @noFavoriteCompetitions.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t followed any competitions yet. Tap the star on a competition\'s card or page to follow it.'**
  String get noFavoriteCompetitions;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @followingNotice.
  ///
  /// In en, this message translates to:
  /// **'You\'ll get notifications for {name}. Turn them off in Settings.'**
  String followingNotice(String name);

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @manageFollowedTeams.
  ///
  /// In en, this message translates to:
  /// **'Manage your followed squads'**
  String get manageFollowedTeams;

  /// No description provided for @manageFollowedCompetitions.
  ///
  /// In en, this message translates to:
  /// **'Manage your followed leagues'**
  String get manageFollowedCompetitions;

  /// No description provided for @followedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} followed'**
  String followedCount(int count);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languagePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get languagePhone;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @aboutOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the About page.'**
  String get aboutOpenFailed;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get notificationsSection;

  /// No description provided for @matchNotifications.
  ///
  /// In en, this message translates to:
  /// **'Match Notifications'**
  String get matchNotifications;

  /// No description provided for @matchNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For the teams and competitions you follow'**
  String get matchNotificationsSubtitle;

  /// No description provided for @matchNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Kick-off reminders, goals and results. Tap the star on a team or competition to follow it.'**
  String get matchNotificationsHint;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications for Scoreboards in your phone settings.'**
  String get allowNotifications;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
