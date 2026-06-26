class Participant {
  final int? id;
  final String name;

  Participant({this.id, required this.name});

  Participant copyWith({int? id, String? name}) {
    return Participant(id: id ?? this.id, name: name ?? this.name);
  }

  Map<String, Object?> toMap() => {'id': id, 'name': name};

  factory Participant.fromMap(Map<String, Object?> map) {
    return Participant(id: map['id'] as int?, name: map['name'] as String);
  }
}
