import 'package:dio/dio.dart';

import 'package:scoreboards/core/api/api_exception.dart';

typedef Json = Map<String, dynamic>;

/// One page of a list endpoint; [nextPage] is null on the last page.
typedef ApiPage<T> = ({List<T> items, int? nextPage});

/// One page of a list endpoint. It answers with pages (`results`, `next`)
/// when paginated, or with a plain list (then the only page). Pages are
/// asked by number, as the `next` link is an absolute URL whose scheme can
/// be wrong behind a proxy.
Future<ApiPage<Json>> getPage(
  Dio dio,
  String path, {
  Map<String, Object?> query = const {},
  int page = 1,
  int pageSize = 100,
}) async {
  final body = await getJson<Object>(
    dio,
    path,
    query: {...query, 'page_size': pageSize, 'page': page},
  );
  return switch (body) {
    List<dynamic> list => (items: list.cast<Json>(), nextPage: null),
    Map<String, dynamic> map => (
        items: (map['results'] as List<dynamic>? ?? const []).cast<Json>(),
        nextPage: map['next'] == null ? null : page + 1,
      ),
    _ => throw const ApiException(ApiErrorKind.unknown),
  };
}

/// Every row of a list endpoint, walking its pages. 100 is the backend's
/// largest page, so most lists come back in one request.
Future<List<Json>> getAll(
  Dio dio,
  String path, {
  Map<String, Object?> query = const {},
}) async {
  final rows = <Json>[];
  int? page = 1;
  while (page != null) {
    final result = await getPage(dio, path, query: query, page: page);
    rows.addAll(result.items);
    page = result.nextPage;
  }
  return rows;
}

/// A list endpoint that isn't paginated (a plain JSON array).
Future<List<Json>> getList(
  Dio dio,
  String path, {
  Map<String, Object?> query = const {},
}) async =>
    (await getJson<List<dynamic>>(dio, path, query: query)).cast<Json>();
