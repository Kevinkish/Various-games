import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cash_flow_provider.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

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
              return Card(
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
                                share.paid
                                    ? Chip(
                                        label: const Text('Payé'),
                                        backgroundColor: theme
                                            .colorScheme
                                            .secondaryContainer,
                                      )
                                    : TextButton(
                                        onPressed: () async {
                                          await provider.markDebtPaid(
                                            share.id!,
                                          );
                                        },
                                        child: const Text('Marquer payé'),
                                      ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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
