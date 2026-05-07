import 'package:hive/hive.dart';

class BadgeModel {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  BadgeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

class BadgeModelAdapter extends TypeAdapter<BadgeModel> {
  @override
  final int typeId = 5;

  @override
  BadgeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BadgeModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      iconName: fields[3] as String,
      isUnlocked: fields[4] as bool,
      unlockedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BadgeModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconName)
      ..writeByte(4)
      ..write(obj.isUnlocked)
      ..writeByte(5)
      ..write(obj.unlockedAt);
  }
}
