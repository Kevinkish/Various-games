import 'package:flutter/material.dart';
import '../../data/database/cash_flow_database.dart';
import '../../data/models/expense.dart';
import '../../data/models/expense_share.dart';
import '../../data/models/participant.dart';

class BalanceTransaction {
  final String from;
  final String to;
  final double amount;

  BalanceTransaction({
    required this.from,
    required this.to,
    required this.amount,
  });
}

class ExpenseDetails {
  final Expense expense;
  final Participant payer;
  final List<Participant> participants;
  final double shareAmount;

  ExpenseDetails({
    required this.expense,
    required this.payer,
    required this.participants,
    required this.shareAmount,
  });
}

class CashFlowProvider extends ChangeNotifier {
  final CashFlowDatabase database;

  List<Participant> _participants = [];
  List<Expense> _expenses = [];
  List<ExpenseShare> _expenseShares = [];

  CashFlowProvider(this.database);

  List<Participant> get participants => _participants;
  List<Expense> get expenses => _expenses;
  List<ExpenseShare> get expenseShares => _expenseShares;
  List<BalanceTransaction> get transactions => _buildMinimalTransactions();

  double get totalBalance {
    return _balances.values.fold(0.0, (sum, value) => sum + value);
  }

  double balanceFor(int participantId) {
    return _balances[participantId] ?? 0.0;
  }

  Map<int, double> get _balances {
    final balances = <int, double>{};
    for (final participant in _participants) {
      balances[participant.id!] = 0.0;
    }

    for (final expense in _expenses) {
      final shares = _expenseShares
          .where((share) => share.expenseId == expense.id)
          .toList();
      final payerId = expense.payerId;
      final paidAmount = expense.amount;

      balances[payerId] = (balances[payerId] ?? 0) + paidAmount;
      for (final share in shares) {
        if (share.paid) {
          balances[payerId] = (balances[payerId] ?? 0) - share.shareAmount;
          continue;
        }
        balances[share.participantId] =
            (balances[share.participantId] ?? 0) - share.shareAmount;
      }
    }

    return balances;
  }

  Future<void> loadData() async {
    _participants = await database.getParticipants();
    _expenses = await database.getExpenses();
    _expenseShares = await database.getExpenseShares();

    if (_participants.isEmpty) {
      await _seedParticipants();
      _participants = await database.getParticipants();
    }

    notifyListeners();
  }

  Future<void> _seedParticipants() async {
    await database.insertParticipant(Participant(name: 'Nsimire'));
    await database.insertParticipant(Participant(name: 'Justin'));
    await database.insertParticipant(Participant(name: 'Shamavu'));
  }

  Future<void> addExpense({
    required String description,
    required double amount,
    required int payerId,
    required List<int> participantIds,
  }) async {
    final expense = Expense(
      description: description,
      amount: amount,
      payerId: payerId,
    );

    final expenseId = await database.insertExpense(expense);
    final shareAmount = double.parse(
      (amount / participantIds.length).toStringAsFixed(2),
    );

    for (final participantId in participantIds) {
      await database.insertExpenseShare(
        ExpenseShare(
          expenseId: expenseId,
          participantId: participantId,
          shareAmount: shareAmount,
        ),
      );
    }

    await loadData();
  }

  Future<void> markDebtPaid(int shareId) async {
    await database.updateExpenseSharePaid(shareId, true);
    await loadData();
  }

  List<BalanceTransaction> _buildMinimalTransactions() {
    return _buildTransactionsFromBalances(_balances);
  }

  List<BalanceTransaction> minimalTransactionsForExpense(Expense expense) {
    final balances = <int, double>{};
    balances[expense.payerId] =
        (balances[expense.payerId] ?? 0) + expense.amount;

    final shares = _expenseShares
        .where((share) => share.expenseId == expense.id && !share.paid)
        .toList();

    for (final share in shares) {
      balances[share.participantId] =
          (balances[share.participantId] ?? 0) - share.shareAmount;
    }

    return _buildTransactionsFromBalances(balances);
  }

  List<BalanceTransaction> _buildTransactionsFromBalances(
    Map<int, double> balances,
  ) {
    final creditors = balances.entries
        .where((entry) => entry.value > 0)
        .map((entry) => MapEntry(entry.key, entry.value))
        .toList();
    final debtors = balances.entries
        .where((entry) => entry.value < 0)
        .map((entry) => MapEntry(entry.key, entry.value.abs()))
        .toList();

    creditors.sort((a, b) => b.value.compareTo(a.value));
    debtors.sort((a, b) => b.value.compareTo(a.value));

    final transactions = <BalanceTransaction>[];
    var creditorIndex = 0;
    var debtorIndex = 0;

    while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
      final creditor = creditors[creditorIndex];
      final debtor = debtors[debtorIndex];
      final amount = creditor.value < debtor.value
          ? creditor.value
          : debtor.value;

      final payer = _participants.firstWhere((p) => p.id == debtor.key);
      final receiver = _participants.firstWhere((p) => p.id == creditor.key);

      transactions.add(
        BalanceTransaction(from: payer.name, to: receiver.name, amount: amount),
      );

      creditors[creditorIndex] = MapEntry(
        creditor.key,
        creditor.value - amount,
      );
      debtors[debtorIndex] = MapEntry(debtor.key, debtor.value - amount);

      if (creditors[creditorIndex].value <= 0) {
        creditorIndex++;
      }
      if (debtors[debtorIndex].value <= 0) {
        debtorIndex++;
      }
    }

    return transactions;
  }

  Participant? findParticipant(int id) {
    return _participants.firstWhere(
      (element) => element.id == id,
      orElse: () => Participant(id: id, name: 'Inconnu'),
    );
  }
}
