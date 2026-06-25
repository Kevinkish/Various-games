import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/data/providers/quiz_provider.dart';
import 'package:quiz_master/domain/utils/size_util.dart';
import 'package:quiz_master/ui/screens/quiz/quiz_result_screen.dart';
import 'package:quiz_master/ui/screens/quiz/quiz_transition_screen.dart';
import 'package:quiz_master/ui/styles/app_images.dart';
import 'package:quiz_master/ui/widgets/buttons.dart';

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

    // Gestion des redirections de phases
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
      return const Scaffold(
        backgroundColor: Color(0xFFF9F9FF),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4648D4)),
        ),
      );
    }

    if (provider.phase == QuizPhase.error) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Quiz',
            style: TextStyle(
              color: Color(0xFF111C2D),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            provider.errorMessage ?? 'Erreur inconnue',
            style: const TextStyle(color: Color(0xFFBA1A1A)),
          ),
        ),
      );
    }

    final question = provider.currentQuestion;
    if (question == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            'Aucune question disponible.',
            style: TextStyle(color: Color(0xFF767586)),
          ),
        ),
      );
    }

    // Lettres pour les options
    const optionLetters = ['A', 'B', 'C', 'D'];

    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            AppImages.game3,
            alignment: .center,
            fit: BoxFit.cover,
            width: SizeUtil.sizeWidth(context),
            height: SizeUtil.sizeHeight(context),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // En-tête personnalisé (Custom App Bar style Quivio)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          provider.phase == QuizPhase.player1
                              ? 'Tour du Joueur 1'
                              : 'Tour du Joueur 2',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Section Chronomètre Circulaire & Linéaire
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        // Timer Circulaire Natif
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  value:
                                      provider.timeLeft /
                                      10, // Supposant 10s max
                                  strokeWidth: 8,
                                  backgroundColor: const Color(0xFFD8E3FB),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    provider.timeLeft >= 5
                                        ? Colors.green
                                        : provider.timeLeft >= 3
                                        ? Colors.orange
                                        : Colors.red,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${provider.timeLeft}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4648D4),
                                    ),
                                  ),
                                  const Text(
                                    'SEC',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF767586),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Barre de progression horizontale fluide
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            height: 12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: FractionalTranslation(
                              translation: const Offset(0, 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: provider.currentQuestionNumber,
                                    child: AnimatedContainer(
                                      duration: const Duration(seconds: 1),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex:
                                        provider.totalQuestions +
                                        1 -
                                        provider.currentQuestionNumber,
                                    child: const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Question ${provider.currentQuestionNumber} sur ${provider.totalQuestions}',
                          style: const TextStyle(
                            color: Color(0xFF767586),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Carte 3D de la question
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: const Color(0xFFDEE8FF)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4648D4).withOpacity(0.15),
                            blurRadius: 0,
                            offset: const Offset(
                              0,
                              8,
                            ), // Effet d'élévation rigide 3D
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007DA9).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Quiz Challenge',
                              style: TextStyle(
                                color: Color(0xFF006387),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            question.question,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111C2D),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Liste des réponses tactiles (Grid simulée par espacement)
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 32,
                    bottom: 40,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final answer = provider.currentAnswers[index];
                      return ShadowedButton(
                        letter: optionLetters[index % optionLetters.length],
                        text: answer,
                        isSelected:
                            false, // Pas d'état persistant visuel d'après tes contraintes
                        onTap: () => provider.submitAnswer(answer),
                      );
                    }, childCount: provider.currentAnswers.length),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
