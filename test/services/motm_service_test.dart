import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoreboards/services/motm_service.dart';
import 'package:scoreboards/services/device_service.dart';
import 'package:scoreboards/constants/urls.dart';

Map<String, dynamic> _summaryJson() => {
      "window": {
        "is_open": true,
        "opens_at": "2026-10-04T12:00:00Z",
        "closes_at": "2026-10-04T18:00:00Z",
        "has_closed": false,
      },
      "candidates": [
        {
          "player": {
            "id": 50,
            "slug": "john-doe",
            "firstname": "John",
            "lastname": "Doe",
            "avatar": null,
            "jersey_number": 9,
          },
          "team": {
            "id": 10,
            "slug": "team-a",
            "name": "Team A",
            "logo": null,
            "stadium": null,
            "country": "England",
          },
          "is_starting": true,
          "is_captain": false,
          "position": "forward",
        },
      ],
      "tally": [
        {
          "player": {
            "id": 50,
            "slug": "john-doe",
            "firstname": "John",
            "lastname": "Doe",
            "avatar": null,
            "jersey_number": 9,
          },
          "votes": 3,
        },
      ],
      "total_votes": 3,
      "your_vote": null,
      "result": null,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: ".env");
  });

  group("MotmService Tests", () {
    setUp(() {
      urls['MATCHS'] ??= {};
      urls['MATCHS']!['PLAYER_OF_THE_MATCH'] =
          "https://fake.dev/matchs/#matchId/player-of-the-match/";

      // Avoid real device registration network calls: seed a device id.
      DeviceService().resetCache();
      SharedPreferences.setMockInitialValues({"device_id": "device-123"});
    });

    test("getSummary returns a parsed summary on success", () async {
      MotmService.client = MockClient((request) async {
        expect(request.url.toString(),
            "https://fake.dev/matchs/42/player-of-the-match/?device_id=device-123");
        return Response(jsonEncode(_summaryJson()), 200);
      });

      final summary = await MotmService.getSummary(42, deviceId: "device-123");

      expect(summary.candidates, hasLength(1));
      expect(summary.totalVotes, 3);
    });

    test("getSummary throws on error", () async {
      MotmService.client = MockClient((request) async {
        return Response("Error", 500);
      });

      expect(
        () async => await MotmService.getSummary(42),
        throwsA(isA<Exception>()),
      );
    });

    test("castVote posts device_id and player_id and returns the summary",
        () async {
      MotmService.client = MockClient((request) async {
        expect(request.method, "POST");
        expect(request.url.toString(),
            "https://fake.dev/matchs/42/player-of-the-match/");

        final body = jsonDecode(request.body);
        expect(body["device_id"], "device-123");
        expect(body["player_id"], 50);

        return Response(jsonEncode(_summaryJson()), 201);
      });

      final summary = await MotmService.castVote(42, 50);

      expect(summary.candidates, hasLength(1));
    });

    test("castVote throws MotmVoteRejected with the server detail on 409",
        () async {
      MotmService.client = MockClient((request) async {
        return Response(jsonEncode({"detail": "Voting is closed."}), 409);
      });

      expect(
        () async => await MotmService.castVote(42, 50),
        throwsA(isA<MotmVoteRejected>().having(
          (e) => e.message,
          'message',
          "Voting is closed.",
        )),
      );
    });

    test("retractVote deletes with device_id and returns the summary",
        () async {
      MotmService.client = MockClient((request) async {
        expect(request.method, "DELETE");

        final body = jsonDecode(request.body);
        expect(body["device_id"], "device-123");

        return Response(jsonEncode(_summaryJson()), 200);
      });

      final summary = await MotmService.retractVote(42);

      expect(summary.totalVotes, 3);
    });

    test("retractVote throws MotmVoteRejected on failure", () async {
      MotmService.client = MockClient((request) async {
        return Response(jsonEncode({"detail": "Not found."}), 404);
      });

      expect(
        () async => await MotmService.retractVote(42),
        throwsA(isA<MotmVoteRejected>()),
      );
    });
  });
}
