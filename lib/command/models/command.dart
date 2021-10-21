import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'command.g.dart';

@HiveType(typeId: 0)
class Command extends Equatable {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String platform;
  @HiveField(2)
  final DateTime? dateTime;

  Command({required this.name, required this.platform, this.dateTime});
  Command copyWith({
    String? name,
    String? platform,
    DateTime? datetime,
  }) {
    return Command(
        name: name ?? this.name,
        platform: platform ?? this.platform,
        dateTime: dateTime ?? this.dateTime);
  }

  @override
  List<Object?> get props => [name, platform, dateTime];
}
