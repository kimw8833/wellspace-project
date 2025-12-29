// lib/widgets/fx/coin_fly_fx.dart

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class CoinFlyFx {
  static Future<void> play({
    required BuildContext context,
    required Offset from,
    required Offset to,
    int coinCount = 10,
    Duration duration = const Duration(milliseconds: 1800),
    VoidCallback? onArrive,
  }) async {
    final overlay = Overlay.of(context, rootOverlay: true);
    if (overlay == null) return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _CoinBurstFlight(
        from: from,
        to: to,
        coinCount: coinCount,
        duration: duration,
        onDone: () {
          entry.remove();
          onArrive?.call();
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _CoinBurstFlight extends StatefulWidget {
  final Offset from;
  final Offset to;
  final int coinCount;
  final Duration duration;
  final VoidCallback onDone;

  const _CoinBurstFlight({
    required this.from,
    required this.to,
    required this.coinCount,
    required this.duration,
    required this.onDone,
  });

  @override
  State<_CoinBurstFlight> createState() => _CoinBurstFlightState();
}

class _CoinBurstFlightState extends State<_CoinBurstFlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  late final List<Offset> _burstOffsets;
  late final List<double> _delays;

  @override
  void initState() {
    super.initState();

    _c = AnimationController(vsync: this, duration: widget.duration);
    _t = CurvedAnimation(parent: _c, curve: Curves.linear);

    final rng = Random(7);

    // Calm spread so it reads as a little pile, not an explosion
    const spread = 18.0;

    _burstOffsets = List.generate(widget.coinCount, (_) {
      final dx = (rng.nextDouble() * 2 - 1) * spread;
      final dy = (rng.nextDouble() * 2 - 1) * spread;
      return Offset(dx, dy);
    });

    // Tiny stagger, almost imperceptible (reduces wasp feel)
    _delays = List.generate(widget.coinCount, (i) {
      if (widget.coinCount <= 1) return 0.0;
      final frac = i / (widget.coinCount - 1);
      return frac * 0.03; // max 3% delay
    });

    _c.forward();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Offset _quadBezier(Offset a, Offset b, Offset c, double t) {
    final ab = Offset.lerp(a, b, t)!;
    final bc = Offset.lerp(b, c, t)!;
    return Offset.lerp(ab, bc, t)!;
  }

  // ✅ Emoji rendered via WidgetSpan to avoid underline/baseline artifacts
  Widget _emojiCoin({double size = 26}) {
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Text(
              '🪙',
              style: TextStyle(
                fontSize: size,
                // These help avoid weird font fallback behavior:
                height: 1.0,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final from = widget.from;
    final to = widget.to;

    // Nice readable arc
    final mid = Offset(
      (from.dx + to.dx) / 2,
      min(from.dy, to.dy) - 120,
    );

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _t,
        builder: (_, __) {
          final tt = _t.value;

          return Stack(
            children: List.generate(widget.coinCount, (i) {
              final tStaggered = (tt - _delays[i]).clamp(0.0, 1.0);

              // Longer calm pop so you can REGISTER the coins
              const popPhase = 0.42;

              final start = from + _burstOffsets[i];

              Offset pos;
              double scale;
              double opacity;

              if (tStaggered < popPhase) {
                // POP: smooth drift outwards, no bounce
                final u = (tStaggered / popPhase).clamp(0.0, 1.0);
                final pop = Curves.easeOutCubic.transform(u);

                pos = Offset.lerp(from, start, pop)!;

                // Gentle grow-in
                scale = lerpDouble(0.78, 1.00, pop)!;

                opacity = 1.0;
              } else {
                // FLY: smooth travel
                final u = ((tStaggered - popPhase) / (1.0 - popPhase))
                    .clamp(0.0, 1.0);
                final eased = Curves.easeInOutCubic.transform(u);

                pos = _quadBezier(start, mid, to, eased);

                // Slight shrink as it flies
                scale = lerpDouble(1.00, 0.82, eased)!;

                // Fade only right at the end
                final fade = ((eased - 0.92) / 0.08).clamp(0.0, 1.0);
                opacity = lerpDouble(1.0, 0.0, fade)!;
              }

              return Positioned(
                left: pos.dx - 13,
                top: pos.dy - 13,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: _emojiCoin(size: 26),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
