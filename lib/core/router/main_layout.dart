import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../features/tasks/presentation/task_notifier.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine selected index based on current location
    final location = GoRouterState.of(context).uri.path;
    int currentIndex = 0;
    if (location.startsWith('/tasks')) currentIndex = 1;
    if (location.startsWith('/statistics')) currentIndex = 3;
    if (location.startsWith('/settings')) currentIndex = 4;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Allows body to extend behind the navbar
      body: child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 32),
        child: FloatingActionButton(
          onPressed: () {
            _showQuickAddDialog(context, ref);
          },
          backgroundColor: const Color(0xFF6534FF),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F1FE),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black45 : const Color(0xFF6534FF).withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BottomAppBar(
            color: Colors.transparent,
            elevation: 0,
            notchMargin: 8,
            padding: EdgeInsets.zero,
            height: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavBarItem(
                  icon: Icons.home_filled,
                  isSelected: currentIndex == 0,
                  onTap: () => context.go('/dashboard'),
                ),
                _NavBarItem(
                  icon: Icons.list_alt_rounded,
                  isSelected: currentIndex == 1,
                  onTap: () => context.go('/tasks'),
                ),
                const SizedBox(width: 48), // Space for FAB
                _NavBarItem(
                  icon: Icons.person_rounded,
                  isSelected: currentIndex == 3,
                  onTap: () => context.go('/statistics'),
                ),
                _NavBarItem(
                  icon: Icons.settings_rounded,
                  isSelected: currentIndex == 4,
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickAddDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Proyek Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Nama Proyek'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                ref.read(taskNotifierProvider.notifier).addTask(titleCtrl.text, descCtrl.text);
                Navigator.pop(context);
                context.go('/tasks');
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF6534FF).withOpacity(isDark ? 0.3 : 0.15),
                  shape: BoxShape.circle, // Using circle to look like the badge in the image
                ),
              ),
            Icon(
              icon,
              size: 26,
              color: isSelected ? const Color(0xFF6534FF) : (isDark ? Colors.white54 : const Color(0xFF6534FF).withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }
}
