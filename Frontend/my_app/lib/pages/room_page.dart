import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_app/widgets/sprites/friend_picture_sprite.dart';

import '../controllers/room_controller.dart';
import '../services/api_service.dart';
import '../widgets/tutorial/room_tutorial.dart';

import '../widgets/sprites/plant_sprite.dart';
import '../widgets/sprites/dog_sprite.dart';
import '../widgets/debug/debug_panel.dart';
import '../widgets/room_menu_button.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/sprites/clock_sprite.dart';
import '../widgets/friends_dialog.dart';

import '../utils/constants.dart';
import '../models/dog_model.dart';
import '../widgets/sprites/trophy_sprite.dart';
import '../widgets/achievements_dialog.dart';

class MyRoomPage extends StatefulWidget {
  final int userId;

  final int? viewerUserId;

  final String? roomOwnerUsername;

  const MyRoomPage({
    super.key,
    required this.userId,
    this.viewerUserId,
    this.roomOwnerUsername,
  });

  bool get isVisitor => (viewerUserId ?? userId) != userId;

  @override
  State<MyRoomPage> createState() => _MyRoomPageState();
}

class _MyRoomPageState extends State<MyRoomPage> {
  late RoomController controller;
  bool _debugVisible = false;

  // ✅ tutorial + backend
  final ApiService _api = ApiService();

  // Existing key
  final GlobalKey _coinPillKey = GlobalKey();

  // ✅ tutorial target keys
  final GlobalKey _plantKey = GlobalKey();
  final GlobalKey _dogKey = GlobalKey();
  final GlobalKey _friendsKey = GlobalKey();
  final GlobalKey _trophyKey = GlobalKey();
  final GlobalKey _menuKey = GlobalKey();

  // ✅ tutorial guards
  bool _tutorialCheckStarted = false;
  bool _tutorialShown = false;

  bool get isDeveloper => widget.userId == 1;

  static const String _dayRoomAsset = "assets/images/rooms/daylight_room.png";
  static const String _nightRoomAsset = "assets/images/rooms/night_room.png";

  String _backgroundFor(DateTime t) {
    final h = t.hour;
    final isNight = (h >= 20 || h < 6); // Night: 20:00–05:59
    return isNight ? _nightRoomAsset : _dayRoomAsset;
  }

  @override
  void initState() {
    super.initState();
    controller = RoomController(
      widget.userId,
      readOnly: widget.isVisitor,
    );
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

    // ✅ kick tutorial once we’re done loading
    if (!controller.isLoading) {
      RoomTutorial.maybeStart(
        context: context,
        api: _api,
        userId: widget.userId,
        isVisitor: widget.isVisitor,
        debugVisible: _debugVisible,
        tutorialCheckStarted: _tutorialCheckStarted,
        tutorialShown: _tutorialShown,
        setTutorialCheckStarted: (v) => _tutorialCheckStarted = v,
        setTutorialShown: (v) => _tutorialShown = v,
        keys: RoomTutorialKeys(
          coin: _coinPillKey,
          trophy: _trophyKey,
          friends: _friendsKey,
          plant: _plantKey,
          dog: _dogKey,
          menu: _menuKey,
        ),
      );
    }
  }

  void _openSettingsDialog() async {
    controller.registerExplorerEvent('open_settings');
    final result = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => SettingsDialog(
        currentStepGoal: controller.dailyStepGoal,
        currentWaterGoal: controller.dailyWaterGoal,
        currentMusicVolume: controller.roomMusicVolume,
        onMusicVolumeChanged: (v) => controller.setRoomMusicVolume(v),
      ),
    );

    if (result != null) {
      controller.updateSettings(result["steps"], result["water"]);

      final v = (result["musicVolume"] as num).toDouble();
      await controller.setRoomMusicVolume(v);
    }
  }

  void _openFriendsDialog() {
    controller.registerExplorerEvent('open_friends');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => FriendsDialog(
        userId: widget.userId,
      ),
    );
  }

  void _openAchievementsDialog() {
    controller.registerExplorerEvent('open_achievements');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AchievementsDialog(
        controller: controller,
        coinPillKey: _coinPillKey,
      ),
    );
  }

  Widget _coinPill() {
    return Container(
      key: _coinPillKey,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on,
            size: 18,
            color: Color(0xFFB28A2E),
          ),
          const SizedBox(width: 6),
          Text(
            controller.coins.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2A2A2A),
            ),
          ),
        ],
      ),
    );
  }

  /// Visitor banner + return button (shown only when visiting).
  Widget _visitorOverlay(BuildContext context) {
    final name = (widget.roomOwnerUsername ?? "Friend").trim();
    final label = name.isEmpty ? "Friend’s room" : "$name’s room";

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.visibility_outlined, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                tooltip: "Return",
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Room-themed loading UI so you never see a white screen.
  Widget _cozyRoomLoader(BuildContext context, String bgAsset) {
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          bgAsset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: const SizedBox.expand(),
        ),
        Container(color: Colors.black.withOpacity(0.40)),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F0E8).withOpacity(0.92),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  color: Colors.black.withOpacity(0.22),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.isVisitor ? 'Entering their room…' : 'Preparing your room…',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleDebug() async {
    setState(() => _debugVisible = !_debugVisible);

    if (_debugVisible) {
      controller.enterDebugSim();
    } else {
      controller.exitDebugSim();
    }
  }

  Future<void> _commitAndCloseDebug() async {
    await controller.commitDebugState();
    if (mounted) {
      setState(() => _debugVisible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      final bgAsset = _backgroundFor(DateTime.now());
      return Scaffold(body: _cozyRoomLoader(context, bgAsset));
    }

    final bgAsset = _backgroundFor(controller.effectiveNow);

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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // BACKGROUND
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(bgAsset),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // ✅ Non-clickable visitor mode for interactive elements
          AbsorbPointer(
            absorbing: widget.isVisitor,
            child: Stack(
              children: [
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
                  child: KeyedSubtree(
                    key: _plantKey,
                    child: Transform.scale(
                      scale: SpriteScale.plant,
                      child: PlantSprite(health: state.plantHealth),
                    ),
                  ),
                ),

                // DOG
                Positioned(
                  right: rightDogX,
                  bottom: bottomDogY,
                  child: KeyedSubtree(
                    key: _dogKey,
                    child: Transform.scale(
                      scale: SpriteScale.dog,
                      child: DogSprite(mood: state.dogHealth),
                    ),
                  ),
                ),

                // FRIEND PICTURE
                Positioned(
                  right: rightFriendPictureX,
                  bottom: bottomFriendPictureY,
                  child: KeyedSubtree(
                    key: _friendsKey,
                    child: Transform.scale(
                      scale: SpriteScale.friendPicture,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _openFriendsDialog,
                        child: FriendPictureSprite(),
                      ),
                    ),
                  ),
                ),

                // TROPHY
                Positioned(
                  right: rightTrophyX,
                  bottom: bottomTrophyY,
                  child: KeyedSubtree(
                    key: _trophyKey,
                    child: Transform.scale(
                      scale: 1.8,
                      child: TrophySprite(
                        onTap: _openAchievementsDialog,
                        glow: controller.hasClaimableAchievements,
                      ),
                    ),
                  ),
                ),

                if (!widget.isVisitor)
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _coinPill(),
                            KeyedSubtree(
                              key: _menuKey,
                              child: RoomMenuButton(
                                onSettings: _openSettingsDialog,
                                onLogout: () => Navigator.of(context).pop(),
                                onAchievements: _openAchievementsDialog,
                                onFriends: _openFriendsDialog,
                              ),
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
                                onPressed: _toggleDebug,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ✅ DEBUG PANEL: only owner/dev, and not in visitor mode
                if (_debugVisible && isDeveloper && !widget.isVisitor)
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

                        // NEW
                        waterToday: controller.waterToday,
                        dailyWaterGoal: controller.dailyWaterGoal,
                        onWaterChanged: (v) =>
                            controller.addWater(v.toInt() - controller.waterToday),

                        onAddDayMinus1: () => controller.addDays(-1),
                        onAddHourMinus1: () => controller.addHours(-1),
                        onAddHourPlus1: () => controller.addHours(1),
                        onAddDayPlus1: () => controller.addDays(1),
                        onPlay1x: () => controller.playAutoSim(1),
                        onPlay10x: () => controller.playAutoSim(10),
                        onPause: () => controller.pauseAutoSim(),
                        onScenarioChanged: (s) => controller.setScenario(s),
                        onDogStepsChanged: (v) => controller.setStepsToday(v.toInt()),
                        onResetAchievements: () => controller.resetAllAchievements(),
                        onCommit: _commitAndCloseDebug,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (widget.isVisitor) _visitorOverlay(context),
        ],
      ),
    );
  }
}
