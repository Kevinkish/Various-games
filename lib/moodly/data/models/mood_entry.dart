class MoodEntry {
  final int? id;
  final DateTime date;
  final int moodLevel;
  final String note;

  MoodEntry({
    this.id,
    required this.date,
    required this.moodLevel,
    required this.note,
  });

  MoodEntry copyWith({int? id, DateTime? date, int? moodLevel, String? note}) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      moodLevel: moodLevel ?? this.moodLevel,
      note: note ?? this.note,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'moodLevel': moodLevel,
    'note': note,
  };

  factory MoodEntry.fromMap(Map<String, Object?> map) {
    return MoodEntry(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      moodLevel: map['moodLevel'] as int,
      note: map['note'] as String,
    );
  }
}
