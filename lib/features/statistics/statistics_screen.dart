import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../tasks/domain/task_model.dart';
import '../tasks/presentation/task_notifier.dart';
import '../auth/presentation/auth_notifier.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskNotifierProvider);
    final userState = ref.watch(authNotifierProvider);
    final user = userState.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    int totalTasks = tasks.length;
    int completedTasks = tasks.where((t) => t.status == TaskStatus.done).length;
    
    int totalSubtasks = tasks.fold(0, (sum, t) => sum + t.subtasks.length);
    int completedSubtasks = tasks.fold(0, (sum, t) => sum + t.subtasks.where((st) => st.isCompleted).length);
    
    int focusMinutes = tasks.fold(0, (sum, t) => sum + t.subtasks.where((st) => st.isCompleted).fold(0, (s, st) => s + st.estimatedMinutes));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profil & Statistik', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- PROFILE SECTION ---
            _buildProfileSection(context, ref, user, isDark),
            
            const SizedBox(height: 48),
            
            // --- STATISTICS SECTION ---
            const Text('Ringkasan Aktivitas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),
            
            // Streak Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 48)
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scaleXY(end: 1.1, duration: 1.seconds),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Streak Anda', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                        const Text('3 Hari', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        Text('Pertahankan momentum!', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildStatCard(context, 'Tugas Selesai', '$completedTasks/$totalTasks', Icons.check_circle_outline, 300.ms, isDark)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(context, 'Langkah Selesai', '$completedSubtasks/$totalSubtasks', Icons.done_all, 400.ms, isDark)),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatCard(context, 'Total Waktu Fokus', '$focusMinutes Menit', Icons.timer_outlined, 500.ms, isDark),
            
            const SizedBox(height: 48),
            Center(
              child: Text(
                '“Satu langkah kecil lebih baik daripada niat besar yang tidak pernah dimulai.”',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
              ).animate().fadeIn(delay: 800.ms),
            ),
            
            const SizedBox(height: 100), // padding for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, WidgetRef ref, dynamic user, bool isDark) {
    if (user == null) return const SizedBox.shrink();

    // Parse icon from avatar string
    IconData avatarIcon = Icons.person;
    if (user.avatar != null) {
      int? code = int.tryParse(user.avatar!);
      if (code != null) {
        avatarIcon = IconData(code, fontFamily: 'MaterialIcons');
      }
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                border: Border.all(color: Theme.of(context).primaryColor, width: 2),
              ),
              child: Icon(avatarIcon, size: 50, color: Theme.of(context).primaryColor),
            ),
            GestureDetector(
              onTap: () => _showAvatarPicker(context, ref, user.name),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF6534FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ).animate().scale(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showEditNameDialog(context, ref, user.name, user.avatar),
              child: Icon(Icons.edit_outlined, size: 20, color: Colors.grey[600]),
            ),
          ],
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ).animate().fadeIn(delay: 100.ms),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Duration delay, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    ).animate().fadeIn(delay: delay).slideX();
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName, String? currentAvatar) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nama'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Nama Lengkap'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                ref.read(authNotifierProvider.notifier).updateProfile(ctrl.text, currentAvatar);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, WidgetRef ref, String currentName) {
    final icons = [
      Icons.person,
      Icons.face,
      Icons.emoji_emotions,
      Icons.pets,
      Icons.rocket_launch,
      Icons.star,
      Icons.lightbulb,
      Icons.water_drop,
      Icons.forest,
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Avatar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: icons.map((icon) {
                return GestureDetector(
                  onTap: () {
                    ref.read(authNotifierProvider.notifier).updateProfile(currentName, icon.codePoint.toString());
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    child: Icon(icon, color: Theme.of(context).primaryColor, size: 30),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
