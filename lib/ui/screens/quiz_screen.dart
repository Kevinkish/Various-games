import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/data/providers/quiz_provider.dart';
import 'package:quiz_master/ui/screens/result_screen.dart';
import 'package:quiz_master/ui/screens/transition_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();

    if (!_hasNavigated && provider.phase == QuizPhase.transition) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const TransitionScreen()),
          );
        }
      });
    }

    if (!_hasNavigated && provider.phase == QuizPhase.completed) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ResultScreen()),
          );
        }
      });
    }

    if (provider.phase == QuizPhase.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.phase == QuizPhase.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: Center(child: Text(provider.errorMessage ?? 'Erreur inconnue')),
      );
    }

    final question = provider.currentQuestion;
    if (question == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('Aucune question disponible.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          provider.phase == QuizPhase.player1
              ? 'Tour du Joueur 1'
              : 'Tour du Joueur 2',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${provider.currentQuestionNumber}/${provider.totalQuestions}',
                ),
                Text('Temps restant : ${provider.timeLeft}s'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              question.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ...provider.currentAnswers.map((answer) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: () => provider.submitAnswer(answer),
                  child: Text(answer),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
