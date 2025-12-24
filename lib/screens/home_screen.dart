import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habit/providers/theme_provider.dart';
import 'package:habit/widgets/add_habit_dailog.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart'; 
import '../core/utils/date_formatter.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openAddDialog(HabitProvider box) {
    showDialog(
      context: context,
      builder: (_) =>
          AddHabitDialog(onAdd: (name, color) => box.addHabit(name, color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Provider.of<HabitProvider>(context);
    final percent = box.todayPercent().clamp(0.0, 1.0);
    final themeProv = Provider.of<ThemeProvider>(context);
    final isDark = themeProv.isDark;

    final Color bg = isDark ? const Color(0xFF1D1F20) : const Color(0xFFF1F3F6);
    final Color cardBg = isDark
        ? const Color(0xFF242628)
        : const Color(0xFFEDEFF3);
    final Color lightShadow = isDark ? Colors.grey.shade800 : Colors.white;
    final Color darkShadow = isDark
        ? Colors.black.withOpacity(0.6)
        : Colors.black12;

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Quick Habit', style: TextStyle(letterSpacing: 0.2)),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, value, _) {
              return IconButton(
                tooltip: value.isDark ? 'Switch to Light' : 'Switch to Dark',
                icon: Icon(value.isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => value.toggleTheme(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: GestureDetector(
          onTap: () => _openAddDialog(box),
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(-6, -6),
                  blurRadius: 14,
                  color: lightShadow.withOpacity(0.6),
                ),
                BoxShadow(
                  offset: const Offset(6, 6),
                  blurRadius: 14,
                  color: darkShadow.withOpacity(0.9),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add, size: 20),
                SizedBox(width: 8),
                Text(
                  'Add Habit',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14),
            child: Column(
              children: [
                _buildphicHeader(
                  context,
                  percent,
                  box,
                  cardBg,
                  lightShadow,
                  darkShadow,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's Habits",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon: Filters')),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.filter_list, size: 18),
                          SizedBox(width: 6),
                          Text('Filter', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: box.habits.isEmpty
                      ? _emptyState(cardBg, isDark)
                      : ListView.separated(
                          itemCount: box.habits.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final habit = box.habits[i];
                            return TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 300 + i * 25),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - value) * 8),
                                    child: child,
                                  ),
                                );
                              },
                              child: NeumorphicHabitCard(
                                habit: habit,
                                onToggle: () =>
                                    box.toggleDone(habit, !habit.todayDone),
                                onUndo: () => box.toggleDone(habit, false),
                                onDelete: () => box.removeHabit(habit.id),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildphicHeader(
    BuildContext context,
    double percent,
    HabitProvider box,
    Color cardBg,
    Color lightShadow,
    Color darkShadow,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    final textColor =
        Theme.of(context).textTheme.bodyLarge!.color ??
        (isDark ? Colors.white : Colors.black87);
    final completed = box.habits.where((h) => h.todayDone).length;
    final total = box.habits.length;
    final percentLabel = '${(percent * 100).round()}%';

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final isNarrow = maxW < 360;
        final leftWidth = (maxW * 0.28).clamp(72.0, 110.0);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(-8, -8),
                        blurRadius: 22,
                        color: lightShadow.withOpacity(0.38),
                      ),
                      BoxShadow(
                        offset: const Offset(8, 8),
                        blurRadius: 22,
                        color: darkShadow.withOpacity(0.55),
                      ),
                    ],
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                cardBg.withOpacity(0.58),
                                cardBg.withOpacity(0.36),
                              ]
                            : [
                                cardBg.withOpacity(0.96),
                                cardBg.withOpacity(0.92),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(isDark ? 0.035 : 0.06),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: isNarrow
                                  ? 90
                                  : 115,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: isNarrow ? 100 : 120,
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: percent),
                                      duration: const Duration(
                                        milliseconds: 700,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, _) {
                                        final bubbleSize = isNarrow
                                            ? 110.0
                                            : 130.0;
                                        final ringRadius = bubbleSize / 2 - 14;

                                        return Container(
                                          width: bubbleSize,
                                          height: bubbleSize,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white.withOpacity(0.04)
                                                : Colors.white.withOpacity(
                                                    0.25,
                                                  ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: isDark
                                                    ? Colors.black54
                                                    : Colors.white,
                                                offset: const Offset(-6, -6),
                                                blurRadius: 14,
                                              ),
                                              BoxShadow(
                                                color: isDark
                                                    ? Colors.black87
                                                    : Colors.black12,
                                                offset: const Offset(6, 6),
                                                blurRadius: 14,
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              CircularPercentIndicator(
                                                radius: ringRadius,
                                                lineWidth: 9,
                                                percent: value.clamp(0.0, 1.0),
                                                circularStrokeCap:
                                                    CircularStrokeCap.round,
                                                progressColor: accent,
                                                backgroundColor: accent
                                                    .withOpacity(0.10),
                                                animation: false,
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "${(percent * 100).round()}%",
                                                    style: TextStyle(
                                                      fontSize: isNarrow
                                                          ? 18
                                                          : 22,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Today',
                                                    style: TextStyle(
                                                      fontSize: isNarrow
                                                          ? 12
                                                          : 13,
                                                      color: textColor
                                                          .withOpacity(0.70),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _greeting(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: textColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 78,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SizedBox(
                                              width: 36,
                                              height: 36,
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                tooltip: 'Insights',
                                                icon: Icon(
                                                  Icons.bar_chart_outlined,
                                                  size: 18,
                                                  color: textColor.withOpacity(
                                                    0.9,
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Insights — coming soon',
                                                        ),
                                                      ),
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            SizedBox(
                                              width: 36,
                                              height: 36,
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                tooltip: 'Share',
                                                icon: Icon(
                                                  Icons.share_outlined,
                                                  size: 18,
                                                  color: textColor.withOpacity(
                                                    0.9,
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Share your progress',
                                                        ),
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    friendlyDate(DateTime.now()),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: textColor.withOpacity(0.72),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: box.habits.isEmpty
                                        ? Text(
                                            'No habits yet. Add your first routine.',
                                            style: TextStyle(
                                              color: textColor.withOpacity(
                                                0.65,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            '$completed of $total completed today • Keep the streak going!',
                                            key: ValueKey<int>(completed),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: textColor.withOpacity(
                                                0.85,
                                              ),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (!isNarrow)
                          Row(
                            children: [
                              Flexible(
                                fit: FlexFit.tight,
                                child: _microStat(
                                  label: 'Avg streak',
                                  value: _avgStreak(box).toString(),
                                  icon: Icons.timeline,
                                  color: accent,
                                  textColor: textColor,
                                  cardBg: cardBg,
                                  lightShadow: lightShadow,
                                  darkShadow: darkShadow,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                fit: FlexFit.tight,
                                child: _microStat(
                                  label: 'Total',
                                  value: '$total',
                                  icon: Icons.list_alt,
                                  color: Colors.indigo,
                                  textColor: textColor,
                                  cardBg: cardBg,
                                  lightShadow: lightShadow,
                                  darkShadow: darkShadow,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                fit: FlexFit.tight,
                                child: _microStat(
                                  label: 'Active',
                                  value: '$completed',
                                  icon: Icons.flash_on,
                                  color: Colors.orange,
                                  textColor: textColor,
                                  cardBg: cardBg,
                                  lightShadow: lightShadow,
                                  darkShadow: darkShadow,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: _microStat(
                                      label: 'Avg',
                                      value: _avgStreak(box).toString(),
                                      icon: Icons.timeline,
                                      color: accent,
                                      textColor: textColor,
                                      cardBg: cardBg,
                                      lightShadow: lightShadow,
                                      darkShadow: darkShadow,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: _microStat(
                                      label: 'Total',
                                      value: '$total',
                                      icon: Icons.list_alt,
                                      color: Colors.indigo,
                                      textColor: textColor,
                                      cardBg: cardBg,
                                      lightShadow: lightShadow,
                                      darkShadow: darkShadow,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: _microStat(
                                      label: 'Active',
                                      value: '$completed',
                                      icon: Icons.flash_on,
                                      color: Colors.orange,
                                      textColor: textColor,
                                      cardBg: cardBg,
                                      lightShadow: lightShadow,
                                      darkShadow: darkShadow,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _microStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color textColor,
    required Color cardBg,
    required Color lightShadow,
    required Color darkShadow,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: const Offset(-4, -4),
            blurRadius: 8,
            color: lightShadow.withOpacity(0.45),
          ),
          BoxShadow(
            offset: const Offset(4, 4),
            blurRadius: 8,
            color: darkShadow.withOpacity(0.6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withOpacity(0.75),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _avgStreak(HabitProvider box) {
    if (box.habits.isEmpty) return 0;
    final sum = box.habits.fold<int>(0, (p, h) => p + h.currentStreak);
    return (sum / box.habits.length).round();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _emptyState(Color cardBg, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(-6, -6),
                  blurRadius: 12,
                  color: (isDark ? Colors.grey.shade800 : Colors.white)
                      .withOpacity(0.6),
                ),
                BoxShadow(
                  offset: const Offset(6, 6),
                  blurRadius: 12,
                  color: (isDark ? Colors.black54 : Colors.black12).withOpacity(
                    0.8,
                  ),
                ),
              ],
            ),
            child: Icon(
              Icons.rocket_launch,
              size: 48,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Start small. Add one habit today.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to create your first habit.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
