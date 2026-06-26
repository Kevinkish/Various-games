class Expense {
  final int? id;
  final String description;
  final double amount;
  final int payerId;
  final DateTime createdAt;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.payerId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Expense copyWith({
    int? id,
    String? description,
    double? amount,
    int? payerId,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      payerId: payerId ?? this.payerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'description': description,
    'amount': amount,
    'payerId': payerId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Expense.fromMap(Map<String, Object?> map) {
    return Expense(
      id: map['id'] as int?,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      payerId: map['payerId'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
