import 'package:flutter/material.dart';
import 'package:habit/core/theme/app_theme.dart';
import 'package:habit/providers/habit_provider.dart';
import 'package:habit/providers/theme_provider.dart';
import 'package:habit/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const HabitApp());
}

class HabitApp extends StatelessWidget {
  const HabitApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HabitProvider()..loadFromStorage(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, value, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Quick Habit',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: value.isDark ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
