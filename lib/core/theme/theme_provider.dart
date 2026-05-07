import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final box = Hive.box<String>('settings');
    final isDark = box.get('isDarkMode');
    if (isDark != null) {
      return isDark == 'true' ? ThemeMode.dark : ThemeMode.light;
    }
    return ThemeMode.system;
  }

  void toggleTheme() {
    final isDark = state == ThemeMode.dark || (state == ThemeMode.system && WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    Hive.box<String>('settings').put('isDarkMode', (!isDark).toString());
  }
}
