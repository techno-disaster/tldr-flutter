import 'dart:async';
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
    suggestions.retainWhere(
        (element) => element.name.toLowerCase().startsWith(text.toLowerCase()));
    suggestions = LinkedHashSet<Command>.from(suggestions)
        .toList(); // remove repeated elements due to repeated addAll more info: https://api.dart.dev/stable/2.4.0/dart-collection/LinkedHashSet/LinkedHashSet.from.html
    return suggestions;
  }

  final key = GlobalKey();
  final _controller = TextEditingController();
  @override
  void initState() {
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
        title: Hero(
          tag: "search-bar",
          child: TypeAheadField(
              key: key,
              getImmediateSuggestions: true,
              keepSuggestionsOnSuggestionSelected: true,
              hideSuggestionsOnKeyboardHide: false,
              suggestionsBoxDecoration: SuggestionsBoxDecoration(
                borderRadius: BorderRadius.zero,
                elevation: 0,
                offsetX: -55,
                constraints: BoxConstraints(
                  maxHeight: 500,
                  minWidth: MediaQuery.of(context).size.width,
                ),
              ),
              textFieldConfiguration: TextFieldConfiguration(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                    hintText: "Search tldr_ "),
              ),
              suggestionsCallback: (pattern) async {
                if (pattern.length > 1) {
                  return await getSuggestions(pattern);
                } else
                  return [
                    Command("null", "null")
                  ]; // bad workaround for condition when user opens search screen for first time.
              },
              itemBuilder: (context, suggestion) {
                return (suggestion as Command).name == "null"
                    ? Container()
                    : ListTile(
                        tileColor: Color(0xff17181c),
                        title: Text(suggestion.name),
                        subtitle: Text(suggestion.platform),
                      );
              },
              noItemsFoundBuilder: (_) => ListTile(
                    title: Text("No commands found"),
                    subtitle: Text(""),
                    tileColor: Color(0xff17181c),
                  ),
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
      ),
      body: _controller.text.length > 2
          ? Container()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Find your command.",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    "Search the whole tldr project for your command.",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
