import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../domain/task_model.dart';

class TaskRepository {
  static const String _tasksBox = 'tasks';
  final _uuid = const Uuid();

  List<TaskModel> getTasks() {
    final box = Hive.box<TaskModel>(_tasksBox);
    return box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<TaskModel> addTask(String title, String description) async {
    final box = Hive.box<TaskModel>(_tasksBox);
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      status: TaskStatus.planning,
    );
    await box.put(task.id, task);
    return task;
  }

  Future<void> updateTask(TaskModel task) async {
    final box = Hive.box<TaskModel>(_tasksBox);
    await box.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    final box = Hive.box<TaskModel>(_tasksBox);
    await box.delete(id);
  }
}
