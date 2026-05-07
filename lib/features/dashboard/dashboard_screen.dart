import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../tasks/domain/task_model.dart';
import '../tasks/presentation/task_notifier.dart';
import '../auth/presentation/auth_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskNotifierProvider);
    final userState = ref.watch(authNotifierProvider);
    final userName = userState.value?.name ?? 'User';

    // Calculate progress
    int totalTasks = tasks.length;
    int completedTasks = tasks.where((t) => t.status == TaskStatus.done).length;
    double overallProgress = totalTasks == 0 ? 0 : completedTasks / totalTasks;

    final inProgressTasks = tasks.where((t) => t.status == TaskStatus.progress).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nextAction = ref.watch(nextActionProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false, // Let MainLayout handle bottom padding
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 100), // Bottom padding for nav bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, userName, isDark),
              const SizedBox(height: 24),
              _buildHeroCard(context, overallProgress, nextAction),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'In Progress', inProgressTasks.length.toString(), isDark),
              const SizedBox(height: 16),
              _buildInProgressList(context, inProgressTasks, isDark),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Task Groups', tasks.length.toString(), isDark),
              const SizedBox(height: 16),
              _buildTaskGroupsList(context, tasks, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, bool isDark) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'), // Placeholder image
        ).animate().scale(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello!', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 14)),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ).animate().fadeIn().slideX(),
        ),
        Stack(
          children: [
            const Icon(Icons.notifications_none_rounded, size: 28),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF6534FF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ).animate().scale(delay: 200.ms),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, double progress, NextActionData? nextAction) {
    int percent = (progress * 100).toInt();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF6534FF), // Deep purple
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6534FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextAction != null ? "Waktunya fokus pada:\n${nextAction.subtask.title}" : "Your today's task\nalmost done!",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (nextAction != null) {
                          context.push('/timer/${nextAction.task.id}/${nextAction.subtask.id}');
                        } else {
                          context.push('/tasks');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6534FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(nextAction != null ? 'Mulai Fokus' : 'View Task', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  Text('$percent%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildSectionTitle(BuildContext context, String title, String count, bool isDark) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D3748) : const Color(0xFFEBEBFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count,
            style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF6534FF), fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildInProgressList(BuildContext context, List<TaskModel> inProgressTasks, bool isDark) {
    if (inProgressTasks.isEmpty) {
      return const Text('Tidak ada proyek yang sedang berjalan.', style: TextStyle(color: Colors.grey));
    }
    
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: inProgressTasks.length,
        itemBuilder: (context, index) {
          final task = inProgressTasks[index];
          // Alternate colors for variety
          final bgColor = index % 2 == 0 
              ? (isDark ? const Color(0xFF1A365D) : const Color(0xFFE5F0FF)) 
              : (isDark ? const Color(0xFF652B19) : const Color(0xFFFFEFE5));
          final progColor = index % 2 == 0 ? const Color(0xFF0066FF) : const Color(0xFFFF6B00);
          final iconBg = index % 2 == 0 
              ? (isDark ? const Color(0xFF2C5282) : const Color(0xFFFFE5E5)) 
              : (isDark ? const Color(0xFF7B341E) : const Color(0xFFE5FFEF));
          
          double taskProgress = task.subtasks.isEmpty ? 0 : task.subtasks.where((st) => st.isCompleted).length / task.subtasks.length;

          return GestureDetector(
            onTap: () => context.push('/task/${task.id}'),
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Project', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: iconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.work_outline, size: 14, color: isDark ? Colors.white70 : Colors.black45),
                      ),
                    ],
                  ),
                  Text(
                    task.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.2, color: isDark ? Colors.white : Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  LinearProgressIndicator(
                    value: taskProgress,
                    backgroundColor: Colors.white.withOpacity(0.5),
                    color: progColor,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 200 + (index * 100))).slideX(),
          );
        },
      ),
    );
  }

  Widget _buildTaskGroupsList(BuildContext context, List<TaskModel> tasks, bool isDark) {
    if (tasks.isEmpty) {
      return const Text('Belum ada grup tugas.', style: TextStyle(color: Colors.grey));
    }

    return Column(
      children: tasks.map((task) {
        int index = tasks.indexOf(task);
        double progress = task.subtasks.isEmpty ? 0 : task.subtasks.where((st) => st.isCompleted).length / task.subtasks.length;
        int percent = (progress * 100).toInt();

        // Varied colors based on index
        final iconColors = [
          const Color(0xFFFF6B81),
          const Color(0xFF6534FF),
          const Color(0xFFFF9F43),
          const Color(0xFF1DD1A1),
        ];
        final iconBgs = [
          isDark ? const Color(0xFF4A1C24) : const Color(0xFFFFEAEB),
          isDark ? const Color(0xFF1A1A4A) : const Color(0xFFEBEBFF),
          isDark ? const Color(0xFF4A2B1A) : const Color(0xFFFFF0E1),
          isDark ? const Color(0xFF0D3D2E) : const Color(0xFFE1F9F0),
        ];
        final icons = [Icons.work_outline, Icons.person_outline, Icons.menu_book, Icons.home_outlined];

        final cIndex = index % iconColors.length;

        return GestureDetector(
          onTap: () => context.push('/task/${task.id}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgs[cIndex],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icons[cIndex], color: iconColors[cIndex]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('${task.subtasks.length} Tasks', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        backgroundColor: iconColors[cIndex].withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(iconColors[cIndex]),
                      ),
                      Text('$percent%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 300 + (index * 100))).slideY(begin: 0.1),
        );
      }).toList(),
    );
  }
}
