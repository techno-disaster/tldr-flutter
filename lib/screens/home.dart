import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tldr/models/commad.dart';
import 'package:tldr/remote/requests.dart';
import 'package:tldr/screens/search_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flare_flutter/flare_actor.dart';

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
    suggestions.retainWhere(
        (element) => element.name.toLowerCase().contains(text.toLowerCase()));
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
                ),
              ),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Color(0xff17181c),
      ),
      body: Center(
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Container(
              height: 300,
              width: 300,
              child: FlareActor("assets/images/tldr.flr",
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                  animation: "startup"),
            ),
            SizedBox(
              height: 30,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  transitionOnUserGestures: true,
                  tag: "search-bar",
                  child: SearchButton(
                    commands: commands,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SearchButton extends StatelessWidget {
  final List<Command> commands;

  const SearchButton({Key? key, required this.commands}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Color(0xff2e2f37),
      child: SizedBox(
        width: 200,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Search ",
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentColor,
                      fontSize: 24),
                )),
            TypewriterAnimatedTextKit(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    commands: commands,
                  ),
                ),
              ),
              speed: Duration(milliseconds: 200),
              isRepeatingAnimation: false,
              text: ["tldr"],
              textStyle: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SearchScreen(
            commands: commands,
          ),
        ),
      ),
    );
  }
}
