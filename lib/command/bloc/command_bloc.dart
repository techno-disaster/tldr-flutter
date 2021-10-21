import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'package:tldr/command/models/command.dart';
import 'package:tldr/utils/constants.dart';

part 'command_event.dart';
part 'command_state.dart';

class CommandBloc extends Bloc<CommandEvent, CommandState> {
  CommandBloc() : super(CommandState());

  @override
  Stream<CommandState> mapEventToState(
    CommandEvent event,
  ) async* {
    if (event is AddToHistory) {
      yield* mapEventToAddToHistory(event);
    } else if (event is GetFromHistory) {
      yield* mapEventToGetFromHistory(event);
    } else if (event is AddToFavorite) {
      yield* mapEventToAddToFavorite(event);
    } else if (event is GetFromFavorite) {
      yield* mapEventToGetFromFavorite(event);
    } else if (event is AppOpened) {
      yield* mapEventToGetAll(event);
    }
  }

  Stream<CommandState> mapEventToAddToHistory(AddToHistory event) async* {
    var box = Hive.box(RECENT_COMMANDS);
    if (box.containsKey(event.command.name)) {
      box.delete(event.command.name);
    }
    box.put(event.command.name, event.command);
  }

  Stream<CommandState> mapEventToGetFromHistory(CommandEvent event) async* {
    var box = Hive.box(RECENT_COMMANDS);
    //box.deleteFromDisk();
    List<Command> recentCommands = [];
    for (var i = 0; i < box.length; i++) {
      recentCommands.add(box.getAt(i));
    }
    yield state.copyWith(
        recentCommands: recentCommands, status: CommandStatus.getRecent);
  }

  Stream<CommandState> mapEventToAddToFavorite(AddToFavorite event) async* {
    var box = Hive.box(FAVORITE_COMMANDS);
    if (!box.containsKey(event.command.name)) {
      box.put(event.command.name, event.command);
    } else
      box.delete(event.command.name);
  }

  Stream<CommandState> mapEventToGetFromFavorite(CommandEvent event) async* {
    var box = Hive.box(FAVORITE_COMMANDS);
    //box.deleteFromDisk();
    List<Command> favoriteCommands = [];
    for (var i = 0; i < box.length; i++) {
      favoriteCommands.add(box.getAt(i));
    }
    yield state.copyWith(
        favoriteCommands: favoriteCommands, status: CommandStatus.getFav);
  }

  Stream<CommandState> mapEventToGetAll(CommandEvent event) async* {
    var favBox = Hive.box(FAVORITE_COMMANDS);
    var recentBox = Hive.box(RECENT_COMMANDS);

    //box.deleteFromDisk();
    List<Command> favoriteCommands = [];
    for (var i = 0; i < favBox.length; i++) {
      favoriteCommands.add(favBox.getAt(i));
    }
    List<Command> recentCommands = [];
    for (var i = 0; i < recentBox.length; i++) {
      recentCommands.add(recentBox.getAt(i));
    }
    yield CommandState(
      favoriteCommands: favoriteCommands,
      recentCommands: recentCommands,
      status: CommandStatus.getAll,
    );
  }
}
