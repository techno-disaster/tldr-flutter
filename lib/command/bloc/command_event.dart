part of 'command_bloc.dart';

abstract class CommandEvent extends Equatable {
  const CommandEvent();

  @override
  List<Object> get props => [];
}

class AddToHistory extends CommandEvent {
  final Command command;

  AddToHistory(this.command);
  @override
  List<Object> get props => [command];
}

class AddToFavorite extends CommandEvent {
  final Command command;

  AddToFavorite(this.command);
  @override
  List<Object> get props => [command];
}

class GetFromHistory extends CommandEvent {}

class GetFromFavorite extends CommandEvent {}

class AppOpened extends CommandEvent {}
