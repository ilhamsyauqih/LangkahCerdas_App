import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../domain/task_model.dart';
import 'task_notifier.dart';

class AtomicBreakdownScreen extends ConsumerWidget {
  final String taskId;
  const AtomicBreakdownScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskNotifierProvider);
    final task = tasks.firstWhere((t) => t.id == taskId, orElse: () => TaskModel(id: '', title: 'Not Found', createdAt: DateTime.now()));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (task.id.isEmpty) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Tugas tidak ditemukan')));
    }

    final progress = task.subtasks.isEmpty 
        ? 0.0 
        : task.subtasks.where((st) => st.isCompleted).length / task.subtasks.length;

    // Identify Next Action
    SubtaskModel? nextActionSubtask;
    if (task.status == TaskStatus.progress || task.status == TaskStatus.planning) { 
       final incomplete = task.subtasks.where((st) => !st.isCompleted).toList();
       if (incomplete.isNotEmpty) {
         nextActionSubtask = incomplete.first;
       }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 200,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
                const SizedBox(width: 8),
                Text('BACK TO BOARD', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
            color: isDark ? Colors.white : Colors.black87,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
            color: isDark ? Colors.white : Colors.black87,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Divider(height: 1),
            const SizedBox(height: 32),
            
            Text(
              'PROJECT',
              style: TextStyle(color: const Color(0xFF4285F4), fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 10),
            ).animate().fadeIn().slideX(),
            const SizedBox(height: 8),
            Text(
              task.title,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, height: 1.2, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
            ).animate().fadeIn(delay: 100.ms).slideX(),
            
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Overall Progress', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : const Color(0xFF4A4A5F), fontSize: 16)),
                Text('${(progress * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 32, height: 1, color: isDark ? Colors.white : const Color(0xFF1C1C1E))),
              ],
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
              backgroundColor: isDark ? const Color(0xFF2D3748) : const Color(0xFFEBEBFF),
              color: const Color(0xFF2E6FF2), // Blue from design
            ).animate().fadeIn(delay: 300.ms).scaleX(alignment: Alignment.centerLeft),
            
            const SizedBox(height: 48),
            Text('Atomic Breakdown', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: isDark ? Colors.white : const Color(0xFF1C1C1E))).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 24),
            
            if (task.subtasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text('Belum ada subtask.\nPecah tugas ini menjadi langkah kecil.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
                ),
              ).animate().fadeIn(delay: 500.ms)
            else
              ...task.subtasks.asMap().entries.map((entry) {
                final index = entry.key;
                final subtask = entry.value;
                final isNextAction = subtask.id == nextActionSubtask?.id;
                
                return _buildSubtaskCard(
                  context: context, 
                  ref: ref, 
                  task: task, 
                  subtask: subtask, 
                  isNextAction: isNextAction, 
                  isDark: isDark
                ).animate().fadeIn(delay: Duration(milliseconds: 500 + (100 * index).toInt())).slideY();
              }),
              
            const SizedBox(height: 16),
            
            // Add New Subtask Button
            GestureDetector(
              onTap: () => _showAddSubtaskDialog(context, ref, task.id),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.grey[700]! : const Color(0xFFE0E0E0), width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: isDark ? Colors.grey[400] : const Color(0xFF4A4A5F)),
                    const SizedBox(width: 16),
                    Text('Add new subtask', style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF4A4A5F), fontWeight: FontWeight.w500, fontSize: 16)),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 800.ms),
            
            const SizedBox(height: 100), // padding for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildSubtaskCard({
    required BuildContext context, 
    required WidgetRef ref, 
    required TaskModel task, 
    required SubtaskModel subtask, 
    required bool isNextAction, 
    required bool isDark
  }) {
    if (subtask.isCompleted) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => ref.read(taskNotifierProvider.notifier).toggleSubtask(task.id, subtask.id),
              child: Container(
                width: 24, height: 24,
                decoration: const BoxDecoration(color: Color(0xFF8BA9FF), shape: BoxShape.circle), // Light blue circle
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                subtask.title,
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: isDark ? Colors.grey[600] : const Color(0xFFA0A0A0),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isNextAction) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2E6FF2), width: 1.5),
          boxShadow: [
            if (!isDark) BoxShadow(color: const Color(0xFF2E6FF2).withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))
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
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('NEXT ACTION', style: TextStyle(color: Color(0xFF2E6FF2), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => ref.read(taskNotifierProvider.notifier).toggleSubtask(task.id, subtask.id),
                            child: Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isDark ? Colors.grey[500]! : const Color(0xFF6B6B7B), width: 1.5)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              subtask.title,
                              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1E), fontSize: 16, fontWeight: FontWeight.w600, height: 1.3),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              if (task.status != TaskStatus.progress) {
                                ref.read(taskNotifierProvider.notifier).updateTask(task.copyWith(status: TaskStatus.progress));
                              }
                              context.push('/timer/${task.id}/${subtask.id}');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2D3748) : const Color(0xFFF6F6FB),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isDark ? Colors.grey[700]! : const Color(0xFFE0E0E0)),
                              ),
                              child: Row(
                                children: [
                                  Text('${subtask.estimatedMinutes}:00', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF4A4A5F))),
                                  const SizedBox(width: 8),
                                  Icon(Icons.play_arrow_outlined, size: 16, color: isDark ? Colors.white : const Color(0xFF4A4A5F)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Pending Subtask (Not Next Action)
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ref.read(taskNotifierProvider.notifier).toggleSubtask(task.id, subtask.id),
            child: Container(
              width: 24, height: 24,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isDark ? Colors.grey[500]! : const Color(0xFF6B6B7B), width: 1.5)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSubtaskDialog(BuildContext context, WidgetRef ref, String taskId) {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '25'); // Default 25 min pomodoro
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Langkah Kecil Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Deskripsi Subtask'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeCtrl,
              decoration: const InputDecoration(labelText: 'Estimasi (menit)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && int.tryParse(timeCtrl.text) != null) {
                ref.read(taskNotifierProvider.notifier).addSubtask(taskId, titleCtrl.text, int.parse(timeCtrl.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
