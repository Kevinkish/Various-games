import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/data/providers/quiz_provider.dart';
import 'package:quiz_master/ui/screens/home_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();
    final player1Score = provider.player1Score;
    final player2Score = provider.player2Score;
    final winnerText = player1Score == player2Score
        ? 'Égalité'
        : player1Score > player2Score
        ? 'Joueur 1 gagne'
        : 'Joueur 2 gagne';

    return Scaffold(
      appBar: AppBar(title: const Text('Résultat')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              winnerText,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text('Catégorie : ${provider.categoryName}'),
            const SizedBox(height: 16),
            Text('Score Joueur 1: $player1Score'),
            const SizedBox(height: 8),
            Text('Score Joueur 2: $player2Score'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                provider.resetGame();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: const Text('Retour à l’accueil'),
            ),
          ],
        ),
      ),
    );
  }
}
