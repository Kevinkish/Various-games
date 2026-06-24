import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quiz_master/domain/models/match_record.dart';
import 'package:quiz_master/ui/screens/category_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<MatchRecord>('match_records');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Master'),
        actions: [
          IconButton(
            tooltip: 'Effacer l\'historique',
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirmer'),
                  content: const Text('Effacer tout l\'historique des duels ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Effacer'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await box.clear();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Historique effacé')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Historique des duels',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<Box<MatchRecord>>(
                valueListenable: box.listenable(),
                builder: (context, box, _) {
                  final records = box.values.toList().reversed.toList();
                  if (records.isEmpty) {
                    return const Center(
                      child: Text('Aucun duel enregistré pour le moment.'),
                    );
                  }

                  return ListView.separated(
                    itemCount: records.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final dateText = record.date
                          .toLocal()
                          .toString()
                          .split('.')
                          .first;
                      return ListTile(
                        title: Text(record.categoryName),
                        subtitle: Text(
                          'J1: ${record.scorePlayer1} / J2: ${record.scorePlayer2}',
                        ),
                        trailing: Text(dateText),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => CategoryScreen()));
              },
              child: const Text('Nouveau Duel'),
            ),
          ],
        ),
      ),
    );
  }
}
