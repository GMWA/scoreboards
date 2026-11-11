import 'dart:convert';
import 'package:scoreboards/constants/urls.dart';
import 'package:scoreboards/services/device_service.dart';

/// Sends the device's complete favorites to the backend, which replaces
/// what it has stored for the device. Competitions are followed as
/// editions; the backend counts them per championship. Throws on failure.
Future<void> syncFavoritesToBackend({
  required List<int> teams,
  required List<int> editions,
}) async {
  final deviceId = await DeviceService().getOrRegisterDevice();
  final response = await DeviceService.httpClient
      .put(
        Uri.parse((urls['NOTIFICATIONS']['FAVORITES'] as String)
            .replaceAll('#deviceId', deviceId)),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"teams": teams, "editions": editions}),
      )
      .timeout(const Duration(seconds: 20));

  if (response.statusCode != 200) {
    throw Exception(
        'Favorites sync failed (${response.statusCode}): ${response.body}');
  }
}
