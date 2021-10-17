import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tldr/command/bloc/command_bloc.dart';
import 'package:tldr/utils/recents_tile.dart';

class RecentsSreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff17181c),
      appBar: AppBar(
        elevation: 0,
        title: Text("Recent Commands"),
        backgroundColor: Color(0xff17181c),
      ),
      body: BlocBuilder<CommandBloc, CommandState>(builder: (context, state) {
        return state.recentCommands.isNotEmpty
            ? ListView.separated(
                physics: BouncingScrollPhysics(),
                itemCount: state.recentCommands.length,
                itemBuilder: (context, index) {
                  return RecentsTile(index: index);
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
                      "No recently searched commands",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
      }),
    );
  }
}
