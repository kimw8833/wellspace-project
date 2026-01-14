// lib/widgets/sprites/plant_sprite.dart

import 'package:flutter/material.dart';
import '../../utils/sprite_paths.dart';

class PlantSprite extends StatelessWidget {
  final double health;
  final double width;

  /// Called when the plant is tapped (e.g. open water dialog)
  final VoidCallback? onTap;

  const PlantSprite({
    super.key,
    required this.health,
    this.width = 180,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double s = health.clamp(0.0, 1.0);
    final int index = PlantSprites.indexForHealth(s);
    final String path = PlantSprites.stages[index];

    final sprite = SizedBox(
      width: width,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: Image.asset(
          path,
          key: ValueKey(index),
          width: width,
          fit: BoxFit.contain,
        ),
      ),
    );

    // If no interaction is needed, return as-is
    if (onTap == null) return sprite;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: sprite,
    );
  }
}
