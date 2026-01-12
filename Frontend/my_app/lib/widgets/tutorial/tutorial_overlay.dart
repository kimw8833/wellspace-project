// lib/widgets/tutorial/tutorial_overlay.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'tutorial_controller.dart';

class TutorialOverlay extends StatefulWidget {
  final TutorialController controller;
  const TutorialOverlay({super.key, required this.controller});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_recalc);
    WidgetsBinding.instance.addPostFrameCallback((_) => _recalc());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_recalc);
    super.dispose();
  }

  void _recalc() {
    final key = widget.controller.current.targetKey;
    final ctx = key.currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final topLeft = box.localToGlobal(Offset.zero);
    final size = box.size;

    setState(() {
      _targetRect = Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height);
    });
  }

  @override
  Widget build(BuildContext context) {
    final rect = _targetRect;
    if (rect == null) return const SizedBox.shrink();

    final media = MediaQuery.of(context);
    final Size screen = media.size;

    // Bubble sizing
    const double bubbleWidth = 360.0;
    const double bubblePad = 14.0;
    const double gap = 16.0;

    // Space around target
    final double spaceTop = rect.top;
    final double spaceBottom = screen.height - rect.bottom;
    final double spaceLeft = rect.left;
    final double spaceRight = screen.width - rect.right;

    // Prefer below -> above -> right -> left
    final _Placement placement;
    if (spaceBottom > 210) {
      placement = _Placement.bottom;
    } else if (spaceTop > 210) {
      placement = _Placement.top;
    } else if (spaceRight > bubbleWidth) {
      placement = _Placement.right;
    } else {
      placement = _Placement.left;
    }

    // Bubble position
    double bubbleLeft = 0;
    double bubbleTop = 0;

    if (placement == _Placement.bottom || placement == _Placement.top) {
      final double idealLeft = rect.center.dx - bubbleWidth / 2;
      bubbleLeft = idealLeft.clamp(bubblePad, screen.width - bubbleWidth - bubblePad).toDouble();

      final double rawTop = placement == _Placement.bottom
          ? rect.bottom + gap
          : rect.top - gap - _Bubble.estimatedHeight;
      bubbleTop = rawTop.clamp(bubblePad, screen.height - _Bubble.estimatedHeight - bubblePad).toDouble();
    } else {
      bubbleTop = (rect.center.dy - _Bubble.estimatedHeight * 0.45)
          .clamp(bubblePad, screen.height - _Bubble.estimatedHeight - bubblePad)
          .toDouble();

      final double rawLeft = placement == _Placement.right
          ? rect.right + gap
          : rect.left - gap - bubbleWidth;
      bubbleLeft = rawLeft.clamp(bubblePad, screen.width - bubbleWidth - bubblePad).toDouble();
    }

    // Anchors: a point on target + a point on bubble edge
    final Offset targetAnchor = switch (placement) {
      _Placement.bottom => Offset(rect.center.dx, rect.bottom),
      _Placement.top => Offset(rect.center.dx, rect.top),
      _Placement.right => Offset(rect.right, rect.center.dy),
      _Placement.left => Offset(rect.left, rect.center.dy),
    };

    final Offset bubbleAnchor = switch (placement) {
      _Placement.bottom => Offset(
          targetAnchor.dx.clamp(bubbleLeft + 28, bubbleLeft + bubbleWidth - 28).toDouble(),
          bubbleTop,
        ),
      _Placement.top => Offset(
          targetAnchor.dx.clamp(bubbleLeft + 28, bubbleLeft + bubbleWidth - 28).toDouble(),
          bubbleTop + _Bubble.estimatedHeight,
        ),
      _Placement.right => Offset(
          bubbleLeft,
          targetAnchor.dy.clamp(bubbleTop + 28, bubbleTop + _Bubble.estimatedHeight - 28).toDouble(),
        ),
      _Placement.left => Offset(
          bubbleLeft + bubbleWidth,
          targetAnchor.dy.clamp(bubbleTop + 28, bubbleTop + _Bubble.estimatedHeight - 28).toDouble(),
        ),
    };

    final step = widget.controller.current;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dim + glow (no cutout, web-safe)
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.controller.next, // optional: tap anywhere = next
              child: CustomPaint(
                painter: _DimGlowPainter(targetRect: rect),
              ),
            ),
          ),

          // Soft "beam" connector instead of a triangle arrow
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BeamPainter(from: bubbleAnchor, to: targetAnchor),
              ),
            ),
          ),

          // Bubble
          Positioned(
            left: bubbleLeft,
            top: bubbleTop,
            width: bubbleWidth,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) {
                final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
                final scale = Tween<double>(begin: 0.98, end: 1.0).animate(fade);
                return FadeTransition(
                  opacity: fade,
                  child: ScaleTransition(scale: scale, child: child),
                );
              },
              child: _Bubble(
                key: ValueKey(step.title),
                title: step.title,
                body: step.body,
                isLast: widget.controller.isLast,
                onNext: widget.controller.next,
                onSkip: widget.controller.skip,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _Placement { top, bottom, left, right }

class _Bubble extends StatelessWidget {
  static const double estimatedHeight = 190;

  final String title;
  final String body;
  final bool isLast;
  final VoidCallback onNext;
  final Future<void> Function() onSkip;

  const _Bubble({
    super.key,
    required this.title,
    required this.body,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    // Paper-like gradient instead of flat fill
    final paper = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFF6F0E8).withOpacity(0.98),
        const Color(0xFFF1E9DE).withOpacity(0.98),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: paper,
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [
          // warmer, softer shadow (less "material tooltip")
          BoxShadow(
            blurRadius: 26,
            offset: const Offset(0, 14),
            color: Colors.black.withOpacity(0.22),
          ),
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.black.withOpacity(0.80),
              height: 1.25,
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black.withOpacity(0.88),
                    letterSpacing: 0.1,
                  ),
            ),
            const SizedBox(height: 8),
            Text(body),
            const SizedBox(height: 14),
            Row(
              children: [
                TextButton(
                  onPressed: () => onSkip(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black.withOpacity(0.55),
                  ),
                  child: const Text('Skip'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.84),
                    foregroundColor: const Color(0xFFF6F0E8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    elevation: 0,
                  ),
                  child: Text(isLast ? 'Done' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DimGlowPainter extends CustomPainter {
  final Rect targetRect;
  _DimGlowPainter({required this.targetRect});

  @override
  void paint(Canvas canvas, Size size) {
    // Softer dim overall
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0x88000000),
    );

    // "Lamp" spotlight: offset a bit downward, wide and soft
    final Offset c = Offset(
      targetRect.center.dx,
      targetRect.center.dy + targetRect.height * 0.20,
    );
    final double r = math.max(targetRect.width, targetRect.height) * 1.45;

    final spotlight = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF6F0E8).withOpacity(0.16),
          const Color(0xFFF6F0E8).withOpacity(0.00),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: r));

    canvas.drawCircle(c, r, spotlight);

    // Subtle bloom around object (no crisp ring)
    final RRect rr = RRect.fromRectAndRadius(
      targetRect.inflate(14),
      const Radius.circular(20),
    );

    final bloom = Paint()
      ..color = const Color(0xFFF6F0E8).withOpacity(0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

    canvas.drawRRect(rr, bloom);
  }

  @override
  bool shouldRepaint(covariant _DimGlowPainter oldDelegate) =>
      oldDelegate.targetRect != targetRect;
}

class _BeamPainter extends CustomPainter {
  final Offset from;
  final Offset to;

  _BeamPainter({required this.from, required this.to});

  @override
  void paint(Canvas canvas, Size size) {
    // A soft, short connector that feels like "light", not an arrow.
    final dir = (to - from);
    final dist = dir.distance;
    if (dist < 1) return;

    final Offset a = from;
    final Offset b = to;

    // Gradient along the beam (stronger near target)
    final rect = Rect.fromPoints(a, b).inflate(24);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFF6F0E8).withOpacity(0.10),
          const Color(0xFFF6F0E8).withOpacity(0.24),
        ],
      ).createShader(rect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // Draw only part of the beam so it doesn't look like a pointer line
    final t = math.min(1.0, 120.0 / dist); // cap to ~120px
    final Offset mid = Offset(
      a.dx + dir.dx * t,
      a.dy + dir.dy * t,
    );

    canvas.drawLine(a, mid, paint);
  }

  @override
  bool shouldRepaint(covariant _BeamPainter oldDelegate) =>
      oldDelegate.from != from || oldDelegate.to != to;
}
