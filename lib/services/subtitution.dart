import 'dart:convert';
import 'package:http/http.dart';
import 'package:scoreboards/models/subtitution.dart';
import 'package:scoreboards/constants/urls.dart';

class PlayerService {
  static Client client = Client();
  static Future<List<Substitution>> getMatchSubtitutions(int matchId) async {
    Response res = await client.get(Uri.parse(
        urls['MATCHS']['SUBTITUTIONS'].replaceAll('#matchId', matchId.toString())));

    if (res.statusCode == 200) {
      List<dynamic> subtitutionsList = jsonDecode(res.body);
      List<Substitution> subtitutions =
          subtitutionsList.map((dynamic item) => Substitution.fromJson(item)).toList();
      return subtitutions;
    } else {
      throw "Can't get Subtitution by match.";
    }
  }
}