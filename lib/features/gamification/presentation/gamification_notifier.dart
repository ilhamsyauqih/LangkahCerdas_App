import 'dart:math';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/gamification_repository.dart';
import '../models/user_stats_model.dart';
import '../models/badge_model.dart';

final gamificationRepositoryProvider = Provider((ref) => GamificationRepository());

class GamificationState {
  final UserStatsModel stats;
  final List<BadgeModel> badges;
  final int newlyUnlockedLevel; 
  final List<BadgeModel> newlyUnlockedBadges;

  GamificationState({
    required this.stats,
    required this.badges,
    this.newlyUnlockedLevel = 0,
    this.newlyUnlockedBadges = const [],
  });

  GamificationState copyWith({
    UserStatsModel? stats,
    List<BadgeModel>? badges,
    int? newlyUnlockedLevel,
    List<BadgeModel>? newlyUnlockedBadges,
  }) {
    return GamificationState(
      stats: stats ?? this.stats,
      badges: badges ?? this.badges,
      newlyUnlockedLevel: newlyUnlockedLevel ?? this.newlyUnlockedLevel,
      newlyUnlockedBadges: newlyUnlockedBadges ?? this.newlyUnlockedBadges,
    );
  }
}

final gamificationNotifierProvider = NotifierProvider<GamificationNotifier, GamificationState>(GamificationNotifier.new);

class GamificationNotifier extends Notifier<GamificationState> {
  late GamificationRepository _repository;

  @override
  GamificationState build() {
    _repository = ref.watch(gamificationRepositoryProvider);
    _checkAndUpdateStreak();
    return GamificationState(
      stats: _repository.getStats(),
      badges: _repository.getBadges(),
    );
  }

  void _checkAndUpdateStreak() {
    final stats = _repository.getStats();
    final now = DateTime.now();
    final lastActive = stats.lastActiveDate;
    
    final difference = DateTime(now.year, now.month, now.day)
        .difference(DateTime(lastActive.year, lastActive.month, lastActive.day))
        .inDays;

    if (difference > 1) {
      final updatedStats = stats.copyWith(streakDays: 0, lastActiveDate: now);
      _repository.saveStats(updatedStats);
    }
  }

  Future<void> addXP(int amount) async {
    final currentStats = state.stats;
    int newXP = currentStats.totalXP + amount;
    int newLevel = sqrt(newXP / 100).floor() + 1;
    
    final now = DateTime.now();
    final lastActive = currentStats.lastActiveDate;
    final difference = DateTime(now.year, now.month, now.day)
        .difference(DateTime(lastActive.year, lastActive.month, lastActive.day))
        .inDays;
        
    int newStreak = currentStats.streakDays;
    if (difference == 1) {
      newStreak += 1;
    } else if (difference > 1) {
      newStreak = 1; 
    } else if (newStreak == 0) {
      newStreak = 1; 
    }

    final updatedStats = currentStats.copyWith(
      totalXP: newXP,
      level: newLevel,
      streakDays: newStreak,
      lastActiveDate: now,
    );

    await _repository.saveStats(updatedStats);

    bool leveledUp = newLevel > currentStats.level;
    
    List<BadgeModel> newlyUnlocked = [];
    final allBadges = List<BadgeModel>.from(state.badges);
    
    // Beginner: b1
    if (newXP >= 50 && !allBadges.firstWhere((b) => b.id == 'b1').isUnlocked) {
      final index = allBadges.indexWhere((b) => b.id == 'b1');
      allBadges[index] = allBadges[index].copyWith(isUnlocked: true, unlockedAt: now);
      _repository.updateBadge(allBadges[index]);
      newlyUnlocked.add(allBadges[index]);
    }
    
    // Consistent: b2
    if (newStreak >= 7 && !allBadges.firstWhere((b) => b.id == 'b2').isUnlocked) {
      final index = allBadges.indexWhere((b) => b.id == 'b2');
      allBadges[index] = allBadges[index].copyWith(isUnlocked: true, unlockedAt: now);
      _repository.updateBadge(allBadges[index]);
      newlyUnlocked.add(allBadges[index]);
    }
    
    // Night worker: b4
    if (now.hour >= 22 && !allBadges.firstWhere((b) => b.id == 'b4').isUnlocked) {
      final index = allBadges.indexWhere((b) => b.id == 'b4');
      allBadges[index] = allBadges[index].copyWith(isUnlocked: true, unlockedAt: now);
      _repository.updateBadge(allBadges[index]);
      newlyUnlocked.add(allBadges[index]);
    }

    state = state.copyWith(
      stats: updatedStats,
      badges: allBadges,
      newlyUnlockedLevel: leveledUp ? newLevel : 0,
      newlyUnlockedBadges: newlyUnlocked,
    );
  }

  void clearLevelUpEvent() {
    state = state.copyWith(newlyUnlockedLevel: 0, newlyUnlockedBadges: []);
  }
}
