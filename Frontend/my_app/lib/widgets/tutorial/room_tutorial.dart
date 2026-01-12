// lib/widgets/tutorial/room_tutorial.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'tutorial_launcher.dart';
import 'tutorial_step.dart';

class RoomTutorialKeys {
  final GlobalKey coin;
  final GlobalKey trophy;
  final GlobalKey friends;
  final GlobalKey plant;
  final GlobalKey dog;
  final GlobalKey menu;

  RoomTutorialKeys({
    required this.coin,
    required this.trophy,
    required this.friends,
    required this.plant,
    required this.dog,
    required this.menu,
  });
}

class RoomTutorial {
  static Future<void> maybeStart({
    required BuildContext context,
    required ApiService api,
    required int userId,
    required bool isVisitor,
    required bool debugVisible,
    required bool tutorialCheckStarted,
    required bool tutorialShown,
    required void Function(bool) setTutorialCheckStarted,
    required void Function(bool) setTutorialShown,
    required RoomTutorialKeys keys,
  }) async {
    // Basic guards
    if (!context.mounted) return;
    if (isVisitor) return;
    if (debugVisible) return;
    if (tutorialShown) return;
    if (tutorialCheckStarted) return;

    // Only start when this page is the current route (avoid showing behind dialogs)
    if (ModalRoute.of(context)?.isCurrent != true) return;

    setTutorialCheckStarted(true);

    final isFirst = await api.isFirstTimeUser(userId);

    if (!context.mounted) return;
    if (isFirst != true) return;

    // Wait for layout so GlobalKeys resolve to actual positions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      setTutorialShown(true);

      TutorialLauncher.start(
        context: context,
        api: api,
        userId: userId,
        steps: [
          TutorialStep(
            targetKey: keys.coin,
            title: "Coins",
            body: "Earn coins from achievements. You’ll be able to spend them on upgrades later.",
          ),
          TutorialStep(
            targetKey: keys.trophy,
            title: "Achievements",
            body: "Tap the trophy to view achievements and claim rewards.",
          ),
          TutorialStep(
            targetKey: keys.friends,
            title: "Friends",
            body: "Tap the picture frame to add friends and visit their rooms.",
          ),
          TutorialStep(
            targetKey: keys.plant,
            title: "Plant",
            body: "Hitting your daily water goal keeps your plant healthy over time.",
          ),
          TutorialStep(
            targetKey: keys.dog,
            title: "Dog",
            body: "Your steps affect your dog’s mood. Hit your step goal to keep it happy.",
          ),
          TutorialStep(
            targetKey: keys.menu,
            title: "Menu",
            body: "Settings, friends and achievements are always one tap away.",
          ),
        ],
      );
    });
  }
}
