import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/task_model.dart';
import '../data/task_repository.dart';
import '../../gamification/presentation/gamification_notifier.dart';

final taskRepositoryProvider = Provider((ref) => TaskRepository());

final taskNotifierProvider = NotifierProvider<TaskNotifier, List<TaskModel>>(TaskNotifier.new);

class TaskNotifier extends Notifier<List<TaskModel>> {
  late TaskRepository _repository;
  final _uuid = const Uuid();

  @override
  List<TaskModel> build() {
    _repository = ref.watch(taskRepositoryProvider);
    return _repository.getTasks();
  }

  Future<void> addTask(String title, String description) async {
    final newTask = await _repository.addTask(title, description);
    state = [newTask, ...state];
  }

  Future<void> updateTask(TaskModel task) async {
    TaskModel updatedTask = task;
    if (task.subtasks.isNotEmpty && task.subtasks.every((st) => st.isCompleted)) {
      updatedTask = task.copyWith(status: TaskStatus.done);
    } else if (task.status == TaskStatus.done && task.subtasks.any((st) => !st.isCompleted)) {
      updatedTask = task.copyWith(status: TaskStatus.progress);
    }
    
    await _repository.updateTask(updatedTask);
    state = state.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
    state = state.where((t) => t.id != id).toList();
  }

  Future<void> addSubtask(String taskId, String title, int estimatedMinutes) async {
    final task = state.firstWhere((t) => t.id == taskId);
    final subtask = SubtaskModel(
      id: _uuid.v4(),
      title: title,
      estimatedMinutes: estimatedMinutes,
    );
    final updatedTask = task.copyWith(subtasks: [...task.subtasks, subtask]);
    await updateTask(updatedTask);
  }

  Future<void> toggleSubtask(String taskId, String subtaskId) async {
    final task = state.firstWhere((t) => t.id == taskId);
    final updatedSubtasks = task.subtasks.map((st) {
      if (st.id == subtaskId) {
        final toggled = st.copyWith(isCompleted: !st.isCompleted);
        if (toggled.isCompleted) {
          int xp = 10;
          if (st.estimatedMinutes >= 60) {
            xp = 50;
          } else if (st.estimatedMinutes >= 30) {
            xp = 25;
          }
          ref.read(gamificationNotifierProvider.notifier).addXP(xp);
        }
        return toggled;
      }
      return st;
    }).toList();
    
    final updatedTask = task.copyWith(subtasks: updatedSubtasks);
    await updateTask(updatedTask);
  }
}

class NextActionData {
  final TaskModel task;
  final SubtaskModel subtask;
  NextActionData(this.task, this.subtask);
}

final nextActionProvider = Provider<NextActionData?>((ref) {
  final tasks = ref.watch(taskNotifierProvider);
  
  final activeTasks = tasks.where((t) => t.status == TaskStatus.progress).toList();
  
  if (activeTasks.isNotEmpty) {
    for (final task in activeTasks) {
      final incompleteSubtasks = task.subtasks.where((st) => !st.isCompleted).toList();
      if (incompleteSubtasks.isNotEmpty) {
        return NextActionData(task, incompleteSubtasks.first);
      }
    }
  }
  
  return null;
});
