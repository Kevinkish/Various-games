import 'package:flutter/material.dart';
import 'package:quiz_master/cashFlow/ui/screens/expense_list_screen.dart';
import 'package:quiz_master/moodly/ui/screens/mood_home_screen.dart';
import 'package:quiz_master/nearby/ui/screens/nearby_home_screen.dart';
import 'package:quiz_master/qr_code/ui/screens/qr_home_screen.dart';
import 'package:quiz_master/quiz_master/ui/screens/quiz/quiz_home_screen.dart';

class HostPage extends StatelessWidget {
  const HostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const items = <_HostItem>[
      _HostItem(icon: Icons.quiz, title: 'Quiz Home', page: QuizHomeScreen()),
      _HostItem(
        icon: Icons.money,
        title: 'CashFlow',
        page: ExpenseListScreen(),
      ),
      _HostItem(icon: Icons.mood, title: 'Moodly', page: MoodHomeScreen()),
      _HostItem(icon: Icons.place, title: 'NearBy', page: NearbyHomeScreen()),
      _HostItem(icon: Icons.qr_code, title: 'QR Code', page: QrHomeScreen()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Applications rapides',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item.page),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.surfaceContainerHighest,
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: Text(
                          'Explorez cette fonctionnalité',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HostItem {
  final IconData icon;
  final String title;
  final Widget page;

  const _HostItem({
    required this.icon,
    required this.title,
    required this.page,
  });
}
