import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboards/core/api/api_exception.dart';

import '../../helpers/fake_http.dart';

void main() {
  Future<ApiException> failure(FakeHandler handler) async {
    final (:dio, api: _) = fakeDio(handler);
    try {
      await getJson<Object>(dio, '/x/');
    } on ApiException catch (e) {
      return e;
    }
    fail('expected an ApiException');
  }

  test('no answer is a network error', () async {
    expect((await failure(offline)).kind, ApiErrorKind.network);
  });

  test('the status decides the kind, and detail is the message', () async {
    final notFound = await failure((_) async => jsonBody(404, {}));
    expect(notFound.kind, ApiErrorKind.notFound);

    final refused =
        await failure((_) async => jsonBody(409, {'detail': 'Voting closed'}));
    expect(refused.kind, ApiErrorKind.rejected);
    expect(refused.statusCode, 409);
    expect(refused.message, 'Voting closed');
    expect(refused.toString(), 'Voting closed');

    expect((await failure((_) async => jsonBody(503, null))).kind,
        ApiErrorKind.server);
  });
}
