// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navScores => 'Scores';

  @override
  String get navLeagues => 'Ligues';

  @override
  String get navTeams => 'Équipes';

  @override
  String get navBlogs => 'Blogs';

  @override
  String get navSettings => 'Réglages';

  @override
  String get retry => 'Réessayer';

  @override
  String get connectionError => 'Erreur de connexion';

  @override
  String get loadError => 'Une erreur est survenue lors du chargement !';

  @override
  String get liveBadge => 'DIRECT';

  @override
  String get fullTimeShort => 'FIN';

  @override
  String get resultUnknown => 'RÉSULTAT INCONNU';

  @override
  String penaltiesScore(String home, String away) {
    return '($home - $away TAB)';
  }

  @override
  String penaltiesScoreShort(String home, String away) {
    return '($home-$away TAB)';
  }

  @override
  String get filterAll => 'Tous';

  @override
  String get filterLive => '● En direct';

  @override
  String get filterUpcoming => 'À venir';

  @override
  String get filterFinished => 'Terminés';

  @override
  String get noMatchesInView => 'Aucun match dans cette vue.';

  @override
  String get failedToLoadMatches => 'Impossible de charger les matchs.';

  @override
  String get followTeam => 'Suivre une équipe';

  @override
  String roundMatchday(String number) {
    return 'Journée $number';
  }

  @override
  String get roundFinal => 'Finale';

  @override
  String get roundSemiFinal => 'Demi-finale';

  @override
  String get roundQuarterFinal => 'Quart de finale';

  @override
  String get roundThirdPlace => 'Match pour la 3e place';

  @override
  String get roundOf16 => 'Huitièmes de finale';

  @override
  String get roundOf32 => 'Seizièmes de finale';

  @override
  String get matchNotFound => 'Impossible de trouver les détails du match.';

  @override
  String get matchCenter => 'CENTRE DU MATCH';

  @override
  String get shareMatch => 'Partager le match';

  @override
  String get tabTimeline => 'Déroulé';

  @override
  String get tabStats => 'Stats';

  @override
  String get tabLineups => 'Compositions';

  @override
  String get tabMotm => 'Homme du match';

  @override
  String get statusLive => 'En direct';

  @override
  String get statusFullTime => 'Terminé';

  @override
  String get statusScheduled => 'Programmé';

  @override
  String get statusPostponed => 'Reporté';

  @override
  String get statusCancelled => 'Annulé';

  @override
  String get statusAbandoned => 'Arrêté';

  @override
  String get statusAwarded => 'Sur tapis vert';

  @override
  String get noMatchEvents => 'Aucun événement pour le moment';

  @override
  String get unknownPlayer => 'Joueur inconnu';

  @override
  String get ownGoal => 'But contre son camp';

  @override
  String assistBy(String name) {
    return 'Passe : $name';
  }

  @override
  String get secondYellow => 'Deuxième jaune';

  @override
  String get staffHeadCoach => 'Entraîneur principal';

  @override
  String get staffAssistantCoach => 'Entraîneur adjoint';

  @override
  String get staffOther => 'Staff';

  @override
  String get lineupsNotPublished =>
      'Les compositions n\'ont pas encore été publiées.';

  @override
  String get substitutes => 'REMPLAÇANTS';

  @override
  String get statPossession => 'Possession';

  @override
  String get statShots => 'Tirs';

  @override
  String get statShotsOnTarget => 'Tirs cadrés';

  @override
  String get statCorners => 'Corners';

  @override
  String get statFouls => 'Fautes';

  @override
  String get statOffsides => 'Hors-jeu';

  @override
  String get statSaves => 'Arrêts';

  @override
  String get statYellowCards => 'Cartons jaunes';

  @override
  String get statRedCards => 'Cartons rouges';

  @override
  String statsSource(String note) {
    return 'Source : $note';
  }

  @override
  String statComparison(String label, String home, String away) {
    return '$label : $home contre $away';
  }

  @override
  String get motmVoteFailed => 'Impossible d\'enregistrer votre vote.';

  @override
  String get motmLoadFailed =>
      'Impossible de charger le vote de l\'homme du match.';

  @override
  String get motmOpensWithLineups =>
      'Le vote de l\'homme du match ouvre dès que les compositions sont publiées.';

  @override
  String get motmTie => 'Égalité !';

  @override
  String motmVotesCast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes exprimés',
      one: '1 vote exprimé',
    );
    return '$_temp0';
  }

  @override
  String motmWinner(String name) {
    return '$name est l\'homme du match';
  }

  @override
  String motmWinnerVotes(int votes, int total) {
    return '$votes votes sur $total';
  }

  @override
  String get motmVotingClosed => 'Le vote est clos';

  @override
  String get motmNoVotes => 'Aucun vote exprimé';

  @override
  String get motmVoteTitle => 'Votez pour l\'homme du match';

  @override
  String motmVotingCloses(String date) {
    return 'Fin du vote : $date';
  }

  @override
  String get motmFinalizing => 'Résultat en cours de validation';

  @override
  String get competitionsTitle => 'Compétitions';

  @override
  String get noCompetitions => 'Aucune compétition trouvée.';

  @override
  String get liveCompetitions => 'Compétitions en cours';

  @override
  String get archive => 'Archives';

  @override
  String get competitionLoadFailed =>
      'Impossible de charger cette compétition.';

  @override
  String get tabStandings => 'Classement';

  @override
  String get tabTeams => 'Équipes';

  @override
  String get tabMatches => 'Matchs';

  @override
  String get tabPlayerStats => 'Buteurs';

  @override
  String get matchesLoadFailed => 'Erreur de chargement des matchs';

  @override
  String get noMatchesAvailable => 'Aucun match disponible';

  @override
  String get moreMatchesLoadFailed => 'Impossible de charger plus de matchs';

  @override
  String get statsLoadFailed => 'Impossible de charger les statistiques';

  @override
  String get topScorers => 'MEILLEURS BUTEURS';

  @override
  String get showLess => 'VOIR MOINS';

  @override
  String get viewFullList => 'VOIR TOUT';

  @override
  String get standingsLoadFailed => 'Erreur de chargement du classement.';

  @override
  String get noStandings => 'Aucun classement disponible pour le moment.';

  @override
  String get standingsTeam => 'ÉQUIPE';

  @override
  String get standingsPoints => 'PTS';

  @override
  String get standingsPlayed => 'J';

  @override
  String get standingsWon => 'G';

  @override
  String get standingsDrawn => 'N';

  @override
  String get standingsLost => 'P';

  @override
  String get standingsGoalDifference => 'DB';

  @override
  String get participatingTeams => 'ÉQUIPES PARTICIPANTES';

  @override
  String get teamsLoadFailed => 'Erreur de chargement des équipes';

  @override
  String get noTeamsThisSeason => 'Aucune équipe trouvée pour cette saison.';

  @override
  String get searchTeams => 'Rechercher une équipe';

  @override
  String get noTeamsFound => 'Aucune équipe trouvée.';

  @override
  String get teamNotFound => 'Équipe introuvable.';

  @override
  String get overview => 'APERÇU';

  @override
  String get teamType => 'Type d\'équipe';

  @override
  String get homeStadium => 'Stade';

  @override
  String get teamTypeClub => 'Club';

  @override
  String get teamTypeNational => 'Sélection nationale';

  @override
  String get playerProfile => 'Profil du joueur';

  @override
  String get playerLoadFailed => 'Impossible de charger ce joueur.';

  @override
  String jerseyNumber(String number) {
    return 'N° $number';
  }

  @override
  String playerAge(int age) {
    return '$age ans';
  }

  @override
  String get playerGoals => 'Buts';

  @override
  String get playerAssists => 'Passes décisives';

  @override
  String get playerYellowCards => 'Cartons jaunes';

  @override
  String get playerRedCards => 'Cartons rouges';

  @override
  String get noSeasonStats =>
      'Aucune statistique de la saison pour ce joueur pour le moment.';

  @override
  String get currentClub => 'Club actuel';

  @override
  String clubSince(String date) {
    return 'Depuis $date';
  }

  @override
  String get positionGoalkeeper => 'Gardien';

  @override
  String get positionDefender => 'Défenseur';

  @override
  String get positionMidfielder => 'Milieu';

  @override
  String get positionForward => 'Attaquant';

  @override
  String get noArticles => 'Aucun article trouvé.';

  @override
  String get articleNotFound => 'Article introuvable.';

  @override
  String get linkOpenFailed => 'Impossible d\'ouvrir ce lien.';

  @override
  String get shareArticle => 'Partager l\'article';

  @override
  String articleViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vues',
      one: '1 vue',
      zero: '0 vue',
    );
    return '$_temp0';
  }

  @override
  String get relatedMatches => 'Matchs liés';

  @override
  String get favoriteTeams => 'Équipes favorites';

  @override
  String get favoriteCompetitions => 'Compétitions favorites';

  @override
  String get noFavoriteTeams =>
      'Vous ne suivez encore aucune équipe. Touchez l\'étoile sur la carte ou la page d\'une équipe pour la suivre.';

  @override
  String get noFavoriteCompetitions =>
      'Vous ne suivez encore aucune compétition. Touchez l\'étoile sur la carte ou la page d\'une compétition pour la suivre.';

  @override
  String get unfollow => 'Ne plus suivre';

  @override
  String followingNotice(String name) {
    return 'Vous recevrez des notifications pour $name. Désactivez-les dans les Réglages.';
  }

  @override
  String get preferences => 'PRÉFÉRENCES';

  @override
  String get manageFollowedTeams => 'Gérez les équipes que vous suivez';

  @override
  String get manageFollowedCompetitions =>
      'Gérez les compétitions que vous suivez';

  @override
  String followedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suivies',
      one: '1 suivie',
    );
    return '$_temp0';
  }

  @override
  String get language => 'Langue';

  @override
  String get languagePhone => 'Langue du téléphone';

  @override
  String get about => 'À propos';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutOpenFailed => 'Impossible d\'ouvrir la page À propos.';

  @override
  String get notificationsSection => 'NOTIFICATIONS';

  @override
  String get matchNotifications => 'Notifications de match';

  @override
  String get matchNotificationsSubtitle =>
      'Pour les équipes et compétitions que vous suivez';

  @override
  String get matchNotificationsHint =>
      'Rappels avant le coup d\'envoi, buts et résultats. Touchez l\'étoile d\'une équipe ou d\'une compétition pour la suivre.';

  @override
  String get allowNotifications =>
      'Autorisez les notifications de Scoreboards dans les réglages du téléphone.';
}
