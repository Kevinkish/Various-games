import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cash_flow_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  int? _selectedPayerId;
  final Set<int> _selectedParticipantIds = {};

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CashFlowProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une dépense')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Montant',
              prefixText: '€ ',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Qui a payé ?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...provider.participants.map((participant) {
            return RadioListTile<int>(
              title: Text(participant.name),
              value: participant.id!,
              groupValue: _selectedPayerId,
              onChanged: (value) => setState(() => _selectedPayerId = value),
            );
          }),
          const SizedBox(height: 24),
          Text(
            'Participants concernés',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...provider.participants.map((participant) {
            return CheckboxListTile(
              title: Text(participant.name),
              value: _selectedParticipantIds.contains(participant.id),
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _selectedParticipantIds.add(participant.id!);
                  } else {
                    _selectedParticipantIds.remove(participant.id);
                  }
                });
              },
            );
          }),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () async {
              final description = _descriptionController.text.trim();
              final amount =
                  double.tryParse(
                    _amountController.text.replaceAll(',', '.'),
                  ) ??
                  0;

              if (description.isEmpty ||
                  amount <= 0 ||
                  _selectedPayerId == null ||
                  _selectedParticipantIds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Remplissez tous les champs et sélectionnez les participants.',
                    ),
                  ),
                );
                return;
              }

              await provider.addExpense(
                description: description,
                amount: amount,
                payerId: _selectedPayerId!,
                participantIds: _selectedParticipantIds.toList(),
              );

              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Enregistrer la dépense'),
          ),
        ],
      ),
    );
  }
}
