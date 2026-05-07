import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../gamification_notifier.dart';
import '../../models/badge_model.dart';

class BadgeScreen extends ConsumerWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamificationState = ref.watch(gamificationNotifierProvider);
    final badges = gamificationState.badges;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Achievements', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          return _buildBadgeCard(context, badge, isDark);
        },
      ),
    );
  }

  Widget _buildBadgeCard(BuildContext context, BadgeModel badge, bool isDark) {
    final bool unlocked = badge.isUnlocked;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked ? (isDark ? const Color(0xFF2C2C3E) : Colors.white) : (isDark ? const Color(0xFF1E1E2C) : Colors.grey[100]),
        borderRadius: BorderRadius.circular(24),
        border: unlocked ? Border.all(color: const Color(0xFF6534FF), width: 2) : Border.all(color: Colors.transparent),
        boxShadow: unlocked && !isDark ? [
          BoxShadow(color: const Color(0xFF6534FF).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
        ] : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: unlocked ? const Color(0xFF6534FF).withOpacity(0.1) : Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: ColorFiltered(
              colorFilter: unlocked 
                  ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                  : const ColorFilter.matrix(<double>[
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0,      0,      0,      1, 0,
                    ]), // Grayscale filter
              child: Text(
                badge.iconName,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: unlocked ? (isDark ? Colors.white : Colors.black) : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          if (unlocked) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1DD1A1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Unlocked', style: TextStyle(color: Color(0xFF1DD1A1), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ] else ...[
             const SizedBox(height: 12),
             const Icon(Icons.lock_rounded, color: Colors.grey, size: 16),
          ]
        ],
      ),
    );
  }
}
