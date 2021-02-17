import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tldr/command/bloc/command_bloc.dart';
import 'package:tldr/command/models/command.dart';
import 'package:tldr/remote/requests.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:tldr/utils/constants.dart';
import 'package:tldr/utils/favorites_tile.dart';
import 'package:tldr/utils/recents_tile.dart';
import 'package:tldr/utils/router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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
    BlocProvider.of<CommandBloc>(context).add(AppOpened());

    super.initState();
  }

  void getCommands() async {
    var data = await api.commands();
    setState(() {
      commands = data.entries
          .map((e) => Command(name: e.key, platform: e.value))
          .toList();
    });
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
        elevation: 0,
        backgroundColor: Color(0xff17181c),
      ),
      drawer: Drawer(
        elevation: 0,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 200,
              child: DrawerHeader(
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      child: Image.asset(
                        "assets/images/tldr.png",
                      ),
                    ),
                    Text("TLDR"),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text('Recent commands'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  recentsPage,
                );
              },
            ),
            ListTile(
              title: Text('Favorite commands'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  favoritesPage,
                );
              },
            ),
            ListTile(
              title: Text('About app'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  createAboutPageRoute(),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Container(
              height: 300,
              width: 300,
              child: FlareActor(
                "assets/images/tldr.flr",
                alignment: Alignment.center,
                fit: BoxFit.contain,
                animation: "startup",
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
              child: AboutTldrText(),
            ),
            SizedBox(
              height: 12,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Hero(
                    transitionOnUserGestures: true,
                    tag: "search-bar",
                    child: SearchButton(
                      commands: commands,
                    ),
                  ),
                ),
              ],
            ),
            BlocBuilder<CommandBloc, CommandState>(
              builder: (context, state) {
                if (state is CommandState) {
                  state.recentCommands
                      .sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
                  state.favoriteCommands
                      .sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
                  return Column(
                    children: [
                      FavoritesList(
                        favoritesList: state.favoriteCommands,
                      ),
                      RecentsList(recentCommands: state.recentCommands),
                    ],
                  );
                }

                return Container();
              },
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Color(0xff2e2f37),
      child: SizedBox(
        width: 200,
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.search,
              color: Theme.of(context).accentColor,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "Search ",
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor,
                  fontSize: 18,
                ),
              ),
            ),
            TypewriterAnimatedTextKit(
              onTap: () => Navigator.pushNamed(
                context,
                searchPage,
                arguments: commands,
              ),
              speed: Duration(milliseconds: 200),
              isRepeatingAnimation: false,
              text: ["tldr_____"],
              textStyle: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
      onPressed: () => Navigator.pushNamed(
        context,
        searchPage,
        arguments: commands,
      ),
    );
  }
}

class AboutTldrText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "The ",
          ),
          TextSpan(
            text: "tldr app ",
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  createAboutPageRoute(),
                );
              },
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          ),
          TextSpan(
            text: "is a community effort to simplify the beloved ",
          ),
          TextSpan(
            text: "man pages ",
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch(
                  'https://en.wikipedia.org/wiki/Man_page',
                );
              },
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          ),
          TextSpan(
            text: "with practical examples.",
          ),
        ],
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class RecentsList extends StatefulWidget {
  final List<Command> recentCommands;

  RecentsList({Key? key, required this.recentCommands}) : super(key: key);

  @override
  _RecentsListState createState() => _RecentsListState();
}

class _RecentsListState extends State<RecentsList> {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Text(
            "Recents",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        widget.recentCommands.isEmpty
            ? Center(
                child: Column(
                  children: [
                    Icon(Icons.history),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "No recently searched commands",
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              )
            : widget.recentCommands.length > 2
                ? Column(
                    children: [
                      ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return RecentsTile(index: index);
                        },
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                      ),
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        color: Color(0xff2e2f37),
                        child: MaterialButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            recentsPage,
                          ),
                          child: Text("Show all"),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.recentCommands.length,
                    itemBuilder: (context, index) {
                      return RecentsTile(index: index);
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
      ],
    );
  }
}

class FavoritesList extends StatefulWidget {
  final List<Command> favoritesList;

  FavoritesList({Key? key, required this.favoritesList}) : super(key: key);

  @override
  _FavoritesListState createState() => _FavoritesListState();
}

class _FavoritesListState extends State<FavoritesList> {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Text(
            "Favorites",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        widget.favoritesList.isEmpty
            ? Center(
                child: Column(
                  children: [
                    Icon(Icons.code),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Your favorite commands will appear here",
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              )
            : widget.favoritesList.length > 2
                ? Column(
                    children: [
                      ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return FavoritesTile(index: index);
                        },
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                      ),
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        color: Color(0xff2e2f37),
                        child: MaterialButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            favoritesPage,
                          ),
                          child: Text("Show all"),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.favoritesList.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return FavoritesTile(index: index);
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
      ],
    );
  }
}
