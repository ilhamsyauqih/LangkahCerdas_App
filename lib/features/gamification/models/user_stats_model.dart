import 'package:hive/hive.dart';

class UserStatsModel {
  final int totalXP;
  final int level;
  final int streakDays;
  final DateTime lastActiveDate;

  UserStatsModel({
    this.totalXP = 0,
    this.level = 1,
    this.streakDays = 0,
    DateTime? lastActiveDate,
  }) : lastActiveDate = lastActiveDate ?? DateTime.now();

  UserStatsModel copyWith({
    int? totalXP,
    int? level,
    int? streakDays,
    DateTime? lastActiveDate,
  }) {
    return UserStatsModel(
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}

class UserStatsModelAdapter extends TypeAdapter<UserStatsModel> {
  @override
  final int typeId = 4;

  @override
  UserStatsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStatsModel(
      totalXP: fields[0] as int,
      level: fields[1] as int,
      streakDays: fields[2] as int,
      lastActiveDate: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserStatsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.totalXP)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.streakDays)
      ..writeByte(3)
      ..write(obj.lastActiveDate);
  }
}
