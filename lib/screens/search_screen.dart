import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:tldr/models/commad.dart';
import 'package:tldr/screens/command_details.dart';

class SearchScreen extends StatefulWidget {
  final List<Command> commands;

  SearchScreen({Key? key, required this.commands}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Command> suggestions = [];

  Future<List<Command>> getSuggestions(String text) async {
    suggestions.addAll(widget.commands);
    suggestions.retainWhere((element) => element.name.toLowerCase().contains(text.toLowerCase()));
    suggestions = LinkedHashSet<Command>.from(suggestions)
        .toList(); // remove repeated elements due to repeated addAll more info: https://api.dart.dev/stable/2.4.0/dart-collection/LinkedHashSet/LinkedHashSet.from.html
    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
        title: TypeAheadField(
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
              offsetX: -70,
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
            ),
            textFieldConfiguration: TextFieldConfiguration(
              decoration: new InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: "Search Tldr"),
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
            }),
      ),
    );
  }
}
