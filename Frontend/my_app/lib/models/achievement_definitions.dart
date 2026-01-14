// lib/models/achievement_definitions.dart

enum AchievementKind {
  single,
  tiered,
}

class AchievementTier {
  // Human-facing tier number (1-based).
  final int tier;

  // Completion target for this tier (meaning depends on achievement logic).
  final int target;

  // Coins awarded when claiming this tier.
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

  // Single achievements: reward for claiming.
  // Tiered achievements: use tiers for rewards.
  final int rewardCoins;

  final AchievementKind kind;

  // Used when kind == tiered.
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

  AchievementTier? tierAt(int tierIndex) {
    if (!isTiered) return null;
    if (tierIndex < 0 || tierIndex >= tiers.length) return null;
    return tiers[tierIndex];
  }

  int get tierCount => isTiered ? tiers.length : 0;
}

// Achievement indices (backend): 1–3.
// 1: Explorer (single)
// 2: Hydration streak (tiered; target = consecutive days meeting water goal)
// 3: Placeholder
const Map<int, AchievementDefinition> achievementDefinitions = {
  1: AchievementDefinition(
    index: 1,
    title: 'Welcome Home',
    description: 'Explore the room and discover its features.',
    rewardCoins: 50,
    kind: AchievementKind.single,
  ),
  2: AchievementDefinition(
    index: 2,
    title: 'Hydration Habit',
    description: 'Build a streak by reaching your daily water goal.',
    rewardCoins: 0, // tiers define rewards
    kind: AchievementKind.tiered,
    tiers: [
      AchievementTier(tier: 1, target: 1, rewardCoins: 25),
      AchievementTier(tier: 2, target: 5, rewardCoins: 60),
      AchievementTier(tier: 3, target: 10, rewardCoins: 120),
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
