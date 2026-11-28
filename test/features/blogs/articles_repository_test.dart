import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/features/blogs/articles_repository.dart';

import '../../helpers/fake_http.dart';

void main() {
  test('all searches when asked to', () async {
    final (:dio, :api) =
        fakeDio((_) async => jsonBody(200, {'next': null, 'results': []}));

    await ArticlesRepository(dio).all(search: 'lions');

    expect(api.requests.single.path, '/articles/');
    expect(api.requests.single.queryParameters['search'], 'lions');
  });

  test('recordView never fails', () async {
    final (:dio, :api) = fakeDio(offline);

    await ArticlesRepository(dio).recordView(4);

    expect(api.requests.single.path, '/articles/4/view/');
    expect(api.requests.single.method, 'POST');
  });
}
