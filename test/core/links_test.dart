import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/core/links.dart';

void main() {
  group('appRouteForLink', () {
    final website = Uri.parse('https://scoreboards.cm');
    String? route(String link) => appRouteForLink(Uri.parse(link), website);

    test('maps website paths used in articles to app routes', () {
      expect(route('/teams/cameroun-w'), '/teams/cameroun-w');
      expect(route('/players/temwa-chawinga'), '/players/temwa-chawinga');
      expect(route('/leagues/wafcon-2026'), '/championships/wafcon-2026');
      expect(route('/matchs/a-vs-b'), '/matchs/details/a-vs-b');
      expect(route('/blogs/some-article'), '/blogs/some-article');
    });

    test('maps absolute links to the website the same way', () {
      expect(route('https://scoreboards.cm/teams/cameroun-w'),
          '/teams/cameroun-w');
    });

    test('returns null for pages the app does not have and other sites', () {
      expect(route('/predictions'), isNull);
      expect(route('/teams'), isNull);
      expect(route('https://example.com/teams/cameroun-w'), isNull);
    });
  });

  test('articleWebLink points at the article page on the website', () {
    expect(
      articleWebLink(Uri.parse('https://scoreboards.cm'), 'cameroun-w-champion')
          .toString(),
      'https://scoreboards.cm/blogs/cameroun-w-champion',
    );
    // The link round-trips to the app's article screen.
    final website = Uri.parse('https://scoreboards.cm');
    expect(
        appRouteForLink(articleWebLink(website, 'a-b'), website), '/blogs/a-b');
  });

  group('appRouteForIncomingLink', () {
    final website = Uri.parse('https://scoreboards.cm');
    String? route(String location) =>
        appRouteForIncomingLink(Uri.parse(location), website);

    test('maps website paths to the app screens', () {
      expect(route('/matchs/a-vs-b'), '/matchs/details/a-vs-b');
      expect(route('/leagues/elite-one'), '/championships/elite-one');
      expect(route('https://scoreboards.cm/matchs/a-vs-b'),
          '/matchs/details/a-vs-b');
      // Same path on both: the address still has to become a route.
      expect(route('https://scoreboards.cm/teams/cameroun-w'),
          '/teams/cameroun-w');
    });

    test('leaves app routes alone', () {
      expect(route('/home'), isNull);
      expect(route('/teams/cameroun-w'), isNull);
      expect(route('/matchs/details/a-vs-b'), isNull);
      expect(route('/settings/favorites/teams'), isNull);
    });
  });

  test('matchWebLink points at the match page on the website', () {
    final website = Uri.parse('https://scoreboards.cm');
    expect(matchWebLink(website, 'a-vs-b').toString(),
        'https://scoreboards.cm/matchs/a-vs-b');
    // The link round-trips to the app's match screen.
    expect(appRouteForLink(matchWebLink(website, 'a-vs-b'), website),
        '/matchs/details/a-vs-b');
  });
}
