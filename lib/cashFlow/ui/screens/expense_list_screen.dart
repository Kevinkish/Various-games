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
      appBar: AppBar(centerTitle: true),
      body: RefreshIndicator(
        onRefresh: provider.loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Dépenses de groupe', style: theme.textTheme.titleLarge),
            SizedBox(height: 10),
            Card(
              color: theme.colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance globale',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Text(
                    //   '${provider.totalBalance.toStringAsFixed(2)} €',
                    //   style: theme.textTheme.headlineMedium?.copyWith(
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.participants.map((participant) {
                        final balance = provider.balanceFor(participant.id!);
                        final status = balance >= 0 ? 'crédit' : 'débit';
                        return Chip(
                          label: Text(
                            '${participant.name}: ${balance.toStringAsFixed(2)} € ($status)',
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Transactions minimales',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...provider.transactions.map((transaction) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: Text('${transaction.from} → ${transaction.to}'),
                  trailing: Text('${transaction.amount.toStringAsFixed(2)} €'),
                ),
              );
            }),
            const SizedBox(height: 24),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Payé par ${payer?.name ?? 'Inconnu'} • ${shares.length} participant(s)',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      ...shares.map((share) {
                        final participant = provider.findParticipant(
                          share.participantId,
                        );
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    backgroundColor:
                                        theme.colorScheme.secondaryContainer,
                                  )
                                : TextButton(
                                    onPressed: () async {
                                      await provider.markDebtPaid(share.id!);
                                    },
                                    child: const Text('Marquer payé'),
                                  ),
                          ],
                        );
                      }).toList(),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${expense.amount.toStringAsFixed(2)} €',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
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
