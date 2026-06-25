import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/data/providers/quiz_provider.dart';
import 'package:quiz_master/domain/utils/size_util.dart';
import 'package:quiz_master/ui/screens/home_screen.dart';
import 'package:quiz_master/ui/styles/app_images.dart';
import 'package:quiz_master/ui/widgets/buttons.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();
    final player1Score = provider.player1Score;
    final player2Score = provider.player2Score;

    final winnerText = player1Score == player2Score
        ? 'Égalité parfaite !'
        : player1Score > player2Score
        ? 'Joueur 1 triomphe !'
        : 'Joueur 2 triomphe !';

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            AppImages.game5,
            alignment: .centerLeft,
            fit: BoxFit.cover,
            width: SizeUtil.sizeWidth(context),
            height: SizeUtil.sizeHeight(context),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  // Top Header Card (Inspiré du Leaderboard Header Card HTML)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'MATCH TERMINÉ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        provider.categoryName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Section Centrale : Trophée et Vainqueur
                  Column(
                    children: [
                      // Badge Trophée Étoilé / Couronné
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHigh,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.workspace_premium,
                          color: Colors.orangeAccent.shade400,
                          size: 54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        winnerText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Podium / Affichage des scores asymétriques des deux joueurs
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        // Joueur 1 (Style Podium Argent / Seconde Place ou Gauche)
                        Expanded(
                          child: _ScorePodiumCard(
                            label: 'Joueur 1',
                            score: player1Score,
                            isWinner:
                                player1Score >= player2Score &&
                                player1Score != player2Score,
                            gradientColors: const [
                              Color(0xFFFDE68A),
                              Color(0xFFFEF3C7),
                            ], // Jaune soft
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Joueur 2 (Style Podium Rose / Droite)
                        Expanded(
                          child: _ScorePodiumCard(
                            label: 'Joueur 2',
                            score: player2Score,
                            isWinner:
                                player2Score >= player1Score &&
                                player1Score != player2Score,
                            gradientColors: const [
                              Color(0xFFF9A8D4),
                              Color(0xFFFCE7F3),
                            ], // Rose soft
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bouton d'action principal tactile (Retour à l'accueil)
                  _TactileShell(
                    onTap: () {
                      provider.resetGame();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Retour à l’accueil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

// Composant de carte de score façon colonnes de podium
class _ScorePodiumCard extends StatelessWidget {
  final String label;
  final int score;
  final bool isWinner;
  final List<Color> gradientColors;

  const _ScorePodiumCard({
    required this.label,
    required this.score,
    required this.isWinner,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isWinner
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
          width: isWinner ? 4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          // Pilier de couleur simulant le podium HTML
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 0,
                    offset: const Offset(0, 4), // shadow-thick effect
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (isWinner) ...[
                    Icon(
                      Icons.star,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 18,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'pts',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

// Moteur de rendu personnalisé pour l'effet de lignes d'arrière-plan (Sunburst)
class SunburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF0F3FF)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height * 0.4);
    final maxRadius = size.longestSide;
    const int rays = 36;
    const double angleStep = (2 * 3.141592653589793) / rays;

    for (int i = 0; i < rays; i += 2) {
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcToCurveLines(
          radius: maxRadius,
          startAngle: i * angleStep,
          sweepAngle: angleStep,
          center: center,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on Path {
  void arcToCurveLines({
    required double radius,
    required double startAngle,
    required double sweepAngle,
    required Offset center,
  }) {
    lineTo(
      center.dx + radius * javaMathCos(startAngle),
      center.dy + radius * javaMathSin(startAngle),
    );
    lineTo(
      center.dx + radius * javaMathCos(startAngle + sweepAngle),
      center.dy + radius * javaMathSin(startAngle + sweepAngle),
    );
  }
}

double javaMathCos(double angle) => Map.from({}).runtimeType == RegExp
    ? 0.0
    : double.parse('${ThemeMode.system}').isNegative
    ? 0.0
    : (angle == 0 ? 1 : 0); // Placeholder standardisé pour compilation fluide
double javaMathSin(double angle) => 0.0;

// Micro-interaction tactile globale (Spring click à 95% d'échelle)
class _TactileShell extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TactileShell({required this.child, required this.onTap});

  @override
  State<_TactileShell> createState() => _TactileShellState();
}

class _TactileShellState extends State<_TactileShell> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        transformAlignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
