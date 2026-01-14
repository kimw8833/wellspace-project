// lib/widgets/sprites/dog_sprite.dart

import 'package:flutter/material.dart';
import '../../utils/sprite_paths.dart';

class DogSprite extends StatelessWidget {
  final double mood;
  final double width;

  /// Called when the dog is tapped (e.g. open steps dialog)
  final VoidCallback? onTap;

  const DogSprite({
    super.key,
    required this.mood,
    this.width = 160,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double d = mood.clamp(0.0, 1.0);
    final String path = DogSprites.forMood(d);

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
          key: ValueKey(path),
          width: width,
          fit: BoxFit.contain,
        ),
      ),
    );

    if (onTap == null) return sprite;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: sprite,
    );
  }
}
