import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
//import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:tldr/models/commad.dart';
import 'package:tldr/remote/requests.dart';
import 'package:tldr/screens/command_details.dart';
import 'package:tldr/screens/search_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/scaled_tile.dart';

class TLDR extends StatefulWidget {
  @override
  _TLDRState createState() => _TLDRState();
}

class _TLDRState extends State<TLDR> {
  TldrBackend api = TldrBackend();
  List<Command> commands = [];
  List<Command> suggestions = [];

  @override
  void initState() {
    getCommands();
    super.initState();
  }

  void getCommands() async {
    var data = await api.commands();
    setState(() {
      commands = data.entries.map((e) => Command(e.key, e.value)).toList();
    });
    // var _list = commands.
  }

  Future<List<Command>> getSuggestions(String text) async {
    suggestions.addAll(commands);
    suggestions.retainWhere((element) => element.name.toLowerCase().contains(text.toLowerCase()));
    suggestions = LinkedHashSet<Command>.from(suggestions)
        .toList(); // remove repeated elements due to repeated addAll more info: https://api.dart.dev/stable/2.4.0/dart-collection/LinkedHashSet/LinkedHashSet.from.html
    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff17181c),
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => SearchScreen(
                        commands: commands,
                      )),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Color(0xff17181c),
      ),
      body: Center(
          child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return await getSuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text((suggestion as Command).name),
                  subtitle: Text(suggestion.platform),
                );
              },
              onSuggestionSelected: (suggestion) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommandDetails(
                      command: suggestion as Command,
                    ),
                  ),
                );
              })
          // child: Markdown(
          //   data: data,
          // ),
          ),
    );
  }
}
