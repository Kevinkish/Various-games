import 'package:flutter/material.dart';
import 'package:quiz_master/ui/screens/quiz/quiz_home_screen.dart';

class HostPage extends StatelessWidget {
  const HostPage({super.key});

  @override
  Widget build(BuildContext context) {
    const List<Map<String, dynamic>> items = [
      {'icon': Icons.quiz, "title": "Quiz Home", "page": QuizHomeScreen()},
      {'icon': Icons.quiz, "title": "Quiz Home", "page": QuizHomeScreen()},
      {'icon': Icons.quiz, "title": "Quiz Home", "page": QuizHomeScreen()},
      {'icon': Icons.quiz, "title": "Quiz Home", "page": QuizHomeScreen()},
    ];
    return Scaffold(
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16.0),

          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            mainAxisExtent: 200,
          ),

          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item['page']),
                );
              },
              child: Center(
                child: Column(
                  spacing: 10,
                  mainAxisSize: .min,
                  children: [
                    Icon(item['icon']!, size: 40),
                    Text(item['title']!),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
