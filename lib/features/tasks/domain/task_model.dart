import 'package:hive/hive.dart';

enum TaskStatus { planning, progress, done }

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 1;

  @override
  TaskStatus read(BinaryReader reader) {
    final index = reader.readInt();
    return TaskStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    writer.writeInt(obj.index);
  }
}

class SubtaskModel {
  final String id;
  final String title;
  final bool isCompleted;
  final int estimatedMinutes;

  SubtaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.estimatedMinutes,
  });

  SubtaskModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? estimatedMinutes,
  }) {
    return SubtaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }
}

class SubtaskModelAdapter extends TypeAdapter<SubtaskModel> {
  @override
  final int typeId = 2;

  @override
  SubtaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubtaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
      estimatedMinutes: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SubtaskModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.estimatedMinutes);
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final TaskStatus status;
  final List<SubtaskModel> subtasks;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.createdAt,
    this.status = TaskStatus.planning,
    this.subtasks = const [],
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    TaskStatus? status,
    List<SubtaskModel>? subtasks,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 3;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      createdAt: fields[3] as DateTime,
      status: fields[4] as TaskStatus,
      subtasks: (fields[5] as List?)?.cast<SubtaskModel>() ?? const [],
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.subtasks);
  }
}
