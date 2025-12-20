import 'package:flutter/material.dart';

class TrophySprite extends StatelessWidget {
  final VoidCallback onTap;

  const TrophySprite({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        'assets/images/additional/trophy.png',
        width: 64,
        fit: BoxFit.contain,
      ),
    );
  }
}
