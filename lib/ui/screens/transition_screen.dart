import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/data/providers/quiz_provider.dart';
import 'package:quiz_master/ui/screens/quiz_screen.dart';

class TransitionScreen extends StatelessWidget {
  const TransitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transition')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Joueur 1 a terminé.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Passez le téléphone au Joueur 2 sans montrer les réponses.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<QuizProvider>().startPlayer2Turn();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const QuizScreen()),
                );
              },
              child: const Text('Prêt'),
            ),
          ],
        ),
      ),
    );
  }
}
