import 'package:flutter/material.dart';

class AchievementsDialog extends StatelessWidget {
  const AchievementsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Achievements',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 480,
        child: ListView(
          children: const [
            AchievementTile(
              title: 'First Sprout',
              description: 'Help your plant grow for the first time.',
              icon: Icons.local_florist,
              progress: 100,
            ),
            AchievementTile(
              title: 'Alive and Well',
              description: 'Keep your plant healthy for several days.',
              icon: Icons.eco,
              progress: 60,
            ),
            AchievementTile(
              title: 'Walkies!',
              description: 'Reach your daily step goal.',
              icon: Icons.directions_walk,
              progress: 100,
            ),
            AchievementTile(
              title: 'Hydrated',
              description: 'Drink enough water in a day.',
              icon: Icons.water_drop,
              progress: 40,
            ),
            AchievementTile(
              title: 'Still Here',
              description: 'Open the app on different days.',
              icon: Icons.favorite,
              progress: 20,
            ),
            AchievementTile(
              title: 'Green Thumb',
              description: 'Reach a fully thriving plant.',
              icon: Icons.park,
              progress: 0,
              locked: true,
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Close',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

class AchievementTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final int progress;
  final bool locked;

  const AchievementTile({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0, 100);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 36,
            color: locked
                ? Colors.grey.shade400
                : Colors.amber.shade700,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: locked
                        ? Colors.grey.shade500
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: clampedProgress / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    color: locked
                        ? Colors.grey.shade400
                        : Colors.amber.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$clampedProgress%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
