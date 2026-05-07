import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../domain/task_model.dart';
import 'task_notifier.dart';
import '../../../core/theme/theme_provider.dart';

class TaskBoardScreen extends HookConsumerWidget {
  const TaskBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // State
    final selectedDate = useState<DateTime>(DateTime.now());
    final selectedFilter = useState<String>('All'); // 'All', 'To do', 'In Progress', 'Completed'

    // Calendar Data
    final dates = useMemoized(() {
      final today = DateTime.now();
      return List.generate(30, (index) => today.subtract(Duration(days: 14 - index)));
    });
    
    // Auto-scroll to center today
    final scrollController = useScrollController(initialScrollOffset: 14 * 76.0 - 120.0);

    // Filtering Logic
    final filteredTasks = tasks.where((task) {
      // Filter by Date
      bool dateMatches = task.createdAt.year == selectedDate.value.year &&
          task.createdAt.month == selectedDate.value.month &&
          task.createdAt.day == selectedDate.value.day;
      
      if (!dateMatches) return false;

      // Filter by Category
      if (selectedFilter.value == 'All') return true;
      if (selectedFilter.value == 'To do' && task.status == TaskStatus.planning) return true;
      if (selectedFilter.value == 'In Progress' && task.status == TaskStatus.progress) return true;
      if (selectedFilter.value == 'Completed' && task.status == TaskStatus.done) return true;
      
      return false;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Today's Tasks",
          style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D3748) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: isDark ? [] : [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? Colors.amber : const Color(0xFF1C1C1E),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark 
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
                colors: [
                  Color(0xFFEEFBF2), // Light mint
                  Color(0xFFF4F7FF), // Very soft blue
                  Color(0xFFFFF5EF), // Very soft peach
                ],
              ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Calendar Strip
              _buildCalendarStrip(dates, selectedDate, scrollController, isDark),
              
              const SizedBox(height: 24),
              
              // Filter Chips
              _buildFilterChips(selectedFilter, isDark),
              
              const SizedBox(height: 24),
              
              // Task List
              Expanded(
                child: filteredTasks.isEmpty 
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        return _buildTaskCard(context, filteredTasks[index], isDark, index);
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarStrip(List<DateTime> dates, ValueNotifier<DateTime> selectedDate, ScrollController scrollController, bool isDark) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date.year == selectedDate.value.year &&
                             date.month == selectedDate.value.month &&
                             date.day == selectedDate.value.day;

          final monthStr = DateFormat('MMM').format(date);
          final dayNum = date.day.toString();
          final dayStr = DateFormat('E').format(date);

          return GestureDetector(
            onTap: () => selectedDate.value = date,
            child: Container(
              width: 66,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6534FF) : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark ? [] : [
                  if (!isSelected) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(monthStr, style: TextStyle(color: isSelected ? Colors.white70 : (isDark ? Colors.grey[400] : Colors.grey), fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(dayNum, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1C1C1E)), fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(dayStr, style: TextStyle(color: isSelected ? Colors.white70 : (isDark ? Colors.grey[400] : Colors.grey), fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 50 + (index % 10) * 20)).slideX();
        },
      ),
    );
  }

  Widget _buildFilterChips(ValueNotifier<String> selectedFilter, bool isDark) {
    final filters = ['All', 'To do', 'In Progress', 'Completed'];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter.value == filter;

          return GestureDetector(
            onTap: () => selectedFilter.value = filter,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                  ? const Color(0xFF6534FF) 
                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFEBEBFF)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6534FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 + index * 50));
        },
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task, bool isDark, int index) {
    final timeStr = DateFormat.jm().format(task.createdAt);
    
    Color statusColor;
    Color statusBg;
    String statusText;

    if (task.status == TaskStatus.done) {
      statusColor = const Color(0xFF6534FF);
      statusBg = const Color(0xFFEBEBFF);
      statusText = 'Done';
    } else if (task.status == TaskStatus.progress) {
      statusColor = const Color(0xFFFF6B00);
      statusBg = const Color(0xFFFFEBE0);
      statusText = 'In Progress';
    } else {
      statusColor = const Color(0xFF00B4D8);
      statusBg = const Color(0xFFE0F7FA);
      statusText = 'To-do';
    }

    final iconColors = [
      const Color(0xFFFF8B94),
      const Color(0xFFA18CD1),
      const Color(0xFFFFB347),
      const Color(0xFF8FD3F4),
    ];
    final iconBgs = [
      const Color(0xFFFFF0F1),
      const Color(0xFFF3F0F9),
      const Color(0xFFFFF6ED),
      const Color(0xFFEBF7FD),
    ];
    final icons = [Icons.work_rounded, Icons.person_rounded, Icons.menu_book_rounded, Icons.layers_rounded];

    final cIndex = index % iconColors.length;

    return GestureDetector(
      onTap: () => context.push('/task/${task.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.description.isNotEmpty ? task.description : 'Task Group',
                    style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF8E8E93), fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? iconColors[cIndex].withOpacity(0.2) : iconBgs[cIndex],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icons[cIndex], color: iconColors[cIndex], size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task.title,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_filled, color: isDark ? Colors.grey[400] : const Color(0xFFA2A2B5), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      timeStr,
                      style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFFA2A2B5), fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? statusColor.withOpacity(0.2) : statusBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.1),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 80, color: isDark ? Colors.grey[800] : Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada tugas.',
            style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}
