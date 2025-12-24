import 'dart:math';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../core/storage/habit_storage.dart';

class HabitProvider extends ChangeNotifier {
  final List<Habit> _habits = [];
  List<Habit> get habits => List.unmodifiable(_habits);

  final HabitStorage _storage = HabitStorage();
  DateTime? _lastSavedDate;

  Future<void> loadFromStorage() async {
    final raw = await _storage.load();
    if (raw == null) return;

    _lastSavedDate =
        raw['date'] != null ? DateTime.parse(raw['date']) : DateTime.now();
    final list = (raw['habits'] as List).cast<Map<String, dynamic>>();
    _habits.clear();
    for (final h in list) {
      _habits.add(Habit.fromJson(h));
    }
    _maybeResetForNewDay();
    notifyListeners();
  }

  void _maybeResetForNewDay() {
    final now = DateTime.now();
    if (_lastSavedDate == null ||
        _lastSavedDate!.day != now.day ||
        _lastSavedDate!.month != now.month ||
        _lastSavedDate!.year != now.year) {
      for (final h in _habits) {
        h.todayDone = false;
      }
    }
    _lastSavedDate = now;
    save();
  }

  Future<void> save() async {
    await _storage.save(_lastSavedDate ?? DateTime.now(), _habits);
  }

  void addHabit(String name, Color color) {
    final id = DateTime.now().millisecondsSinceEpoch + Random().nextInt(1000);
    _habits.insert(
      0,
      Habit(id: id, name: name, colorValue: color.value),
    );
    save();
    notifyListeners();
  }

  void removeHabit(int id) {
    _habits.removeWhere((h) => h.id == id);
    save();
    notifyListeners();
  }

  void toggleDone(Habit h, bool done) {
    h.todayDone = done;
    if (done) {
      h.currentStreak++;
      if (h.currentStreak > h.longestStreak) {
        h.longestStreak = h.currentStreak;
      }
    } else {
      if (h.currentStreak > 0) h.currentStreak--;
    }
    save();
    notifyListeners();
  }

  double todayPercent() =>
      _habits.isEmpty ? 0 : _habits.where((h) => h.todayDone).length / _habits.length;
}
