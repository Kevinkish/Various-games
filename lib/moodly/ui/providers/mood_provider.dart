import 'package:flutter/material.dart';
import '../../data/database/mood_database.dart';
import '../../data/models/mood_entry.dart';

class MoodSummary {
  final int moodLevel;
  final int count;
  final double percentage;

  MoodSummary({
    required this.moodLevel,
    required this.count,
    required this.percentage,
  });
}

class MoodProvider extends ChangeNotifier {
  final MoodDatabase database;

  List<MoodEntry> _entries = [];
  DateTime selectedDate = DateTime.now();

  MoodProvider(this.database);

  List<MoodEntry> get entries => _entries;

  Future<void> loadEntries() async {
    _entries = await database.getMoodEntries();
    notifyListeners();
  }

  Future<void> saveMoodEntry(MoodEntry entry) async {
    await database.insertMoodEntry(entry);
    await loadEntries();
  }

  MoodEntry? entryForDate(DateTime date) {
    for (var entry in _entries) {
      if (entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day) {
        return entry;
      }
    }
    return null; // Retourne null si aucune correspondance n'est trouvée
  }

  List<MoodEntry> entriesForWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return _entries.where((entry) {
      return entry.date.isAfter(monday.subtract(const Duration(seconds: 1))) &&
          entry.date.isBefore(sunday.add(const Duration(days: 1)));
    }).toList();
  }

  List<MoodSummary> get weeklySummary {
    final weekEntries = entriesForWeek(selectedDate);
    final counts = <int, int>{};

    for (var i = 1; i <= 5; i++) {
      counts[i] = 0;
    }

    for (final entry in weekEntries) {
      counts[entry.moodLevel] = (counts[entry.moodLevel] ?? 0) + 1;
    }

    final total = weekEntries.length;
    return counts.entries.map((entry) {
      return MoodSummary(
        moodLevel: entry.key,
        count: entry.value,
        percentage: total == 0 ? 0 : entry.value / total * 100,
      );
    }).toList();
  }

  void updateSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  DateTime get startOfMonth =>
      DateTime(selectedDate.year, selectedDate.month, 1);

  DateTime get endOfMonth =>
      DateTime(selectedDate.year, selectedDate.month + 1, 0);

  List<DateTime> get calendarDays {
    final days = <DateTime>[];
    final firstDay = startOfMonth;
    final weekdayOffset = firstDay.weekday - 1;
    for (var i = 0; i < weekdayOffset; i++) {
      days.add(firstDay.subtract(Duration(days: weekdayOffset - i)));
    }
    for (
      var i = 0;
      i < DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
      i++
    ) {
      days.add(DateTime(selectedDate.year, selectedDate.month, i + 1));
    }
    return days;
  }
}
