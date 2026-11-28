import 'package:dio/dio.dart';

enum ApiErrorKind { network, notFound, rejected, server, unknown }

/// Every API failure a repository throws. Screens decide what to show from
/// [kind] (or [statusCode]) rather than from the backend's text.
class ApiException implements Exception {
  const ApiException(this.kind, {this.statusCode, this.message});

  factory ApiException.fromDio(DioException e) {
    final response = e.response;
    if (response == null) return const ApiException(ApiErrorKind.network);

    final status = response.statusCode ?? 0;
    final body = response.data;
    final message = body is Map ? body['detail']?.toString() : null;
    final kind = switch (status) {
      404 => ApiErrorKind.notFound,
      >= 400 && < 500 => ApiErrorKind.rejected,
      >= 500 => ApiErrorKind.server,
      _ => ApiErrorKind.unknown,
    };
    return ApiException(kind, statusCode: status, message: message);
  }

  final ApiErrorKind kind;
  final int? statusCode;

  /// The backend's `detail`, when it sends one.
  final String? message;

  @override
  String toString() =>
      message ?? 'ApiException($kind${statusCode == null ? '' : ', $statusCode'})';
}

/// Runs a request and turns Dio failures into [ApiException].
Future<T> apiCall<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
}

/// GETs [path] and returns its JSON body.
Future<T> getJson<T>(
  Dio dio,
  String path, {
  Map<String, Object?> query = const {},
}) async {
  final response = await apiCall(
    () => dio.get<T>(path, queryParameters: query),
  );
  return response.data as T;
}
