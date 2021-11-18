import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'package:tldr/command/models/command.dart';
import 'package:tldr/utils/constants.dart';

part 'command_event.dart';
part 'command_state.dart';

class CommandBloc extends Bloc<CommandEvent, CommandState> {
  CommandBloc() : super(CommandState()) {
    on<AddToHistory>(addToHistory);
    on<AddToFavorite>(addToFavorite);
    on<GetFromHistory>(getFromHistory);
    on<GetFromFavorite>(getFromFavorite);
    on<AppOpened>(getAll);
  }

  Future<void> addToHistory(
    AddToHistory event,
    Emitter<CommandState> emit,
  ) async {
    var box = Hive.box(RECENT_COMMANDS);
    if (box.containsKey(event.command.name)) {
      box.delete(event.command.name);
    }
    box.put(event.command.name, event.command);
  }

  Future addToFavorite(
    AddToFavorite event,
    Emitter<CommandState> emit,
  ) async {
    var box = Hive.box(FAVORITE_COMMANDS);
    if (!box.containsKey(event.command.name)) {
      box.put(event.command.name, event.command);
    } else
      box.delete(event.command.name);
  }

  Future getFromHistory(
    CommandEvent event,
    Emitter<CommandState> emit,
  ) async {
    var box = Hive.box(RECENT_COMMANDS);
    //box.deleteFromDisk();
    List<Command> recentCommands = [];
    for (var i = 0; i < box.length; i++) {
      recentCommands.add(box.getAt(i));
    }
    emit(
      state.copyWith(
        recentCommands: recentCommands,
        status: CommandStatus.getRecent,
      ),
    );
  }

  Future getFromFavorite(
    CommandEvent event,
    Emitter<CommandState> emit,
  ) async {
    var box = Hive.box(FAVORITE_COMMANDS);
    //box.deleteFromDisk();
    List<Command> favoriteCommands = [];
    for (var i = 0; i < box.length; i++) {
      favoriteCommands.add(box.getAt(i));
    }
    emit(
      state.copyWith(
        favoriteCommands: favoriteCommands,
        status: CommandStatus.getFav,
      ),
    );
  }

  Future getAll(
    CommandEvent event,
    Emitter<CommandState> emit,
  ) async {
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
    emit(CommandState(
      favoriteCommands: favoriteCommands,
      recentCommands: recentCommands,
      status: CommandStatus.getAll,
    ));
  }
}
