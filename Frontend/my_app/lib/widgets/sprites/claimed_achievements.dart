import 'package:flutter/material.dart';

import '../../controllers/room_controller.dart';
import '../../models/achievement_definitions.dart';
import 'achievement_row.dart';

class ClaimedAchievements extends StatefulWidget {
  final RoomController controller;

  const ClaimedAchievements({
    super.key,
    required this.controller,
  });

  @override
  State<ClaimedAchievements> createState() => _ClaimedAchievementsState();
}

class _ClaimedAchievementsState extends State<ClaimedAchievements> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final defs = achievementDefinitions.values.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    final claimedDefs = defs.where((def) {
      // Tiered: show if at least 1 tier has been completed/claimed
      if (def.isTiered) {
        final completedCount =
            widget.controller.achievementTier(def.index).clamp(0, def.tiers.length);
        return completedCount > 0;
      }

      // Single: show if claimed
      return widget.controller.isAchievementClaimed(def.index);
    }).toList();

    if (claimedDefs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Text(
            'No claimed achievements yet.',
            style: const TextStyle(
              fontFamily: 'serif',
              color: Color(0xFF6A6A6A),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final def in claimedDefs) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: def.isTiered
                ? _TieredClaimedCard(
                    def: def,
                    completedCount: widget.controller
                        .achievementTier(def.index)
                        .clamp(0, def.tiers.length),
                    expanded: _expanded.contains(def.index),
                    onToggle: () {
                      setState(() {
                        if (_expanded.contains(def.index)) {
                          _expanded.remove(def.index);
                        } else {
                          _expanded.add(def.index);
                        }
                      });
                    },
                  )
                : _SingleClaimedRow(def: def),
          ),
        ],
      ],
    );
  }
}

class _SingleClaimedRow extends StatelessWidget {
  final AchievementDefinition def;

  const _SingleClaimedRow({required this.def});

  @override
  Widget build(BuildContext context) {
    // Use the SAME AchievementRow so the muted/grey look matches exactly.
    return AchievementRow(
      definition: def,
      progress: 100,
      completed: true,
      claimed: true,
      isPlaceholder: def.title.trim() == '—' && def.rewardCoins == 0,
      onClaim: (_) {}, // not used on claimed rows
      style: AchievementRowStyle.diploma,
    );
  }
}

class _TieredClaimedCard extends StatelessWidget {
  final AchievementDefinition def;
  final int completedCount;
  final bool expanded;
  final VoidCallback onToggle;

  const _TieredClaimedCard({
    required this.def,
    required this.completedCount,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // We intentionally mimic AchievementRow's "claimed muted" vibe.
    // That is: low-contrast text/icon + subtle background.
    final mutedTitle = Colors.black.withOpacity(0.45);
    final mutedBody = Colors.black.withOpacity(0.40);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.verified,
                    size: 22,
                    color: Colors.black.withOpacity(0.35),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          def.title,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: mutedTitle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedCount completed milestone${completedCount == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 13,
                            height: 1.2,
                            color: mutedBody,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.black.withOpacity(0.35),
                  ),
                ],
              ),
            ),
          ),

          if (expanded) ...[
            const SizedBox(height: 6),
            _CompletedMilestonesPanel(
              tiers: def.tiers,
              completedCount: completedCount,
            ),
          ],
        ],
      ),
    );
  }
}

class _CompletedMilestonesPanel extends StatelessWidget {
  final List<AchievementTier> tiers;
  final int completedCount;

  const _CompletedMilestonesPanel({
    required this.tiers,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final count = completedCount.clamp(0, tiers.length);
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completed milestones',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.black.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < count; i++) ...[
            _MilestoneLine(
              targetDays: tiers[i].target,
              reward: tiers[i].rewardCoins,
              isLast: i == count - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _MilestoneLine extends StatelessWidget {
  final int targetDays;
  final int reward;
  final bool isLast;

  const _MilestoneLine({
    required this.targetDays,
    required this.reward,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        children: [
          Icon(Icons.verified, size: 16, color: Colors.black.withOpacity(0.45)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$targetDays-day hydration streak',
              style: TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.w700,
                color: Colors.black.withOpacity(0.60),
              ),
            ),
          ),
          Text(
            '🪙 $reward',
            style: TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.w800,
              color: Colors.black.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}
