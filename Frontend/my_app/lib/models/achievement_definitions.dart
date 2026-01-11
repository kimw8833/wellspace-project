// lib/models/achievement_definitions.dart

/// What type of achievement this is.
enum AchievementKind {
  /// One-and-done achievements (like your Explorer one).
  single,

  /// Tiered achievements where each tier is a milestone (like streaks).
  tiered,
}

/// One tier in a tiered achievement.
class AchievementTier {
  /// Tier number (1-based for humans).
  final int tier;

  /// The target to complete this tier (meaning depends on the achievement logic).
  /// For hydration streak: "consecutive days hitting goal".
  final int target;

  /// Coins earned when claiming this tier.
  final int rewardCoins;

  const AchievementTier({
    required this.tier,
    required this.target,
    required this.rewardCoins,
  });
}

class AchievementDefinition {
  final int index;
  final String title;
  final String description;

  /// For single achievements, this is the reward.
  /// For tiered achievements, treat this as "fallback / default" and use tiers instead.
  final int rewardCoins;

  /// Defaults to single to keep existing behavior unchanged.
  final AchievementKind kind;

  /// Only used when kind == tiered.
  /// Each tier defines its own target and reward.
  final List<AchievementTier> tiers;

  const AchievementDefinition({
    required this.index,
    required this.title,
    required this.description,
    required this.rewardCoins,
    this.kind = AchievementKind.single,
    this.tiers = const [],
  });

  bool get isTiered => kind == AchievementKind.tiered;

  /// Safe helper: get tier definition for a given 0-based tierIndex (0 => tier 1).
  AchievementTier? tierAt(int tierIndex) {
    if (!isTiered) return null;
    if (tierIndex < 0 || tierIndex >= tiers.length) return null;
    return tiers[tierIndex];
  }

  /// Safe helper: max tiers count (0 for non-tiered).
  int get tierCount => isTiered ? tiers.length : 0;
}

/// Backend supports exactly 3 achievements (indices 1–3).
/// Index 1: implemented (single)
/// Index 2: hydration streak (tiered) — implemented in frontend logic next
/// Index 3: placeholder for future (e.g., steps streak)
const Map<int, AchievementDefinition> achievementDefinitions = {
  1: AchievementDefinition(
    index: 1,
    title: 'Welcome Home',
    description: 'Explore the room and discover its features.',
    rewardCoins: 50,
    kind: AchievementKind.single,
  ),

  // ✅ NEW: Tiered hydration streak achievement
  // NOTE: targets = consecutive days hitting water goal.
  2: AchievementDefinition(
    index: 2,
    title: 'Hydration Habit',
    description: 'Build a streak by reaching your daily water goal.',
    rewardCoins: 0, // ignored for tiered (tiers define rewards)
    kind: AchievementKind.tiered,
    tiers: [
      AchievementTier(tier: 1, target: 1, rewardCoins: 25),
      AchievementTier(tier: 2, target: 5, rewardCoins: 60),
      AchievementTier(tier: 3, target: 10, rewardCoins: 120),
      // Add more later if you want:
      // AchievementTier(tier: 4, target: 20, rewardCoins: 220),
    ],
  ),

  3: AchievementDefinition(
    index: 3,
    title: '—',
    description: 'Coming soon.',
    rewardCoins: 0,
    kind: AchievementKind.single,
  ),
};
