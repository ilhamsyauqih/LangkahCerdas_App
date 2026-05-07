import 'package:hive_flutter/hive_flutter.dart';
import '../../features/auth/domain/user_model.dart';
import '../../features/tasks/domain/task_model.dart';
import '../../features/gamification/models/user_stats_model.dart';
import '../../features/gamification/models/badge_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(TaskStatusAdapter());
    Hive.registerAdapter(SubtaskModelAdapter());
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(UserStatsModelAdapter());
    Hive.registerAdapter(BadgeModelAdapter());
    
    await Hive.openBox<String>('settings');
    await Hive.openBox<UserModel>('users');
    await Hive.openBox<String>('session');
    await Hive.openBox<TaskModel>('tasks');
    await Hive.openBox<UserStatsModel>('userStatsBox');
    await Hive.openBox<BadgeModel>('badgesBox');
  }
}
