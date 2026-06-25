import 'package:flutter/material.dart';

class ShadowedButton extends StatefulWidget {
  final String letter;
  final Icon? icon;
  final String text;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const ShadowedButton({
    super.key,
    required this.letter,
    this.icon,
    this.description = '',
    required this.text,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<ShadowedButton> createState() => ShadowedButtonState();
}

class ShadowedButtonState extends State<ShadowedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Styles basés sur le thème Quivio HTML
    final isSelected = widget.isSelected;
    final backgroundColor = isSelected
        ? const Color(0xFF4648d4)
        : const Color(0xFFFFFFFF);
    final textColor = isSelected ? Colors.white : const Color(0xFF111C2D);
    final shadowColor = const Color(0xFF4648D4).withOpacity(0.15);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 8),
        // L'effet 3D : si pressé, le conteneur descend de 4px
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFDEE8FF),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 0,
              // L'ombre s'écrase (passe de 8px à 4px) quand on appuie
              offset: Offset(0, _isPressed ? 4 : 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Bulle de la lettre (A, B, C, D)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFFDEE8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child:
                  widget.icon ??
                  Text(
                    widget.letter,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF767586),
                    ),
                  ),
            ),
            const SizedBox(width: 16),
            // Libellé de la réponse
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (widget.description.isNotEmpty)
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// Micro-interaction tactile globale (Spring click à 95% d'échelle)
class TactileShell extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const TactileShell({super.key, required this.child, required this.onTap});

  @override
  State<TactileShell> createState() => TactileShellState();
}

class TactileShellState extends State<TactileShell> {
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
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
