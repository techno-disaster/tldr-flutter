import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tldr/command/bloc/command_bloc.dart';
import 'package:tldr/command/models/command.dart';
import 'package:tldr/utils/constants.dart';

class RecentsTile extends StatelessWidget {
  final int index;

  const RecentsTile({Key? key, required this.index}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommandBloc, CommandState>(
      builder: (context, state) {
        state.recentCommands.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
        List<Command> recentCommands = state.recentCommands.reversed.toList();
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              createCommandDetailsRoute(
                recentCommands[index],
              ),
            );
            Command c = Command(
                name: recentCommands[index].name,
                platform: recentCommands[index].platform,
                dateTime: DateTime.now());
            BlocProvider.of<CommandBloc>(context).add(
              AddToHistory(c),
            );
            BlocProvider.of<CommandBloc>(context).add(
              GetFromHistory(),
            );
          },
          leading: Icon(
            Icons.history,
            color: Colors.blueAccent,
          ),
          title: Text(recentCommands[index].name),
          subtitle: Text(recentCommands[index].platform),
          trailing: Text(
            formatDuration(
              DateTime.now().difference(
                recentCommands[index].dateTime!,
              ),
            ),
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }
}
