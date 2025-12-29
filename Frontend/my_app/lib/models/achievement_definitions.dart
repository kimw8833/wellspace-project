class AchievementDefinition {
  final int index;
  final String title;
  final String description;
  final int rewardCoins;

  const AchievementDefinition({
    required this.index,
    required this.title,
    required this.description,
    required this.rewardCoins,
  });
}

/// Backend supports exactly 3 achievements (indices 1–3).
/// We fully implement ONLY index 1 for now.
const Map<int, AchievementDefinition> achievementDefinitions = {
  1: AchievementDefinition(
    index: 1,
    title: 'Welcome Home',
    description: 'Explore the room and discover its features.',
    rewardCoins: 50,
  ),
  2: AchievementDefinition(
    index: 2,
    title: '—',
    description: 'Coming soon.',
    rewardCoins: 0,
  ),
  3: AchievementDefinition(
    index: 3,
    title: '—',
    description: 'Coming soon.',
    rewardCoins: 0,
  ),
};
