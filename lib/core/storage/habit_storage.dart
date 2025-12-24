import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/habit.dart';

class HabitStorage {
  static const _key = 'quick_habit_v1';

  Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return json.decode(raw);
  }

  Future<void> save(DateTime date, List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'date': date.toIso8601String(),
      'habits': habits.map((h) => h.toJson()).toList(),
    };
    await prefs.setString(_key, json.encode(data));
  }
}
