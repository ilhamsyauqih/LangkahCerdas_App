import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/theme_provider.dart';
import '../auth/presentation/auth_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Tampilan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)).animate().fadeIn(),
          Card(
            child: SwitchListTile(
              title: const Text('Mode Gelap'),
              subtitle: const Text('Gunakan tema gelap agar lebih nyaman di mata'),
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              value: isDark,
              onChanged: (val) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(),
          
          const SizedBox(height: 24),
          const Text('Akun', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)).animate().fadeIn(delay: 200.ms),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                ref.read(authNotifierProvider.notifier).logout();
                context.go('/login');
              },
            ),
          ).animate().fadeIn(delay: 300.ms).slideX(),
          
          const SizedBox(height: 24),
          const Text('Tentang', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)).animate().fadeIn(delay: 400.ms),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Versi Aplikasi'),
              trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
            ),
          ).animate().fadeIn(delay: 500.ms).slideX(),
        ],
      ),
    );
  }
}
