import 'package:flutter/material.dart';

class MoodLevel {
  final int value;
  final String label;
  final String emoji;
  final Color color;

  MoodLevel(this.value, this.label, this.emoji, this.color);
}

class MoodSelector extends StatelessWidget {
  final int selectedMood;
  final ValueChanged<int> onChanged;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onChanged,
  });

  static final moods = [
    MoodLevel(1, 'Triste', '😞', Colors.blue),
    MoodLevel(2, 'Calme', '😌', Colors.teal),
    MoodLevel(3, 'Neutre', '😐', Colors.grey),
    MoodLevel(4, 'Serein', '🙂', Colors.amber),
    MoodLevel(5, 'Joyeux', '😄', Colors.green),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moods.map((mood) {
        final selected = selectedMood == mood.value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(mood.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: selected ? mood.color.withAlpha(46) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? mood.color
                      : Theme.of(context).colorScheme.outline,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mood.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    mood.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected
                          ? mood.color
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
