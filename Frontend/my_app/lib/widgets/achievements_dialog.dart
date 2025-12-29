import 'dart:ui';
import 'package:flutter/material.dart';

import '../controllers/room_controller.dart';
import '../models/achievement_definitions.dart';
import 'sprites/achievement_row.dart';


// NEW: coin fly overlay helper
import 'fx/coin_fly_fx.dart';

class AchievementsDialog extends StatefulWidget {
  final RoomController controller;

  // NEW: target key for the coin pill in room_page
  final GlobalKey coinPillKey;

  const AchievementsDialog({
    super.key,
    required this.controller,
    required this.coinPillKey,
  });

  @override
  State<AchievementsDialog> createState() => _AchievementsDialogState();
}

class _AchievementsDialogState extends State<AchievementsDialog> {
  int _tabIndex = 0; // 0 = Unclaimed, 1 = Claimed

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black.withOpacity(0.18)),
              ),
            ),
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Keep the diploma from exceeding the viewport height
                  final maxH = constraints.maxHeight * 0.92;

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 900,
                      maxHeight: maxH,
                    ),
                    child: _DiplomaFrame(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 22, 28, 18),
                        child: Column(
                          children: [
                            // HEADER
                            Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                        'Certificate of Progress',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'serif',
                                          fontSize: 30,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                          color: Color(0xFF2A2A2A),
                                          height: 1.1,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Wellspace Achievements',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'serif',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.2,
                                          color: Color(0xFF5A5A5A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.close),
                                  color: const Color(0xFF2A2A2A),
                                  tooltip: 'Close',
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                const Expanded(child: _Hairline()),
                                const SizedBox(width: 10),
                                Icon(Icons.emoji_events_outlined,
                                    color: Colors.black.withOpacity(0.35),
                                    size: 18),
                                const SizedBox(width: 10),
                                const Expanded(child: _Hairline()),
                              ],
                            ),

                            const SizedBox(height: 16),

                            _DiplomaToggle(
                              index: _tabIndex,
                              onChanged: (i) => setState(() => _tabIndex = i),
                            ),

                            const SizedBox(height: 14),

                            // CONTENT AREA (scrollable)
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _AchievementList(
                                    controller: widget.controller,
                                    showClaimed: _tabIndex == 1,
                                    coinPillKey: widget.coinPillKey,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // FOOTER (seal + signatures) — no overflow now
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: const [
                                      _Hairline(),
                                      SizedBox(height: 6),
                                      Text(
                                        'Room Keeper',
                                        style: TextStyle(
                                          fontFamily: 'serif',
                                          fontSize: 12,
                                          color: Color(0xFF6A6A6A),
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const _Seal(),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    children: const [
                                      _Hairline(),
                                      SizedBox(height: 6),
                                      Text(
                                        'Date Awarded',
                                        style: TextStyle(
                                          fontFamily: 'serif',
                                          fontSize: 12,
                                          color: Color(0xFF6A6A6A),
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Close',
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2A2A2A),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AchievementList extends StatelessWidget {
  final RoomController controller;
  final bool showClaimed;

  // NEW
  final GlobalKey coinPillKey;

  const _AchievementList({
    required this.controller,
    required this.showClaimed,
    required this.coinPillKey,
  });

  @override
  Widget build(BuildContext context) {
    final defs = achievementDefinitions.values.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    final filtered = defs.where((def) {
      final claimed = controller.isAchievementClaimed(def.index);
      return showClaimed ? claimed : !claimed;
    }).toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Text(
            showClaimed
                ? 'No claimed achievements yet.'
                : 'No unclaimed achievements.',
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
        for (final def in filtered) ...[
          Builder(builder: (context) {
            final progress = controller.achievementProgress(def.index);
            final completed = controller.isAchievementCompleted(def.index);
            final claimed = controller.isAchievementClaimed(def.index);
            final isPlaceholder = def.title.trim() == '—' && def.rewardCoins == 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AchievementRow(
                definition: def,
                progress: progress,
                completed: completed,
                claimed: claimed,
                isPlaceholder: isPlaceholder,

                // UPDATED: now receives the "from" position of the CLAIM button
                onClaim: (fromGlobal) async {
                  // 1) Find target pill position (where coins should fly to)
                  final pillCtx = coinPillKey.currentContext;
                  final pillBox = pillCtx?.findRenderObject() as RenderBox?;
                  if (pillBox == null) return;

                  final toGlobal =
                      pillBox.localToGlobal(pillBox.size.center(Offset.zero));

                  // 2) Claim in logic (this should update controller.coins)
                  final before = controller.coins;
                  controller.claimAchievement(def.index);
                  final after = controller.coins;
                  final reward = after - before;

                  // If no reward change, don't animate
                  if (reward <= 0) return;

                  // 3) Fly coins overlay; when it lands, ramp the number
                  final swarm = (reward / 5).clamp(6, 14).toInt();

                  await CoinFlyFx.play(
                    context: context,
                    from: fromGlobal,
                    to: toGlobal,
                    coinCount: swarm,
                    duration: const Duration(milliseconds: 1600),
                    onArrive: () {
                      controller.rampCoinsDisplayTo(after);
                    },
                  );
                },

                style: AchievementRowStyle.diploma,
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _DiplomaFrame extends StatelessWidget {
  final Widget child;

  const _DiplomaFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2C1F16),
                Color(0xFF4A3324),
                Color(0xFF2C1F16),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                blurRadius: 35,
                offset: const Offset(0, 18),
                color: Colors.black.withOpacity(0.25),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE7DECf),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withOpacity(0.15)),
            ),
            padding: const EdgeInsets.all(14),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F4EA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withOpacity(0.18)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                    color: Colors.black.withOpacity(0.12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.08,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Color(0xFFF1E7D7),
                                Colors.white,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiplomaToggle extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _DiplomaToggle({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget pill(String text, int i) {
      final selected = index == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            height: 42,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF2A2A2A) : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.black.withOpacity(0.18)),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: selected
                      ? const Color(0xFFF9F4EA)
                      : const Color(0xFF2A2A2A),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withOpacity(0.04),
        border: Border.all(color: Colors.black.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          pill('UNCLAIMED', 0),
          const SizedBox(width: 6),
          pill('CLAIMED', 1),
        ],
      ),
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: Colors.black.withOpacity(0.18));
  }
}

class _Seal extends StatelessWidget {
  const _Seal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF8B1E1E),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.18),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF2D08A), width: 2),
          ),
          child: const Center(
            child: Icon(Icons.star, color: Color(0xFFF2D08A), size: 18),
          ),
        ),
      ),
    );
  }
}
