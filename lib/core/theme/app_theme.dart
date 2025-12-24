import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: Colors.grey[50],
  appBarTheme: const AppBarTheme(elevation: 0, foregroundColor: Colors.black87),
  // cardTheme: CardTheme(
  //   color: Colors.white,
  //   elevation: 4,
  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  // ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(elevation: 6),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(elevation: 0, foregroundColor: Colors.white),
  // cardTheme: CardTheme(
  //   color: Colors.grey[850],
  //   elevation: 4,
  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  // ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(elevation: 6),
);
