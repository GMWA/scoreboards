import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef FakeHandler = Future<ResponseBody> Function(RequestOptions options);

/// Dio adapter that answers from [handler] and records every request.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final FakeHandler handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

/// A Dio like the app's, answering from [handler].
({Dio dio, FakeAdapter api}) fakeDio(FakeHandler handler) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://fake.dev/api/v1',
    contentType: Headers.jsonContentType,
  ));
  final api = FakeAdapter(handler);
  dio.httpClientAdapter = api;
  return (dio: dio, api: api);
}

ResponseBody jsonBody(int status, Object? body) => ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

Never offline(RequestOptions options) => throw DioException.connectionError(
      requestOptions: options,
      reason: 'offline',
    );

/// Answers each path (relative to the API, e.g. `/teams/slug/x/`) with its
/// JSON body; any other path gets a 404.
FakeHandler routes(Map<String, Object?> byPath) => (options) async {
      final path = options.uri.path.replaceFirst('/api/v1', '');
      return byPath.containsKey(path)
          ? jsonBody(200, byPath[path])
          : jsonBody(404, {'detail': 'Not found.'});
    };

/// The JSON body a request sent.
Map<String, dynamic> sentJson(RequestOptions request) => request.data is String
    ? jsonDecode(request.data as String) as Map<String, dynamic>
    : request.data as Map<String, dynamic>;
