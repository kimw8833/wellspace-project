// lib/pages/room_page.dart

import 'package:flutter/material.dart';

// controller
import '../controllers/room_controller.dart';

// widgets
import '../widgets/sprites/plant_sprite.dart';
import '../widgets/sprites/dog_sprite.dart';
import '../widgets/debug/debug_panel.dart';

// utils
import '../utils/constants.dart';
import '../utils/formatting.dart';

// models
import '../models/dog_model.dart';
import '../models/plant_model.dart';

class MyRoomPage extends StatefulWidget {
  final int playerId;

  const MyRoomPage({super.key, required this.playerId});

  @override
  State<MyRoomPage> createState() => _MyRoomPageState();
}

class _MyRoomPageState extends State<MyRoomPage> {
  late RoomController controller;
  bool _debugVisible = false;

  bool get isDeveloper => widget.playerId == 1;

  @override
  void initState() {
    super.initState();
    controller = RoomController(widget.playerId);
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

  void _toggleDebug() {
    if (!isDeveloper) return;
    setState(() => _debugVisible = !_debugVisible);
  }

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    final leftPlantX = 1450 * (screenW / CanvasSize.width);
    final bottomPlantY = 1006 * (screenH / CanvasSize.height);

    final rightDogX = 260 * (screenW / CanvasSize.width);
    final bottomDogY = 260 * (screenH / CanvasSize.height);

    return Scaffold(
      body: Stack(
        children: [
          // ============================
          //         BACKGROUND
          // ============================
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

          // ============================
          //        PLANT SPRITE
          // ============================
          Positioned(
            left: leftPlantX,
            bottom: bottomPlantY,
            child: Transform.scale(
              scale: SpriteScale.plant,
              child: PlantSprite(health: state.plantHealth),
            ),
          ),

          // ============================
          //         DOG SPRITE
          // ============================
          Positioned(
            right: rightDogX,
            bottom: bottomDogY,
            child: Transform.scale(
              scale: SpriteScale.dog,
              child: DogSprite(mood: state.dogHealth),
            ),
          ),

          // ============================
          //     TOP-LEFT TIME DISPLAY
          // ============================
          if (_debugVisible && isDeveloper)
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          Formatting.timestamp(controller.time.simulatedTime),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ============================
          //        DEBUG PANEL (LEFT)
          // ============================
          if (_debugVisible && isDeveloper)
            SafeArea(
              child: Align(
                alignment: Alignment.centerLeft,
                child: DebugPanel(
                  simulatedTime: controller.time.simulatedTime,
                  autoSimLabel: _autoSimLabel(),

                  // dog
                  stepsToday: controller.dog.stepsToday,
                  dogStepGoal: DogModel.stepGoal,
                  dogMood: controller.dog.mood,
                  dogMoodLabel: _dogHealthLabel(controller.dog.mood),
                  dogSprite: DogSprite(mood: controller.dog.mood),

                  // plant
                  plantHealth: controller.plant.health,
                  hydrationSmoothed: controller.plant.hydrationSmoothed,
                  plantHealthLabel: _plantHealthLabel(controller.plant.health),
                  plantColor: _plantColor(controller.plant.health),

                  // time controls
                  onAddDayMinus1: () => controller.addDays(-1),
                  onAddHourMinus1: () => controller.addHours(-1),
                  onAddHourPlus1: () => controller.addHours(1),
                  onAddDayPlus1: () => controller.addDays(1),

                  // auto sim
                  onPlay1x: () => controller.playAutoSim(1.0),
                  onPlay10x: () => controller.playAutoSim(10.0),
                  onPause: () => controller.pauseAutoSim(),

                  // scenario
                  onScenarioChanged: (s) => controller.setScenario(s),

                  // dog steps
                  onDogStepsChanged: (v) =>
                      controller.setStepsToday(v.toInt()),
                ),
              ),
            ),

          // ============================
          //     DEBUG TOGGLE BUTTON
          // ============================
          if (isDeveloper)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: IconButton(
                    icon: Icon(
                      _debugVisible
                          ? Icons.bug_report
                          : Icons.bug_report_outlined,
                      size: 22,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    onPressed: _toggleDebug,
                  ),
                ),
              ),
            ),

          // ============================
          //       LOGOUT BUTTON (BOTTOM RIGHT)
          // ============================
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  //                    UI HELPERS
  // =========================================================

  String _plantHealthLabel(double s) {
    if (s < 0.2) return 'Dead / barely hanging on';
    if (s < 0.4) return 'Very wilted';
    if (s < 0.6) return 'Not great, needs care';
    if (s < 0.8) return 'Doing pretty well';
    return 'Lush & thriving';
  }

  Color _plantColor(double s) {
    final t = s.clamp(0.0, 1.0);
    return Color.lerp(
      const Color(0xFF6B4226),
      const Color(0xFF4CAF50),
      t,
    )!;
  }

  String _dogHealthLabel(double d) {
    if (d < 0.2) return 'Very sad / restless';
    if (d < 0.4) return 'Quite unhappy';
    if (d < 0.6) return 'Neutral / okay';
    if (d < 0.8) return 'Happy';
    return 'Very happy & energetic';
  }

  String _autoSimLabel() {
    final scenario = switch (controller.time.scenario) {
      'dry' => 'Dry (0.2)',
      'perfect' => 'Perfect (1.0)',
      _ => 'OK (0.6)',
    };

    if (!controller.autoSimRunning) {
      return "Scenario: $scenario • Paused";
    } else {
      return "Scenario: $scenario • "
          "${controller.time.speedMultiplier.toStringAsFixed(0)}x speed";
    }
  }
}
