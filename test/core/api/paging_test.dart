import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/core/api/api_exception.dart';
import 'package:scoreboards/core/api/paging.dart';

import '../../helpers/fake_http.dart';

void main() {
  group('getAll', () {
    test('returns the rows of a plain JSON array', () async {
      final (:dio, :api) = fakeDio((_) async => jsonBody(200, [
            {'id': 1},
            {'id': 2},
          ]));

      final rows = await getAll(dio, '/items/');

      expect(rows.map((r) => r['id']), [1, 2]);
      expect(api.requests, hasLength(1));
    });

    test('returns the rows of a single page', () async {
      final (:dio, api: _) = fakeDio((_) async => jsonBody(200, {
            'count': 2,
            'next': null,
            'results': [
              {'id': 1},
              {'id': 2},
            ],
          }));

      expect((await getAll(dio, '/items/')).map((r) => r['id']), [1, 2]);
    });

    test('walks every page by number, in order', () async {
      final (:dio, :api) = fakeDio((o) async {
        final page = o.queryParameters['page'];
        return jsonBody(200, {
          'next': page == 1 ? 'http://proxy/items/?page=2' : null,
          'results': [
            {'id': page},
          ],
        });
      });

      final rows = await getAll(dio, '/items/');

      expect(rows.map((r) => r['id']), [1, 2]);
      expect(api.requests.map((r) => r.queryParameters['page']), [1, 2]);
    });

    test('keeps the query and asks for large pages', () async {
      final (:dio, :api) = fakeDio((_) async => jsonBody(200, []));

      await getAll(dio, '/items/', query: {'search': 'lion'});

      expect(api.requests.single.queryParameters,
          {'search': 'lion', 'page_size': 100, 'page': 1});
    });

    test('fails with an ApiException on an error status', () async {
      final (:dio, api: _) = fakeDio((_) async => jsonBody(500, {}));

      expect(
        getAll(dio, '/items/'),
        throwsA(isA<ApiException>()
            .having((e) => e.kind, 'kind', ApiErrorKind.server)),
      );
    });

    test('fails on an unexpected answer', () async {
      final (:dio, api: _) = fakeDio((_) async => jsonBody(200, 'oops'));

      expect(getAll(dio, '/items/'), throwsA(isA<ApiException>()));
    });
  });

  test('getPage says which page comes next', () async {
    final (:dio, api: _) = fakeDio((o) async => jsonBody(200, {
          'next': 'x',
          'results': [
            {'id': 1},
          ],
        }));

    final page = await getPage(dio, '/items/', page: 3, pageSize: 20);

    expect(page.items.single['id'], 1);
    expect(page.nextPage, 4);
  });

  test('getList reads a plain array without paging', () async {
    final (:dio, :api) = fakeDio((_) async => jsonBody(200, [
          {'id': 1},
        ]));

    expect((await getList(dio, '/items/')).single['id'], 1);
    expect(api.requests.single.queryParameters, isEmpty);
  });
}
