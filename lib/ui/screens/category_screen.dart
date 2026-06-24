import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/data/datasource/remote/category_service/trivia_category_service.dart';
import 'package:quiz_master/data/datasource/remote/dto/trivia_category.dart';
import 'package:quiz_master/data/providers/quiz_provider.dart';
import 'package:quiz_master/domain/utils/size_util.dart';
import 'package:quiz_master/ui/screens/quiz_screen.dart';
import 'package:quiz_master/ui/styles/app_images.dart';

class CategoryScreen extends StatelessWidget {
  final CategoryService _categoryService = CategoryService();

  CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir une catégorie')),
      body: Stack(
        children: [
          Image.asset(
            AppImages.game2,
            fit: BoxFit.cover,
            width: SizeUtil.sizeWidth(context),
            height: SizeUtil.sizeHeight(context),
          ),
          FutureBuilder<List<TriviaCategory>>(
            future: _categoryService.fetchCategories(),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (asyncSnapshot.hasError) {
                return Center(child: Text('Erreur: ${asyncSnapshot.error}'));
              }
              if (!asyncSnapshot.hasData || asyncSnapshot.data!.isEmpty) {
                return const Center(child: Text('Aucune catégorie trouvée.'));
              }
              final categories = asyncSnapshot.data ?? [];
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: categories.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(category.name),
                    subtitle: Text('ID ${category.id}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () async {
                      final id = category.id;
                      final name = category.name;
                      if (!context.mounted) return;

                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      await context.read<QuizProvider>().fetchQuestions(
                        id,
                        name,
                      );

                      if (!context.mounted) return;
                      Navigator.of(context).pop();

                      final currentPhase = context.read<QuizProvider>().phase;
                      if (currentPhase == QuizPhase.player1) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const QuizScreen()),
                        );
                      } else if (currentPhase == QuizPhase.error) {
                        final error =
                            context.read<QuizProvider>().errorMessage ??
                            'Erreur inconnue';
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(error)));
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
