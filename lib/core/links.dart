/// Website path prefixes (as used in article links) mapped to the app route
/// showing the same page.
const _websiteToAppRoute = {
  'matchs': '/matchs/details',
  'teams': '/teams',
  'leagues': '/championships',
  'players': '/players',
  'blogs': '/blogs',
};

/// The app route for an article link pointing at a website page (relative,
/// like `/teams/x`, or absolute on [website]'s host), or null when the app
/// has no matching screen.
String? appRouteForLink(Uri link, Uri website) {
  final isWebsiteLink =
      !link.hasScheme || (link.host == website.host && link.host.isNotEmpty);
  if (!isWebsiteLink) return null;

  final segments = link.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.length != 2) return null;
  final prefix = _websiteToAppRoute[segments[0]];
  return prefix == null ? null : '$prefix/${segments[1]}';
}

/// Where to go for a website link that opened the app (Android App Links):
/// it arrives as the full address, such as https://scoreboards.cm/matchs/x.
/// The app's route for it, or null when [location] is already an app route.
String? appRouteForIncomingLink(Uri location, Uri website) {
  final route = appRouteForLink(location, website);
  return route == location.toString() ? null : route;
}

/// The website page of an article, for sharing: link previews in WhatsApp
/// and other apps come from that page's title and description.
Uri articleWebLink(Uri website, String slug) =>
    website.replace(pathSegments: ['blogs', slug]);

/// The website page of a match, for sharing: its preview shows the teams
/// and the score.
Uri matchWebLink(Uri website, String slug) =>
    website.replace(pathSegments: ['matchs', slug]);
