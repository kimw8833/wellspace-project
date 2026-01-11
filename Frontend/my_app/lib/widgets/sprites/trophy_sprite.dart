import 'package:flutter/material.dart';

class TrophySprite extends StatefulWidget {
  final VoidCallback onTap;

  /// When true, the trophy breathes/pulses to indicate claimable achievements.
  final bool glow;

  const TrophySprite({
    super.key,
    required this.onTap,
    this.glow = false,
  });

  @override
  State<TrophySprite> createState() => _TrophySpriteState();
}

class _TrophySpriteState extends State<TrophySprite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    if (widget.glow) {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant TrophySprite oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.glow != widget.glow) {
      if (widget.glow) {
        _pulseCtrl.repeat(reverse: true);
      } else {
        _pulseCtrl.stop();
        _pulseCtrl.value = 0; // reset to “no glow”
      }
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (context, child) {
          // 0..1
          final t = widget.glow ? _pulseCtrl.value : 0.0;

          // A gentle "breathing" scale (optional but helps readability)
          final scale = 1.0 + (0.03 * t);

          // Stronger, clearer glow:
          // - opacity breathes
          // - blur/spread breathes
          final glowOpacity = 0.18 + (0.55 * t);
          final blur = 10.0 + (22.0 * t);
          final spread = 0.5 + (2.8 * t);

          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.glow
                    ? [
                        BoxShadow(
                          color: const Color(0xFFF2D08A).withOpacity(glowOpacity),
                          blurRadius: blur,
                          spreadRadius: spread,
                        ),
                        // a softer ambient glow to make it read on warm backgrounds
                        BoxShadow(
                          color: Colors.white.withOpacity(0.06 + 0.10 * t),
                          blurRadius: 6 + 10 * t,
                          spreadRadius: 0.2 + 0.6 * t,
                        ),
                      ]
                    : const [],
              ),
              child: child,
            ),
          );
        },
        child: Image.asset(
          'assets/images/additional/trophy.png',
          width: 64,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
