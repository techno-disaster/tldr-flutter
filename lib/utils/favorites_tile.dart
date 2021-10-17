import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tldr/command/bloc/command_bloc.dart';
import 'package:tldr/command/models/command.dart';
import 'package:tldr/utils/constants.dart';

class FavoritesTile extends StatelessWidget {
  final int index;

  const FavoritesTile({Key? key, required this.index}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommandBloc, CommandState>(
      builder: (context, state) {
        state.favoriteCommands
            .sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
        List<Command> favoriteCommands =
            state.favoriteCommands.reversed.toList();
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              createCommandDetailsRoute(
                favoriteCommands[index],
              ),
            );
            Command c = Command(
                name: favoriteCommands[index].name,
                platform: favoriteCommands[index].platform,
                dateTime: DateTime.now());
            BlocProvider.of<CommandBloc>(context).add(
              AddToHistory(c),
            );
            BlocProvider.of<CommandBloc>(context).add(
              GetFromHistory(),
            );
          },
          leading: Icon(
            Icons.code,
            color: Colors.blueAccent,
          ),
          title: Text(favoriteCommands[index].name),
          subtitle: Text(favoriteCommands[index].platform),
          trailing: getIcon(context, favoriteCommands[index]),
        );
      },
    );
  }
}
