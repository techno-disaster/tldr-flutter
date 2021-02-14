import 'package:flutter/material.dart';
import 'package:tldr/models/commad.dart';
import 'package:tldr/screens/command_details.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case commandDetails:
        final Command command = settings.arguments as Command;
        print(command);
        return MaterialPageRoute<void>(
          settings: RouteSettings(name: settings.name),
          builder: (_) => CommandDetails(command: command),
        );
      default:
        return MaterialPageRoute<void>(
          settings: RouteSettings(name: settings.name),
          builder: (_) => Scaffold(
            body: Text('No route found'),
          ),
        );
    }
  }
}

const commandDetails = '/commandDetails';
