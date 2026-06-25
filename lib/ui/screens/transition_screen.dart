import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/data/providers/quiz_provider.dart';
import 'package:quiz_master/domain/utils/size_util.dart';
import 'package:quiz_master/ui/screens/quiz_screen.dart';
import 'package:quiz_master/ui/styles/app_colors.dart';
import 'package:quiz_master/ui/styles/app_images.dart';

class TransitionScreen extends StatelessWidget {
  const TransitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: .max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(.12),
                          blurRadius: 30,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(.12),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.sync_alt,
                            color: AppColors.primary,
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Joueur 1 a terminé.',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Passez le téléphone au Joueur 2 sans montrer les réponses.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.6,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 48,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
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
          ),
        ],
      ),
    );
  }
}
