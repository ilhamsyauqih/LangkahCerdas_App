import 'package:hive/hive.dart';
import '../models/user_stats_model.dart';
import '../models/badge_model.dart';

class GamificationRepository {
  final Box<UserStatsModel> _statsBox;
  final Box<BadgeModel> _badgesBox;

  GamificationRepository()
      : _statsBox = Hive.box<UserStatsModel>('userStatsBox'),
        _badgesBox = Hive.box<BadgeModel>('badgesBox') {
    _initDefaultBadges();
  }

  void _initDefaultBadges() {
    if (_badgesBox.isEmpty) {
      final defaultBadges = [
        BadgeModel(id: 'b1', title: 'Beginner', description: 'Complete 5 tasks', iconName: '🔰'),
        BadgeModel(id: 'b2', title: 'Consistent', description: '7 day streak', iconName: '🔥'),
        BadgeModel(id: 'b3', title: 'Productive', description: 'Complete 50 tasks', iconName: '⚡'),
        BadgeModel(id: 'b4', title: 'Night Worker', description: 'Complete task after 10 PM', iconName: '🦉'),
      ];
      for (var badge in defaultBadges) {
        _badgesBox.put(badge.id, badge);
      }
    }
  }

  UserStatsModel getStats() {
    return _statsBox.get('main', defaultValue: UserStatsModel())!;
  }

  Future<void> saveStats(UserStatsModel stats) async {
    await _statsBox.put('main', stats);
  }

  List<BadgeModel> getBadges() {
    return _badgesBox.values.toList();
  }

  Future<void> updateBadge(BadgeModel badge) async {
    await _badgesBox.put(badge.id, badge);
  }
}
