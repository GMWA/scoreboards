import 'dart:convert';
import 'package:http/http.dart';

/// Fetches every page of a DRF `PageNumberPagination` list endpoint and
/// returns the flattened items.
///
/// Handles both the paginated envelope (`{"count","next","previous",
/// "results"}`) and a plain JSON array, so it's safe to use even for
/// endpoints that aren't paginated on the backend (yet) — no separate
/// code path needed per endpoint.
///
/// [uri]'s query parameters are preserved on every page; `page_size` is
/// added to the first request (capped by the backend's `max_page_size`)
/// so small-to-medium lists come back in one round trip.
Future<List<T>> fetchPaginated<T>({
  required Client client,
  required Uri uri,
  required T Function(dynamic json) fromJson,
  int pageSize = 100,
}) async {
  final items = <T>[];
  Uri? next = uri.replace(queryParameters: {
    ...uri.queryParameters,
    'page_size': '$pageSize',
  });

  while (next != null) {
    final res = await client.get(next);
    if (res.statusCode != 200) {
      throw Exception('Request to $next failed with status ${res.statusCode}');
    }

    final decoded = jsonDecode(res.body);

    if (decoded is Map<String, dynamic> && decoded.containsKey('results')) {
      items.addAll((decoded['results'] as List).map(fromJson));
      final nextUrl = decoded['next'] as String?;
      next = nextUrl != null ? Uri.parse(nextUrl) : null;
    } else if (decoded is List) {
      items.addAll(decoded.map(fromJson));
      next = null;
    } else {
      throw Exception('Unexpected response shape from $next');
    }
  }

  return items;
}

/// Performs a single GET request expecting a bare JSON array and maps each
/// element with [fromJson]. For endpoints that page their results, use
/// [fetchPaginated] instead.
///
/// [errorMessage] is used verbatim as the thrown exception's message on a
/// non-200 response, so call sites can keep their existing wording.
Future<List<T>> fetchList<T>({
  required Client client,
  required Uri uri,
  required T Function(dynamic json) fromJson,
  String? errorMessage,
}) async {
  final res = await client.get(uri);
  if (res.statusCode != 200) {
    throw Exception(errorMessage ?? 'Request to $uri failed with status ${res.statusCode}');
  }

  final decoded = jsonDecode(res.body) as List;
  return decoded.map(fromJson).toList();
}

/// Performs a single GET request expecting a single JSON object and maps
/// it with [fromJson].
///
/// [errorMessage] is used verbatim as the thrown exception's message on a
/// non-200 response, so call sites can keep their existing wording.
Future<T> fetchJson<T>({
  required Client client,
  required Uri uri,
  required T Function(dynamic json) fromJson,
  String? errorMessage,
}) async {
  final res = await client.get(uri);
  if (res.statusCode != 200) {
    throw Exception(errorMessage ?? 'Request to $uri failed with status ${res.statusCode}');
  }

  return fromJson(jsonDecode(res.body));
}
