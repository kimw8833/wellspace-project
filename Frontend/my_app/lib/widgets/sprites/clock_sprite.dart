import 'dart:math';
import 'package:flutter/material.dart';

class ClockSprite extends StatelessWidget {
  final DateTime time;
  final double size;

  const ClockSprite({
    super.key,
    required this.time,
    this.size = 130,
  });

  Widget _hand({
    required double angle,
    required double length,
    required double thickness,
    required Color color,
    double opacity = 1.0,
  }) {
    return Transform.rotate(
      angle: angle,
      child: Transform.translate(
        // Base of the hand at the center of the clock
        offset: Offset(0, -length / 2),
        child: Container(
          width: thickness,
          height: length,
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
            borderRadius: BorderRadius.circular(thickness),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double radius = size / 2;

    // Smooth time components
    final double seconds = time.second + time.millisecond / 1000.0;
    final double minutes = time.minute + seconds / 60.0;
    final double hours = (time.hour % 12) + minutes / 60.0;

    // IMPORTANT:
    // Our hand is already "12 o'clock up" at angle=0, so NO -pi/2 offset.
    final double secondAngle = (seconds / 60.0) * 2 * pi;
    final double minuteAngle = (minutes / 60.0) * 2 * pi;
    final double hourAngle = (hours / 12.0) * 2 * pi;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Clock face placeholder
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.35),
              border: Border.all(
                color: Colors.white.withOpacity(0.85),
                width: 3,
              ),
            ),
          ),

          // Hour hand
          _hand(
            angle: hourAngle,
            length: radius * 0.42,
            thickness: 5.2,
            color: Colors.white,
            opacity: 0.92,
          ),

          // Minute hand
          _hand(
            angle: minuteAngle,
            length: radius * 0.63,
            thickness: 3.4,
            color: Colors.white,
            opacity: 0.95,
          ),

          // Second hand
          _hand(
            angle: secondAngle,
            length: radius * 0.78,
            thickness: 2.2,
            color: Colors.redAccent,
            opacity: 0.95,
          ),

          // Center pin
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
