import 'package:flutter/material.dart';
import '../../models/achievement_definitions.dart';

enum AchievementRowStyle { cozy, diploma }

class AchievementRow extends StatelessWidget {
  final AchievementDefinition definition;
  final int progress; // 0-100
  final bool completed;
  final bool claimed;
  final bool isPlaceholder;
  final VoidCallback onClaim;
  final AchievementRowStyle style;

  const AchievementRow({
    super.key,
    required this.definition,
    required this.progress,
    required this.completed,
    required this.claimed,
    required this.isPlaceholder,
    required this.onClaim,
    this.style = AchievementRowStyle.cozy,
  });

  @override
  Widget build(BuildContext context) {
    return style == AchievementRowStyle.diploma ? _DiplomaRow(this) : _CozyRow(this);
  }
}

class _DiplomaRow extends StatelessWidget {
  final AchievementRow p;
  const _DiplomaRow(this.p);

  @override
  Widget build(BuildContext context) {
    final prog = p.progress.clamp(0, 100);
    final muted = p.claimed || p.isPlaceholder;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            p.isPlaceholder
                ? Icons.auto_awesome_outlined
                : (p.claimed ? Icons.verified : (p.completed ? Icons.check_circle : Icons.bookmark_border)),
            color: Colors.black.withOpacity(muted ? 0.35 : 0.55),
            size: 22,
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.definition.title,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(muted ? 0.45 : 0.85),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.definition.description,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 13,
                    height: 1.2,
                    color: Colors.black.withOpacity(muted ? 0.35 : 0.55),
                  ),
                ),
                const SizedBox(height: 10),
                if (!p.isPlaceholder) ...[
                  _DiplomaProgress(value: prog / 100.0, muted: p.claimed),
                  const SizedBox(height: 6),
                  Text(
                    p.claimed ? 'Collected' : '$prog%',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          _DiplomaRightSide(
            coins: p.definition.rewardCoins,
            isPlaceholder: p.isPlaceholder,
            completed: p.completed,
            claimed: p.claimed,
            onClaim: p.onClaim,
          ),
        ],
      ),
    );
  }
}

class _DiplomaRightSide extends StatelessWidget {
  final int coins;
  final bool isPlaceholder;
  final bool completed;
  final bool claimed;
  final VoidCallback onClaim;

  const _DiplomaRightSide({
    required this.coins,
    required this.isPlaceholder,
    required this.completed,
    required this.claimed,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    if (isPlaceholder) {
      return _CoinPill(coins: coins, muted: true);
    }

    if (claimed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _CoinPill(coins: coins, muted: true),
          const SizedBox(height: 8),
          _Stamp('CLAIMED'),
        ],
      );
    }

    if (!completed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _CoinPill(coins: coins, muted: false),
          const SizedBox(height: 8),
          _Stamp('LOCKED', muted: true),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _CoinPill(coins: coins, muted: false),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onClaim,
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF2A2A2A),
            foregroundColor: const Color(0xFFF9F4EA),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'CLAIM',
            style: TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

class _CoinPill extends StatelessWidget {
  final int coins;
  final bool muted;

  const _CoinPill({required this.coins, required this.muted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: muted ? Colors.black.withOpacity(0.05) : const Color(0xFFF2D08A).withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.12)),
      ),
      child: Text(
        '🪙 $coins',
        style: TextStyle(
          fontFamily: 'serif',
          fontWeight: FontWeight.w800,
          color: Colors.black.withOpacity(muted ? 0.45 : 0.75),
        ),
      ),
    );
  }
}

class _Stamp extends StatelessWidget {
  final String label;
  final bool muted;
  const _Stamp(this.label, {this.muted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(muted ? 0.04 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(muted ? 0.12 : 0.20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w900,
          color: Colors.black.withOpacity(muted ? 0.45 : 0.65),
        ),
      ),
    );
  }
}

class _DiplomaProgress extends StatelessWidget {
  final double value;
  final bool muted;

  const _DiplomaProgress({required this.value, required this.muted});

  @override
  Widget build(BuildContext context) {
    final bg = Colors.black.withOpacity(0.10);
    final fill = muted ? Colors.black.withOpacity(0.16) : const Color(0xFF8B6B2B).withOpacity(0.70);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 9,
        color: bg,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(color: fill),
          ),
        ),
      ),
    );
  }
}

// Kept so you can switch styles later without breaking imports.
// Not used by the diploma dialog right now.
class _CozyRow extends StatelessWidget {
  final AchievementRow p;
  const _CozyRow(this.p);

  @override
  Widget build(BuildContext context) {
    // fallback simple
    return _DiplomaRow(p);
  }
}
