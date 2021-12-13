// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommandAdapter extends TypeAdapter<Command> {
  @override
  final int typeId = 0;

  @override
  Command read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Command(
      name: fields[0] as String,
      platform: fields[1] as String,
      dateTime: fields[2] as DateTime?,
      languages: (fields[3] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Command obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.platform)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.languages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
