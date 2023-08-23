import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'package:tldr/blocs/command_bloc/command_bloc.dart';
import 'package:tldr/models/command.dart';
import 'package:tldr/screens/about_app.dart';
import 'package:tldr/screens/command_details.dart';

const String RECENT_COMMANDS = "recent_commands";
const String FAVORITE_COMMANDS = "favorite_commands";
const String PAGES_INFO_BOX =
    "pages_info_box"; // stores version number, locale and supported languages

// TODO: translate these strings
final String aboutApp =
    "The [tldr-pages](https://github.com/tldr-pages/tldr) project is a collection of community-maintained help pages for command-line tools, that aims to be a simpler, more approachable complement to traditional [man pages](https://en.wikipedia.org/wiki/Man_page).\n\nMaybe you are new to the command-line world? Or just a little rusty?\nOr perhaps you can't always remember the arguments to `lsof`, or `tar`?\n\nIt certainly doesn't help that the first option explained in `man tar` is:\n ``` -b blocksize Specify the block size, in 512-byte records, for tape drive I/O. As a rule, this argument is only needed when reading from or writing to tape drives, and usually not even then as the default block size of 20 records (10240 bytes) is very common. ```\n\nThere seems to be room for simpler help pages, focused on practical examples.\n\nThis repository is just that: an ever-growing collection of examples\nfor the most common UNIX, Linux, macOS, SunOS and Windows command-line tools.";

final String flareURL =
    "https://flare.rive.app/a/cvl/files/flare/site-animaton/embed";

final String iconURL = "https://github.com/tldr-pages";
final String appURL = "https://github.com/techno-disaster/tldr-flutter";

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
    backgroundColor: Theme.of(context).colorScheme.background,
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

class FavoriteIcon extends StatefulWidget {
  final Command command;
  const FavoriteIcon({Key? key, required this.command}) : super(key: key);

  @override
  State<FavoriteIcon> createState() => _FavoriteIconState();
}

class _FavoriteIconState extends State<FavoriteIcon> {
  final favCountriesBox = Hive.box(FAVORITE_COMMANDS);

  @override
  Widget build(BuildContext context) {
    if (favCountriesBox.containsKey(widget.command.name)) {
      return InkWell(
        onTap: () => showAlertDialog(context, widget.command),
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
          name: widget.command.name,
          platform: widget.command.platform,
          dateTime: DateTime.now(),
          languages: widget.command.languages,
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

// [to_entries[] | {(.key):(.value | .name)} ] | add
// https://github.com/haliaeetus/iso-639/blob/master/data/iso_639-1.json
class ISO639ToCountry {
  static const countryData = {
    "aa": "Afar",
    "ab": "Abkhaz",
    "ae": "Avestan",
    "af": "Afrikaans",
    "ak": "Akan",
    "am": "Amharic",
    "an": "Aragonese",
    "ar": "Arabic",
    "as": "Assamese",
    "av": "Avaric",
    "ay": "Aymara",
    "az": "Azerbaijani",
    "ba": "Bashkir",
    "be": "Belarusian",
    "bg": "Bulgarian",
    "bh": "Bihari",
    "bi": "Bislama",
    "bm": "Bambara",
    "bn": "Bengali, Bangla",
    "bo": "Tibetan Standard, Tibetan, Central",
    "br": "Breton",
    "bs": "Bosnian",
    "ca": "Catalan",
    "ce": "Chechen",
    "ch": "Chamorro",
    "co": "Corsican",
    "cr": "Cree",
    "cs": "Czech",
    "cu": "Old Church Slavonic, Church Slavonic, Old Bulgarian",
    "cv": "Chuvash",
    "cy": "Welsh",
    "da": "Danish",
    "de": "German",
    "dv": "Divehi, Dhivehi, Maldivian",
    "dz": "Dzongkha",
    "ee": "Ewe",
    "el": "Greek (modern)",
    "en": "English",
    "eo": "Esperanto",
    "es": "Spanish",
    "et": "Estonian",
    "eu": "Basque",
    "fa": "Persian (Farsi)",
    "ff": "Fula, Fulah, Pulaar, Pular",
    "fi": "Finnish",
    "fj": "Fijian",
    "fo": "Faroese",
    "fr": "French",
    "fy": "Western Frisian",
    "ga": "Irish",
    "gd": "Scottish Gaelic, Gaelic",
    "gl": "Galician",
    "gn": "Guaraní",
    "gu": "Gujarati",
    "gv": "Manx",
    "ha": "Hausa",
    "he": "Hebrew (modern)",
    "hi": "Hindi",
    "ho": "Hiri Motu",
    "hr": "Croatian",
    "ht": "Haitian, Haitian Creole",
    "hu": "Hungarian",
    "hy": "Armenian",
    "hz": "Herero",
    "ia": "Interlingua",
    "id": "Indonesian",
    "ie": "Interlingue",
    "ig": "Igbo",
    "ii": "Nuosu",
    "ik": "Inupiaq",
    "io": "Ido",
    "is": "Icelandic",
    "it": "Italian",
    "iu": "Inuktitut",
    "ja": "Japanese",
    "jv": "Javanese",
    "ka": "Georgian",
    "kg": "Kongo",
    "ki": "Kikuyu, Gikuyu",
    "kj": "Kwanyama, Kuanyama",
    "kk": "Kazakh",
    "kl": "Kalaallisut, Greenlandic",
    "km": "Khmer",
    "kn": "Kannada",
    "ko": "Korean",
    "kr": "Kanuri",
    "ks": "Kashmiri",
    "ku": "Kurdish",
    "kv": "Komi",
    "kw": "Cornish",
    "ky": "Kyrgyz",
    "la": "Latin",
    "lb": "Luxembourgish, Letzeburgesch",
    "lg": "Ganda",
    "li": "Limburgish, Limburgan, Limburger",
    "ln": "Lingala",
    "lo": "Lao",
    "lt": "Lithuanian",
    "lu": "Luba-Katanga",
    "lv": "Latvian",
    "mg": "Malagasy",
    "mh": "Marshallese",
    "mi": "Māori",
    "mk": "Macedonian",
    "ml": "Malayalam",
    "mn": "Mongolian",
    "mr": "Marathi (Marāṭhī)",
    "ms": "Malay",
    "mt": "Maltese",
    "my": "Burmese",
    "na": "Nauruan",
    "nb": "Norwegian Bokmål",
    "nd": "Northern Ndebele",
    "ne": "Nepali",
    "ng": "Ndonga",
    "nl": "Dutch",
    "nn": "Norwegian Nynorsk",
    "no": "Norwegian",
    "nr": "Southern Ndebele",
    "nv": "Navajo, Navaho",
    "ny": "Chichewa, Chewa, Nyanja",
    "oc": "Occitan",
    "oj": "Ojibwe, Ojibwa",
    "om": "Oromo",
    "or": "Oriya",
    "os": "Ossetian, Ossetic",
    "pa": "(Eastern) Punjabi",
    "pi": "Pāli",
    "pl": "Polish",
    "ps": "Pashto, Pushto",
    "pt": "Portuguese",
    "qu": "Quechua",
    "rm": "Romansh",
    "rn": "Kirundi",
    "ro": "Romanian",
    "ru": "Russian",
    "rw": "Kinyarwanda",
    "sa": "Sanskrit (Saṁskṛta)",
    "sc": "Sardinian",
    "sd": "Sindhi",
    "se": "Northern Sami",
    "sg": "Sango",
    "si": "Sinhalese, Sinhala",
    "sk": "Slovak",
    "sl": "Slovene",
    "sm": "Samoan",
    "sn": "Shona",
    "so": "Somali",
    "sq": "Albanian",
    "sr": "Serbian",
    "ss": "Swati",
    "st": "Southern Sotho",
    "su": "Sundanese",
    "sv": "Swedish",
    "sw": "Swahili",
    "ta": "Tamil",
    "te": "Telugu",
    "tg": "Tajik",
    "th": "Thai",
    "ti": "Tigrinya",
    "tk": "Turkmen",
    "tl": "Tagalog",
    "tn": "Tswana",
    "to": "Tonga (Tonga Islands)",
    "tr": "Turkish",
    "ts": "Tsonga",
    "tt": "Tatar",
    "tw": "Twi",
    "ty": "Tahitian",
    "ug": "Uyghur",
    "uk": "Ukrainian",
    "ur": "Urdu",
    "uz": "Uzbek",
    "ve": "Venda",
    "vi": "Vietnamese",
    "vo": "Volapük",
    "wa": "Walloon",
    "wo": "Wolof",
    "xh": "Xhosa",
    "yi": "Yiddish",
    "yo": "Yoruba",
    "za": "Zhuang, Chuang",
    "zh": "Chinese",
    "zu": "Zulu"
  };
}
