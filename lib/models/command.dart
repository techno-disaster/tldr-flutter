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
  @HiveField(3, defaultValue: [])
  final List languages;
  Command({
    required this.name,
    required this.platform,
    this.dateTime,
    required this.languages,
  });
  Command copyWith({
    String? name,
    String? platform,
    DateTime? datetime,
    List? languages,
  }) {
    return Command(
      name: name ?? this.name,
      platform: platform ?? this.platform,
      dateTime: dateTime ?? this.dateTime,
      languages: languages ?? this.languages,
    );
  }

  @override
  List<Object?> get props => [name, platform, dateTime, languages];
}
