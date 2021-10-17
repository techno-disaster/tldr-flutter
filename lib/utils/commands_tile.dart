import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tldr/command/bloc/command_bloc.dart';
import 'package:tldr/command/models/command.dart';
import 'package:tldr/utils/constants.dart';

class AllCommandsTile extends StatelessWidget {
  final int index;
  final Command command;
  final bool hidden;
  final IconData icon;
  const AllCommandsTile(
      {Key? key,
      required this.index,
      required this.command,
      required this.icon,
      required this.hidden})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (!hidden)
      return BlocBuilder<CommandBloc, CommandState>(builder: (context, state) {
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              createCommandDetailsRoute(command),
            );
            Command c = Command(
              name: command.name,
              platform: command.platform,
              dateTime: DateTime.now(),
            );
            BlocProvider.of<CommandBloc>(context).add(
              AddToHistory(c),
            );
            BlocProvider.of<CommandBloc>(context).add(
              GetFromHistory(),
            );
          },
          leading: Icon(
            icon,
            color: Colors.blueAccent,
          ),
          title: Text(command.name),
          subtitle: Text(command.platform),
        );
      });
    else
      return Container();
  }
}
