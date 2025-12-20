import 'package:flutter/material.dart';
import 'package:my_app/widgets/sprites/friend_picture_sprite.dart';

import '../controllers/room_controller.dart';
import '../widgets/sprites/plant_sprite.dart';
import '../widgets/sprites/dog_sprite.dart';
import '../widgets/debug/debug_panel.dart';
import '../widgets/room_menu_button.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/sprites/clock_sprite.dart';
import '../widgets/friends_dialog.dart';

import '../utils/constants.dart';
import '../utils/formatting.dart';
import '../models/dog_model.dart';
import '../widgets/sprites/trophy_sprite.dart';
import '../widgets/achievements_dialog.dart';

class MyRoomPage extends StatefulWidget {
  final int userId;

  const MyRoomPage({super.key, required this.userId});

  @override
  State<MyRoomPage> createState() => _MyRoomPageState();
}

class _MyRoomPageState extends State<MyRoomPage> {
  late RoomController controller;
  bool _debugVisible = false;

  bool get isDeveloper => widget.userId == 1;

  @override
  void initState() {
    super.initState();
    controller = RoomController(widget.userId);
    controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerUpdate);
    controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  void _openSettingsDialog() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => SettingsDialog(
        currentStepGoal: controller.dailyStepGoal,
        currentWaterGoal: controller.dailyWaterGoal,
      ),
    );

    if (result != null) {
      controller.updateSettings(result["steps"], result["water"]);
    }
  }

  void _openFriendsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => FriendsDialog(
        userId: widget.userId,
      ),
    );
  }

  void _openAchievementsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AchievementsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final state = controller.state;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    // PLANT
    final leftPlantX = 1450 * (screenW / CanvasSize.width);
    final bottomPlantY = 1006 * (screenH / CanvasSize.height);

    // DOG
    final rightDogX = 260 * (screenW / CanvasSize.width);
    final bottomDogY = 260 * (screenH / CanvasSize.height);

    // CLOCK
    final rightClockX = 150 * (screenW / CanvasSize.width);
    final bottomClockY = 1100 * (screenH / CanvasSize.height);

    // FRIEND PICTURE
    final rightFriendPictureX = 1100 * (screenW / CanvasSize.width);
    final bottomFriendPictureY = 750 * (screenH / CanvasSize.height);

    // TROPHY — ON DESK
    final rightTrophyX = 800 * (screenW / CanvasSize.width);
    final bottomTrophyY = 880 * (screenH / CanvasSize.height);

    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/rooms/daylight_room.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // CLOCK
          Positioned(
            right: rightClockX,
            bottom: bottomClockY,
            child: Transform.scale(
              scale: 0.95,
              child: ClockSprite(
                size: 130,
                time: controller.effectiveNow,
              ),
            ),
          ),

          // PLANT
          Positioned(
            left: leftPlantX,
            bottom: bottomPlantY,
            child: Transform.scale(
              scale: SpriteScale.plant,
              child: PlantSprite(health: state.plantHealth),
            ),
          ),

          // DOG
          Positioned(
            right: rightDogX,
            bottom: bottomDogY,
            child: Transform.scale(
              scale: SpriteScale.dog,
              child: DogSprite(mood: state.dogHealth),
            ),
          ),

          // FRIEND PICTURE
          Positioned(
            right: rightFriendPictureX,
            bottom: bottomFriendPictureY,
            child: Transform.scale(
              scale: SpriteScale.friendPicture,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openFriendsDialog,
                child: FriendPictureSprite(),
              ),
            ),
          ),

          // TROPHY (ACHIEVEMENTS)
          Positioned(
            right: rightTrophyX,
            bottom: bottomTrophyY,
            child: Transform.scale(
              scale: 1.8,
              child: TrophySprite(
                onTap: _openAchievementsDialog,
              ),
            ),
          ),

          // MENU + DEBUG
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RoomMenuButton(
                      onSettings: _openSettingsDialog,
                      onLogout: () => Navigator.of(context).pop(),
                      onAchievements: _openAchievementsDialog,
                      onFriends: _openFriendsDialog,
                    ),
                    if (isDeveloper)
                      IconButton(
                        icon: Icon(
                          _debugVisible
                              ? Icons.bug_report
                              : Icons.bug_report_outlined,
                          color: Colors.white.withOpacity(0.7),
                          size: 22,
                        ),
                        onPressed: () =>
                            setState(() => _debugVisible = !_debugVisible),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // DEBUG PANEL
          if (_debugVisible && isDeveloper)
            SafeArea(
              child: Align(
                alignment: Alignment.centerLeft,
                child: DebugPanel(
                  currentScenario: controller.time.scenario,
                  simulatedTime: controller.effectiveNow,
                  autoSimLabel: "",
                  stepsToday: controller.dog.stepsToday,
                  dogStepGoal: controller.dailyStepGoal,
                  dogMood: controller.dog.mood,
                  dogMoodLabel: "",
                  dogSprite: DogSprite(mood: controller.dog.mood),
                  plantHealth: controller.plant.health,
                  hydrationSmoothed: controller.plant.hydrationSmoothed,
                  plantHealthLabel: "",
                  plantColor: Colors.white,
                  onAddDayMinus1: () => controller.addDays(-1),
                  onAddHourMinus1: () => controller.addHours(-1),
                  onAddHourPlus1: () => controller.addHours(1),
                  onAddDayPlus1: () => controller.addDays(1),
                  onPlay1x: () => controller.playAutoSim(1),
                  onPlay10x: () => controller.playAutoSim(10),
                  onPause: () => controller.pauseAutoSim(),
                  onScenarioChanged: (s) => controller.setScenario(s),
                  onDogStepsChanged: (v) => controller.setStepsToday(v.toInt()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
