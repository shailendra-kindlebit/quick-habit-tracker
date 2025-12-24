import 'package:flutter/material.dart';

class AddHabitDialog extends StatefulWidget {
  final void Function(String name, Color color) onAdd;

  const AddHabitDialog({super.key, required this.onAdd});

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final TextEditingController _c = TextEditingController();
  final List<Color> colors = [Colors.teal, Colors.orange, Colors.pink, Colors.indigo];
  Color selected = Colors.teal;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Habit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _c, decoration: const InputDecoration(hintText: 'Habit name')),
          const SizedBox(height: 10),
          Wrap(
            children: colors
                .map((c) => GestureDetector(
                      onTap: () => setState(() => selected = c),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: selected == c ? 3 : 1,
                            color: selected == c ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          )
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_c.text.trim().isNotEmpty) {
              widget.onAdd(_c.text.trim(), selected);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
