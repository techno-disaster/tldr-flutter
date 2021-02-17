part of 'command_bloc.dart';

enum CommandStatus { getAll, getFav, getRecent }

class CommandState extends Equatable {
  final List<Command> favoriteCommands;
  final List<Command> recentCommands;
  final CommandStatus status;
  const CommandState(
      {this.favoriteCommands = const <Command>[],
      this.recentCommands = const <Command>[],
      this.status = CommandStatus.getAll});

  CommandState copyWith(
          {List<Command>? favoriteCommands,
          List<Command>? recentCommands,
          CommandStatus? status}) =>
      CommandState(
          favoriteCommands: favoriteCommands ?? this.favoriteCommands,
          recentCommands: recentCommands ?? this.recentCommands,
          status: status ?? this.status);
  @override
  List<Object> get props => [favoriteCommands, recentCommands, status];
  @override
  String toString() => 'CommandState { Status : $status }';
}
