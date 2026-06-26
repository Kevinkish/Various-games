import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/cashFlow/data/models/expense.dart';
import '../providers/cash_flow_provider.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  void _showExpenseDetails(
    BuildContext context,
    CashFlowProvider provider,
    Expense expense,
  ) {
    final theme = Theme.of(context);
    final payer = provider.findParticipant(expense.payerId);
    final shares = provider.expenseShares
        .where((s) => s.expenseId == expense.id)
        .toList();
    final unpaidShares = shares.where((s) => !s.paid).toList();
    final transactions = provider.minimalTransactionsForExpense(expense);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 50,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  expense.description,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Montant : ${expense.amount.toStringAsFixed(2)} € • Payé par ${payer?.name ?? 'Inconnu'}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  'Partages',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...shares.map((share) {
                  final participant = provider.findParticipant(
                    share.participantId,
                  );
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(participant?.name ?? 'Inconnu'),
                    subtitle: Text('${share.shareAmount.toStringAsFixed(2)} €'),
                    trailing: share.paid
                        ? Chip(
                            label: const Text('Réglé'),
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              await provider.markDebtPaid(share.id!);
                              if (context.mounted) Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Marquer payé'),
                          ),
                  );
                }).toList(),
                if (unpaidShares.isEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Cette dépense est entièrement réglée.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Remboursement minimum',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (transactions.isEmpty)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Aucune dette active pour cette dépense.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  ...transactions.map((transaction) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.sync_alt),
                        title: Text(
                          '${transaction.from} → ${transaction.to}',
                          style: theme.textTheme.bodyLarge,
                        ),
                        trailing: Text(
                          '${transaction.amount.toStringAsFixed(2)} €',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    );
                  }).toList(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Fermer'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CashFlowProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('CashFlow')),
      body: RefreshIndicator(
        onRefresh: provider.loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Dépenses de groupe',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 242),
                      theme.colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance globale',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${provider.totalBalance.toStringAsFixed(2)} €',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.participants.map((participant) {
                        final balance = provider.balanceFor(participant.id!);
                        final status = balance >= 0 ? 'Crédit' : 'Débit';
                        return Chip(
                          backgroundColor: theme.colorScheme.surface,
                          label: Text(
                            '${participant.name}: ${balance.toStringAsFixed(2)}€ • $status',
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
              'Transactions minimales',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (provider.transactions.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Aucune transaction à simplifier pour l’instant.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ...provider.transactions.map((transaction) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 38,
                      ),
                      child: const Icon(
                        Icons.swap_horiz,
                        color: Colors.black54,
                      ),
                    ),
                    title: Text(
                      '${transaction.from} → ${transaction.to}',
                      style: theme.textTheme.bodyLarge,
                    ),
                    trailing: Text(
                      '${transaction.amount.toStringAsFixed(2)} €',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                );
              }).toList(),
            const SizedBox(height: 20),
            Text(
              'Historique des dépenses',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...provider.expenses.map((expense) {
              final payer = provider.findParticipant(expense.payerId);
              final shares = provider.expenseShares
                  .where((s) => s.expenseId == expense.id)
                  .toList();
              return InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _showExpenseDetails(context, provider, expense),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                expense.description,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              '${expense.amount.toStringAsFixed(2)} €',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Payé par ${payer?.name ?? 'Inconnu'} • ${shares.length} participant(s)',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: shares.map((share) {
                            final participant = provider.findParticipant(
                              share.participantId,
                            );
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${participant?.name ?? 'Inconnu'}: ${share.shareAmount.toStringAsFixed(2)} €',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                  if (share.paid)
                                    Chip(
                                      label: const Text('Payé'),
                                      backgroundColor:
                                          theme.colorScheme.secondaryContainer,
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une dépense'),
      ),
    );
  }
}
