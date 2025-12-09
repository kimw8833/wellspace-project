// lib/widgets/sprites/dog_sprite.dart

import 'package:flutter/material.dart';
import '../../utils/sprite_paths.dart';

class DogSprite extends StatelessWidget {
  final double mood;
  final double width;

  const DogSprite({
    super.key,
    required this.mood,
    this.width = 160,
  });

  @override
  Widget build(BuildContext context) {
    final double d = mood.clamp(0.0, 1.0);
    final String path = DogSprites.forMood(d);

    return SizedBox(
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
  }
}
