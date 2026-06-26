class ExpenseShare {
  final int? id;
  final int expenseId;
  final int participantId;
  final double shareAmount;
  final bool paid;

  ExpenseShare({
    this.id,
    required this.expenseId,
    required this.participantId,
    required this.shareAmount,
    this.paid = false,
  });

  ExpenseShare copyWith({
    int? id,
    int? expenseId,
    int? participantId,
    double? shareAmount,
    bool? paid,
  }) {
    return ExpenseShare(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      participantId: participantId ?? this.participantId,
      shareAmount: shareAmount ?? this.shareAmount,
      paid: paid ?? this.paid,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'expenseId': expenseId,
    'participantId': participantId,
    'shareAmount': shareAmount,
    'paid': paid ? 1 : 0,
  };

  factory ExpenseShare.fromMap(Map<String, Object?> map) {
    return ExpenseShare(
      id: map['id'] as int?,
      expenseId: map['expenseId'] as int,
      participantId: map['participantId'] as int,
      shareAmount: (map['shareAmount'] as num).toDouble(),
      paid: (map['paid'] as int? ?? 0) == 1,
    );
  }
}
