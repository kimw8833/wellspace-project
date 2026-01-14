// lib/widgets/sprites/clock_sprite.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';

class ClockSprite extends StatelessWidget {
  final DateTime time;
  final double size;

  final bool showDebugCircle;

  final Offset faceOffset = const Offset(2, 0);

  const ClockSprite({
    super.key,
    required this.time,
    this.size = 150,
    this.showDebugCircle = false,
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

    // Smooth time
    final double seconds = time.second + time.millisecond / 1000.0;
    final double minutes = time.minute + seconds / 60.0;
    final double hours = (time.hour % 12) + minutes / 60.0;

    final double secondAngle = (seconds / 60.0) * 2 * pi;
    final double minuteAngle = (minutes / 60.0) * 2 * pi;
    final double hourAngle = (hours / 12.0) * 2 * pi;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // =============================
          // DEBUG CIRCLE (OPTIONAL)
          // =============================
          if (showDebugCircle)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 2,
                ),
              ),
            ),

          // =============================
          // CLOCK FACE IMAGE (EDGE FEATHER)
          // =============================
          Transform.translate(
            offset: faceOffset,
            child: Transform.rotate(
              angle: -1 * pi / 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Soft blur mask behind the clock
                  ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1.2, sigmaY: 1.2),
                      child: Container(
                        width: size + 2,
                        height: size + 2,
                        color: Colors.transparent,
                      ),
                    ),
                  ),

                  // Actual clock image
                  Image.asset(
                    "assets/images/additional/wall_clock.png",
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),

          // =============================
          // HANDS
          // =============================
          _hand(
            angle: hourAngle,
            length: radius * 0.3,
            thickness: 5.2,
            color: Colors.black,
            opacity: 0.92,
          ),
          _hand(
            angle: minuteAngle,
            length: radius * 0.53,
            thickness: 3.4,
            color: Colors.black,
            opacity: 0.95,
          ),
          _hand(
            angle: secondAngle,
            length: radius * 0.53,
            thickness: 2.2,
            color: Colors.redAccent,
            opacity: 0.95,
          ),

          // =============================
          // CENTER PIN (HIDES SINS)
          // =============================
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
