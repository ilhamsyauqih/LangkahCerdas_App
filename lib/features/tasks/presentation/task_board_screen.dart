import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../domain/task_model.dart';
import 'task_notifier.dart';

class TaskBoardScreen extends ConsumerWidget {
  const TaskBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskNotifierProvider);
    final nextAction = ref.watch(nextActionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final planningTasks = tasks.where((t) => t.status == TaskStatus.planning).toList();
    final progressTasks = tasks.where((t) => t.status == TaskStatus.progress).toList();
    final doneTasks = tasks.where((t) => t.status == TaskStatus.done).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFF), // Very light blue/grey
      appBar: AppBar(
        title: Text('Daftar Tugas', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (nextAction != null) ...[
                _buildUpNextCard(context, ref, nextAction, isDark),
                const SizedBox(height: 32),
              ],
              
              _buildSectionHeader('DAILY PLANNING', planningTasks.length, isDark),
              const SizedBox(height: 16),
              ...planningTasks.map((t) => _buildTaskCard(context, t, isDark)).toList(),
              if (planningTasks.isEmpty) _buildEmptyState('No tasks planned.'),
              
              const SizedBox(height: 32),
              _buildSectionHeader('IN PROGRESS', progressTasks.length, isDark, isBlue: true),
              const SizedBox(height: 16),
              ...progressTasks.map((t) => _buildTaskCard(context, t, isDark, isHighlighted: true)).toList(),
              if (progressTasks.isEmpty) _buildEmptyState('No tasks in progress.'),
              
              const SizedBox(height: 32),
              _buildSectionHeader('COMPLETED', doneTasks.length, isDark),
              const SizedBox(height: 16),
              ...doneTasks.map((t) => _buildTaskCard(context, t, isDark)).toList(),
              if (doneTasks.isEmpty) _buildCompletedEmptyState(isDark),
              
              const SizedBox(height: 100), // Spacing for bottom navbar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpNextCard(BuildContext context, WidgetRef ref, NextActionData nextAction, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : const Color(0xFFE2E8F0), width: 1), // Light border
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: const Color(0xFF2E6FF2).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF2E6FF2),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('UP NEXT', style: TextStyle(color: Color(0xFF2E6FF2), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    Text(
                      nextAction.task.title,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, height: 1.2, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      nextAction.subtask.title,
                      style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF4A4A5F), fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Time Tracker', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          const SizedBox(height: 8),
                          Text('${nextAction.subtask.estimatedMinutes} : 00', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: 2)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.push('/timer/${nextAction.task.id}/${nextAction.subtask.id}'),
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: const BoxDecoration(color: Color(0xFF2E6FF2), shape: BoxShape.circle),
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: isDark ? Colors.grey[800] : const Color(0xFFE2E8F0), shape: BoxShape.circle),
                                child: Icon(Icons.stop_rounded, color: isDark ? Colors.grey[400] : const Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildSectionHeader(String title, int count, bool isDark, {bool isBlue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isBlue ? const Color(0xFF2E6FF2) : (isDark ? Colors.grey[400] : const Color(0xFF64748B)),
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isBlue ? const Color(0xFF2E6FF2) : (isDark ? Colors.grey[800] : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: isBlue ? Colors.white : (isDark ? Colors.grey[300] : const Color(0xFF475569)),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task, bool isDark, {bool isHighlighted = false}) {
    double progress = task.subtasks.isEmpty ? 0 : task.subtasks.where((st) => st.isCompleted).length / task.subtasks.length;
    int percent = (progress * 100).toInt();

    return GestureDetector(
      onTap: () => context.push('/task/${task.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isHighlighted ? Border.all(color: const Color(0xFF2E6FF2), width: 1.5) : Border.all(color: isDark ? Colors.grey[800]! : const Color(0xFFF1F5F9)),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: isHighlighted ? const Color(0xFF2E6FF2).withOpacity(0.1) : Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progress', style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
                Text('$percent%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : const Color(0xFF1C1C1E))),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              color: const Color(0xFF2E6FF2),
            ),
          ],
        ),
      ).animate().fadeIn().slideX(),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(message, style: const TextStyle(color: Colors.grey, fontSize: 14)),
    );
  }

  Widget _buildCompletedEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : const Color(0xFFE2E8F0), style: BorderStyle.none), // Standard border, as native doesn't do dashes easily without custom painters
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? Colors.grey[800] : Colors.white),
            child: const Icon(Icons.check_circle_outline, color: Colors.grey, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            "No tasks completed yet.\nKeep pushing, you'll get\nthere!",
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontSize: 14, height: 1.5),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
