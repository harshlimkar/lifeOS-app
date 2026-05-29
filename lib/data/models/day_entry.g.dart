// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DayEntryAdapter extends TypeAdapter<DayEntry> {
  @override
  final int typeId = 0;

  @override
  DayEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayEntry(
      dateKey: fields[0] as String,
      createdAt: fields[12] as DateTime,
      completedMissions: (fields[1] as List).cast<String>(),
      waterIntakeLiters: fields[2] as double,
      workoutCompleted: fields[3] as bool,
      focusMinutes: fields[4] as int,
      instagramMinutes: fields[5] as int,
      youtubeMinutes: fields[6] as int,
      journalWentWell: fields[7] as String,
      journalWastedTime: fields[8] as String,
      journalImprove: fields[9] as String,
      xpEarned: fields[10] as int,
      isPerfectDay: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DayEntry obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.dateKey)
      ..writeByte(1)
      ..write(obj.completedMissions)
      ..writeByte(2)
      ..write(obj.waterIntakeLiters)
      ..writeByte(3)
      ..write(obj.workoutCompleted)
      ..writeByte(4)
      ..write(obj.focusMinutes)
      ..writeByte(5)
      ..write(obj.instagramMinutes)
      ..writeByte(6)
      ..write(obj.youtubeMinutes)
      ..writeByte(7)
      ..write(obj.journalWentWell)
      ..writeByte(8)
      ..write(obj.journalWastedTime)
      ..writeByte(9)
      ..write(obj.journalImprove)
      ..writeByte(10)
      ..write(obj.xpEarned)
      ..writeByte(11)
      ..write(obj.isPerfectDay)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
