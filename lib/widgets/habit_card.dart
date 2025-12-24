import 'package:flutter/material.dart';
import '../models/habit.dart';

class NeumorphicHabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onUndo;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const NeumorphicHabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onUndo,
    required this.onDelete,
    this.onTap,
  });

  @override
  State<NeumorphicHabitCard> createState() => _NeumorphicHabitCardState();
}

class _NeumorphicHabitCardState extends State<NeumorphicHabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0,
      upperBound: 0.06,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  double _progress() {
    final c = widget.habit.currentStreak.toDouble();
    final b = (widget.habit.longestStreak + 1).toDouble();
    if (b == 0) return 0;
    return (c / b).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.habit;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF202020) : const Color(0xFFE9E9E9);
    final shadow1 = isDark ? Colors.black.withOpacity(0.5) : Colors.black12;
    final shadow2 = isDark ? Colors.grey.shade800 : Colors.white;

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (_, child) {
          final scale = 1 - _pressController.value;
          return Transform.scale(scale: scale, child: child);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: shadow2,
                  offset: const Offset(-4, -4),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: shadow1,
                  offset: const Offset(4, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: shadow2,
                        offset: const Offset(-4, -4),
                        blurRadius: 8,
                      ),
                      BoxShadow(
                        color: shadow1,
                        offset: const Offset(4, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      h.name.isNotEmpty ? h.name[0].toUpperCase() : "?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          _chip(
                            icon: Icons.local_fire_department,
                            label: "${h.currentStreak} day streak",
                            color: Colors.orange,
                            isDark: isDark,
                          ),
                          // const SizedBox(width: 8),
                          // _chip(
                          //   icon: Icons.emoji_events,
                          //   label: "Best ${h.longestStreak}",
                          //   color: Colors.blue,
                          //   isDark: isDark,
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: widget.onToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: h.todayDone ? Colors.green.withOpacity(0.15) : bg,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: shadow2,
                              offset: const Offset(-2, -2),
                              blurRadius: 6,
                            ),
                            BoxShadow(
                              color: shadow1,
                              offset: const Offset(2, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(
                          h.todayDone ? Icons.check_circle : Icons.circle_outlined,
                          size: 22,
                          color: h.todayDone ? Colors.green : (isDark ? Colors.white54 : Colors.black45),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: Icon(Icons.delete_outline, size: 20, color: Colors.redAccent.shade200),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black87 : Colors.black12,
            offset: const Offset(2, 2),
            blurRadius: 3,
          ),
          BoxShadow(
            color: isDark ? Colors.grey.shade700 : Colors.white,
            offset: const Offset(-2, -2),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
