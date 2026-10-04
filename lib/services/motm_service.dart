import 'dart:convert';
import 'package:http/http.dart';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/models/motm.dart';
import 'package:scoreboards/services/api_pagination.dart';
import 'package:scoreboards/services/device_service.dart';

/// Thrown when the backend rejects a vote cast/retract (409 voting closed,
/// 400 invalid candidate, 403 device not eligible). [statusCode] lets the UI
/// distinguish "voting closed" from other failures if it needs to.
class MotmVoteRejected implements Exception {
  final int statusCode;
  final String message;
  MotmVoteRejected(this.statusCode, this.message);

  @override
  String toString() => message;
}

class MotmService {
  static Client client = Client();

  static String _summaryUrl(int matchId) => urls['MATCHS']['PLAYER_OF_THE_MATCH']
      .replaceAll('#matchId', matchId.toString());

  static Future<MotmSummary> getSummary(int matchId, {String? deviceId}) async {
    final uri = Uri.parse(_summaryUrl(matchId)).replace(queryParameters: {
      if (deviceId != null) 'device_id': deviceId,
    });

    return fetchJson(
      client: client,
      uri: uri,
      fromJson: (item) => MotmSummary.fromJson(item),
      errorMessage: "Can't get Man of the Match voting.",
    );
  }

  static Future<MotmSummary> castVote(int matchId, int playerId) async {
    final deviceId = await DeviceService().getOrRegisterDevice();

    final response = await client.post(
      Uri.parse(_summaryUrl(matchId)),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"device_id": deviceId, "player_id": playerId}),
    );

    if (response.statusCode != 201) {
      throw MotmVoteRejected(response.statusCode, _detailOf(response));
    }

    return MotmSummary.fromJson(jsonDecode(response.body));
  }

  static Future<MotmSummary> retractVote(int matchId) async {
    final deviceId = await DeviceService().getOrRegisterDevice();

    final response = await client.delete(
      Uri.parse(_summaryUrl(matchId)),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"device_id": deviceId}),
    );

    if (response.statusCode != 200) {
      throw MotmVoteRejected(response.statusCode, _detailOf(response));
    }

    return MotmSummary.fromJson(jsonDecode(response.body));
  }

  static String _detailOf(Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['detail'] != null) {
        return decoded['detail'].toString();
      }
    } catch (_) {
      // fall through to generic message below
    }
    return 'Request failed with status ${response.statusCode}';
  }
}
