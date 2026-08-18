import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:scoreboards/services/api_pagination.dart';

void main() {
  group('fetchPaginated', () {
    test('returns items directly from a bare JSON array', () async {
      final client = MockClient((request) async {
        return Response(
            jsonEncode([
              {'id': 1},
              {'id': 2},
            ]),
            200);
      });

      final items = await fetchPaginated<int>(
        client: client,
        uri: Uri.parse('https://api.example.com/items'),
        fromJson: (json) => json['id'] as int,
      );

      expect(items, [1, 2]);
    });

    test('returns items from a single-page paginated envelope', () async {
      final client = MockClient((request) async {
        return Response(
            jsonEncode({
              'count': 2,
              'next': null,
              'previous': null,
              'results': [
                {'id': 1},
                {'id': 2},
              ],
            }),
            200);
      });

      final items = await fetchPaginated<int>(
        client: client,
        uri: Uri.parse('https://api.example.com/items'),
        fromJson: (json) => json['id'] as int,
      );

      expect(items, [1, 2]);
    });

    test('walks every page and flattens results in order', () async {
      final requestedUris = <Uri>[];
      final client = MockClient((request) async {
        requestedUris.add(request.url);
        if (!request.url.queryParameters.containsKey('page')) {
          return Response(
              jsonEncode({
                'next': 'https://api.example.com/items?page=2&page_size=100',
                'previous': null,
                'results': [
                  {'id': 1},
                  {'id': 2},
                ],
              }),
              200);
        }
        return Response(
            jsonEncode({
              'next': null,
              'previous': null,
              'results': [
                {'id': 3},
              ],
            }),
            200);
      });

      final items = await fetchPaginated<int>(
        client: client,
        uri: Uri.parse('https://api.example.com/items'),
        fromJson: (json) => json['id'] as int,
      );

      expect(items, [1, 2, 3]);
      expect(requestedUris.length, 2);
      expect(requestedUris[1].queryParameters['page'], '2');
    });

    test('preserves existing query parameters and adds page_size', () async {
      Uri? capturedUri;
      final client = MockClient((request) async {
        capturedUri = request.url;
        return Response(jsonEncode([]), 200);
      });

      await fetchPaginated<int>(
        client: client,
        uri: Uri.parse('https://api.example.com/items?edition=2024'),
        fromJson: (json) => json['id'] as int,
        pageSize: 50,
      );

      expect(capturedUri!.queryParameters['edition'], '2024');
      expect(capturedUri!.queryParameters['page_size'], '50');
    });

    test('throws when the response status is not 200', () async {
      final client = MockClient((request) async {
        return Response('Server error', 500);
      });

      expect(
        () => fetchPaginated<int>(
          client: client,
          uri: Uri.parse('https://api.example.com/items'),
          fromJson: (json) => json['id'] as int,
        ),
        throwsException,
      );
    });

    test('throws on an unexpected response shape', () async {
      final client = MockClient((request) async {
        return Response(jsonEncode({'unexpected': 'shape'}), 200);
      });

      expect(
        () => fetchPaginated<int>(
          client: client,
          uri: Uri.parse('https://api.example.com/items'),
          fromJson: (json) => json['id'] as int,
        ),
        throwsException,
      );
    });
  });
}
