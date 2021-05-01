import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tldr/command/bloc/command_bloc.dart';
import 'package:tldr/command/models/command.dart';
import 'package:tldr/utils/commands_tile.dart';
import 'package:tldr/utils/constants.dart';

class AllCommandsScreen extends StatelessWidget {
  final List<Command> commands;

  const AllCommandsScreen({Key? key, required this.commands}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff17181c),
      appBar: AppBar(
        elevation: 0,
        title: Text("All Commands"),
        backgroundColor: Color(0xff17181c),
      ),
      body: Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.shuffle),
            backgroundColor: Color(0xff2e2f37),
            onPressed: () {
              Command command = (commands.toList()..shuffle()).first;
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
            }),
        body: commands.isNotEmpty
            ? ListView.separated(
                physics: BouncingScrollPhysics(),
                itemCount: commands.length,
                itemBuilder: (context, index) {
                  return AllCommandsTile(
                      index: index, command: commands[index]);
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Unable to fetch commands.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
