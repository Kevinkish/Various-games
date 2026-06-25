import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/data/datasource/remote/category_service/trivia_category_service.dart';
import 'package:quiz_master/data/datasource/remote/dto/trivia_category.dart';
import 'package:quiz_master/data/providers/quiz_provider.dart';
import 'package:quiz_master/domain/utils/size_util.dart';
import 'package:quiz_master/ui/screens/quiz_screen.dart';
import 'package:quiz_master/ui/styles/app_colors.dart';
import 'package:quiz_master/ui/styles/app_images.dart';
import 'package:quiz_master/ui/widgets/buttons.dart';

class CategoryScreen extends StatelessWidget {
  final CategoryService _categoryService = CategoryService();

  CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: Stack(
        children: [
          Image.asset(
            AppImages.game4,
            alignment: .centerStart,
            fit: BoxFit.cover,
            width: SizeUtil.sizeWidth(context),
            height: SizeUtil.sizeHeight(context),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 18.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    spacing: 6,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choisir une catégorie',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Sélectionne une ambiance et lance le duel.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),
                  Expanded(
                    child: FutureBuilder<List<TriviaCategory>>(
                      future: _categoryService.fetchCategories(),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        }

                        if (asyncSnapshot.hasError) {
                          return Center(
                            child: Text(
                              'Erreur : ${asyncSnapshot.error}',
                              style: TextStyle(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        final categories = asyncSnapshot.data ?? [];
                        if (categories.isEmpty) {
                          return Center(
                            child: Text(
                              'Aucune catégorie trouvée.',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return TactileShell(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 20,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: .1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${category.id}',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: AppColors.onSurface,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Un pack de questions pour tester ta culture.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ),

                              onTap: () async {
                                if (!context.mounted) return;
                                showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (ctx) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                await context
                                    .read<QuizProvider>()
                                    .fetchQuestions(category.id, category.name);

                                if (!context.mounted) return;
                                Navigator.of(context).pop();

                                final currentPhase = context
                                    .read<QuizProvider>()
                                    .phase;
                                if (currentPhase == QuizPhase.player1) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const QuizScreen(),
                                    ),
                                  );
                                } else if (currentPhase == QuizPhase.error) {
                                  final error =
                                      context
                                          .read<QuizProvider>()
                                          .errorMessage ??
                                      'Erreur inconnue';
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error)),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
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
