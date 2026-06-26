import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/mood_entry.dart';
import '../providers/mood_provider.dart';
import '../widgets/mood_selector.dart';

class MoodHomeScreen extends StatefulWidget {
  const MoodHomeScreen({super.key});

  @override
  State<MoodHomeScreen> createState() => _MoodHomeScreenState();
}

class _MoodHomeScreenState extends State<MoodHomeScreen> {
  int _selectedMood = 4;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MoodProvider>();
    final theme = Theme.of(context);
    final entry = provider.entryForDate(provider.selectedDate);
    final summary = provider.weeklySummary;
    final chartSections = summary
        .where((item) => item.percentage > 0)
        .map(
          (item) => PieChartSectionData(
            color: MoodSelector.moods[item.moodLevel - 1].color,
            value: item.percentage,
            title: '${item.percentage.toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: provider.selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                provider.updateSelectedDate(picked);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Moodly', style: theme.textTheme.titleLarge),
          SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sélectionnez votre humeur du jour',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MoodSelector(
                    selectedMood: entry?.moodLevel ?? _selectedMood,
                    onChanged: (value) => setState(() => _selectedMood = value),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Note du jour',
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final note = _noteController.text.trim();
                      final moodLevel = entry?.moodLevel ?? _selectedMood;
                      final selectedDate = provider.selectedDate;

                      await provider.saveMoodEntry(
                        MoodEntry(
                          date: DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                          ),
                          moodLevel: moodLevel,
                          note: note,
                        ),
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Humeur enregistrée')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 22,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Statistiques de la semaine',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (summary.every((item) => item.count == 0))
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Aucune donnée pour cette semaine. Enregistrez une humeur pour commencer.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            )
          else
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.3,
                      child: PieChart(
                        PieChartData(
                          sections: chartSections,
                          centerSpaceRadius: 36,
                          sectionsSpace: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: summary.map((item) {
                        final mood = MoodSelector.moods[item.moodLevel - 1];
                        return Chip(
                          backgroundColor: mood.color.withOpacity(0.14),
                          label: Text(
                            '${mood.label}: ${item.percentage.toStringAsFixed(0)}%',
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            'Calendrier',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: provider.calendarDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.9,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final date = provider.calendarDays[index];
              final dayEntry = provider.entryForDate(date);
              final selected =
                  date.year == provider.selectedDate.year &&
                  date.month == provider.selectedDate.month &&
                  date.day == provider.selectedDate.day;
              return GestureDetector(
                onTap: () {
                  provider.updateSelectedDate(date);
                  if (dayEntry != null) {
                    _selectedMood = dayEntry.moodLevel;
                    _noteController.text = dayEntry.note;
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primary.withOpacity(0.18)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: .max,
                    children: [
                      if (dayEntry != null) ...[
                        Expanded(
                          child: Text(
                            MoodSelector.moods[dayEntry.moodLevel - 1].emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ] else
                        Expanded(
                          child: Text(
                            '${date.day}',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
