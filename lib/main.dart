import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tldr/command/models/command.dart';
import 'package:tldr/screens/home.dart';
import 'package:tldr/utils/constants.dart';
import 'package:tldr/utils/router.dart';
import 'command/bloc/command_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BlocOverrides.runZoned(() {}, blocObserver: SimpleBlocObserver());
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(CommandAdapter());
  await Hive.openBox(RECENT_COMMANDS);
  await Hive.openBox(FAVORITE_COMMANDS);
  //Hive.box(FAVORITE_COMMANDS).deleteFromDisk();
  runApp(BlocProvider(
    create: (context) => CommandBloc(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'tldr man-pages',
        theme: ThemeData(
          backgroundColor: Color(0xff17181c),
          canvasColor: Color(0xff17181c),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Color(0xff2e8fff),
            brightness: Brightness.dark,
          ),
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            titleTextStyle: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        home: TLDR(),
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}

// Logs events and states during transition
class SimpleBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
