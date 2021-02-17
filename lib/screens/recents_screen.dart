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
        if (state is CommandState) {
          return ListView.separated(
            physics: BouncingScrollPhysics(),
            itemCount: state.recentCommands.length,
            itemBuilder: (context, index) {
              return RecentsTile(index: index);
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      }),
    );
  }
}
