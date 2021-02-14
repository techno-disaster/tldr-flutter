import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tldr/models/commad.dart';

class TldrBackend {
  Future<Map<String, dynamic>> commands() async {
    final Uri commandsUrl = Uri.https(
        'raw.githubusercontent.com',
        '/Techno-Disaster/foo/master/tldrdict/static/commands.txt',
        {'token': 'AMS62UYWN5PVIHBCFWBVZADAGJP3U'});
    Map<String, dynamic> data = {};
    try {
      http.Response response = await http.get(commandsUrl);
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
      } else
        throw Exception();
    } on Exception catch (e) {
      print(e);
    }
    return data;
  }

  Future<String> details(Command command) async {
    final Uri commandDetailsUrl = Uri.https('raw.githubusercontent.com',
        '/tldr-pages/tldr/master/pages/${command.platform}/${command.name}.md');
    String details = "";
    try {
      http.Response response = await http.get(commandDetailsUrl);
      if (response.statusCode == 200) {
        details = response.body.toString();
      } else
        throw Exception();
    } on Exception catch (e) {
      print(e);
    }
    return details;
  }
}
