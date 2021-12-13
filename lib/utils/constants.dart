import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'package:tldr/command/bloc/command_bloc.dart';
import 'package:tldr/command/models/command.dart';
import 'package:tldr/screens/about_app.dart';
import 'package:tldr/screens/command_details.dart';

const String RECENT_COMMANDS = "recent_commands";
const String FAVORITE_COMMANDS = "favorite_commands";
const String PAGES_INFO_BOX =
    "pages_info_box"; // stores version number and locale
final String aboutApp =
    "The [tldr-pages](https://github.com/tldr-pages/tldr) project is a collection of community-maintained help pages for command-line tools, that aims to be a simpler, more approachable complement to traditional [man pages](https://en.wikipedia.org/wiki/Man_page).\n\nMaybe you are new to the command-line world? Or just a little rusty?\nOr perhaps you can't always remember the arguments to `lsof`, or `tar`?\n\nIt certainly doesn't help that the first option explained in `man tar` is:\n ``` -b blocksize Specify the block size, in 512-byte records, for tape drive I/O. As a rule, this argument is only needed when reading from or writing to tape drives, and usually not even then as the default block size of 20 records (10240 bytes) is very common. ```\n\nThere seems to be room for simpler help pages, focused on practical examples.\n\nThis repository is just that: an ever-growing collection of examples\nfor the most common UNIX, Linux, macOS, SunOS and Windows command-line tools.";

final String flareURL =
    "https://flare.rive.app/a/cvl/files/flare/site-animaton/embed";

final String iconURL = "https://github.com/tldr-pages";
final String appURL = "https://github.com/Techno-Disaster/tldr-flutter";

final String baseURL = "https://github.com/tldr-pages/tldr/blob/main/pages/";
String formatDuration(Duration d) {
  var seconds = d.inSeconds;
  final days = seconds ~/ Duration.secondsPerDay;
  seconds -= days * Duration.secondsPerDay;
  final hours = seconds ~/ Duration.secondsPerHour;
  seconds -= hours * Duration.secondsPerHour;
  final minutes = seconds ~/ Duration.secondsPerMinute;
  seconds -= minutes * Duration.secondsPerMinute;

  final List<String> tokens = [];
  if (days != 0) {
    return '${days}d ago';
    //tokens.add('${days}d');
  }
  if (tokens.isNotEmpty || hours != 0) {
    return '${hours}h ago';
    // tokens.add('${hours}h');
  }
  if (tokens.isNotEmpty || minutes != 0) {
    return '${minutes}m ago';
    // tokens.add('${minutes}m');
  }
  return '${seconds}s ago';
  //tokens.add('${seconds}s');

  //return tokens.join(':');
}

Route createCommandDetailsRoute(Command command) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        CommandDetails(command: command),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}

Route createAboutPageRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AboutApp(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}

showAlertDialog(BuildContext context, Command command) {
  final favCountriesBox = Hive.box(FAVORITE_COMMANDS);
  AlertDialog alert = AlertDialog(
    backgroundColor: Theme.of(context).backgroundColor,
    title: Text("Delete ${command.name} from your favorites?"),
    actions: [
      MaterialButton(
        child: Text("Cancel"),
        onPressed: () => Navigator.pop(context),
      ),
      MaterialButton(
        child: Text("Yes"),
        onPressed: () => {
          favCountriesBox.delete(command.name),
          BlocProvider.of<CommandBloc>(context).add(
            GetFromFavorite(),
          ),
          Navigator.pop(context),
        },
      ),
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Widget getIcon(BuildContext context, Command command) {
  final favCountriesBox = Hive.box(FAVORITE_COMMANDS);
  if (favCountriesBox.containsKey(command.name)) {
    return InkWell(
      onTap: () => showAlertDialog(context, command),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Icon(
          Icons.favorite,
          color: Colors.redAccent,
        ),
      ),
    );
  }
  return InkWell(
    onTap: () {
      Command c = Command(
        name: command.name,
        platform: command.platform,
        dateTime: DateTime.now(),
        languages: command.languages,
      );
      BlocProvider.of<CommandBloc>(context).add(
        AddToFavorite(c),
      );
      BlocProvider.of<CommandBloc>(context).add(
        GetFromFavorite(),
      );
    },
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Icon(Icons.favorite_border),
    ),
  );
}

class MyIcons {
  MyIcons._();
  static const _kFontFam = 'icons';
  static const String? _kFontPkg = null;
  static const IconData linux_1 =
      IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData windows =
      IconData(0xf17a, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData app_store_ios =
      IconData(0xf370, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}
