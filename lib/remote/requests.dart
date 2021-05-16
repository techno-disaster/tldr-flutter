import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tldr/command/models/command.dart';

class TldrBackend {
  Future<Map<String, dynamic>> commands() async {
    final Uri commandsUrl = Uri.https(
      'raw.githubusercontent.com',
      '/Techno-Disaster/tldr-flutter/master/tldrdict/static/commands.txt',
    ); // it's useless don't waste your time
    Map<String, dynamic> data = {};
    try {
      http.Response response = await http.get(commandsUrl);
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
      }
    } on Exception catch (e) {
      print(e);
    }
    return data;
  }

  Future<String> details(Command command) async {
    final Uri commandDetailsUrl = Uri.https('raw.githubusercontent.com',
        '/tldr-pages/tldr/main/pages/${command.platform}/${command.name}.md');
    String details = "";
    try {
      http.Response response = await http.get(commandDetailsUrl);
      if (response.statusCode == 200) {
        details = response.body.toString();
      }
    } on Exception catch (e) {
      print(e);
    }
    return details;
  }
}
