class Habit {
  int id;
  String name;
  int colorValue;
  bool todayDone;
  int currentStreak;
  int longestStreak;

  Habit({
    required this.id,
    required this.name,
    required this.colorValue,
    this.todayDone = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  factory Habit.fromJson(Map<String, dynamic> j) => Habit(
        id: j['id'],
        name: j['name'],
        colorValue: j['colorValue'],
        todayDone: j['todayDone'] ?? false,
        currentStreak: j['currentStreak'] ?? 0,
        longestStreak: j['longestStreak'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'todayDone': todayDone,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
      };
}