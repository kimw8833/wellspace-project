import 'dart:async';
import 'package:flutter/material.dart';
import 'api_service.dart';

class MyRoomPage extends StatefulWidget {
  final int playerId;

  const MyRoomPage({
    super.key,
    required this.playerId,
  });

  @override
  State<MyRoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<MyRoomPage> {
  late Future<double?> outdatedRoomStatus;
  late Future<double?> outdatedDogStatus;
  late Future<double?> outdatedPlantStatus;
  late Future<double?> outdatedWindowStatus;

  // ---- SIMULATED TIME ----
  late DateTime _simulatedTime;
  late DateTime _currentSimulatedDate;

  // ---- HYDRATION (PER DAY) ----
  int _waterToday = 0; // ml
  final int _dailyGoal = 2000;

  // ---- PLANT MODEL STATE ----
  double _plantHealth = 0.7; // S in [0,1], 0 = dead, 1 = lush
  double _hydrationSmoothed = 0.7; // g in [0,1]

  // Constants for the model
  static const double _plantH = 1.0; // upper bound H
  static const double _plantD = 0.0; // lower bound D
  static const double _k = 0.10; // growth-rate constant
  static const double _d = 0.05; // decay-rate constant
  static const double _alpha = 0.35; // smoothing factor for hydration

  // ---- DEBUG ----
  bool _debugVisible = false;

  // ---- AUTO SIMULATION ----
  Timer? _simTimer;
  bool _autoSimRunning = false;
  double _simSpeedMultiplier = 1.0; // 1x, 10x, etc.
  String _autoSimScenario = 'ok'; // 'dry', 'ok', 'perfect'

  static const Duration _simTickRealDuration = Duration(milliseconds: 300);
  static const double _hoursPerTickBase = 1.0; // 1 sim hour per tick at 1x

  // ---- PLANT SPRITES ----
  static const List<String> _plantSpritePaths = [
    "assets/images/plants/stage_1_plant.png", // index 0 - worst
    "assets/images/plants/stage_2_plant.png", // index 1
    "assets/images/plants/stage_3_plant.png", // index 2 - mid
    "assets/images/plants/stage_4_plant.png", // index 3
    "assets/images/plants/stage_5_plant.png", // index 4 - best
  ];

  @override
  void initState() {
    super.initState();

    _simulatedTime = DateTime.now();
    _currentSimulatedDate = DateTime(
      _simulatedTime.year,
      _simulatedTime.month,
      _simulatedTime.day,
    );

    outdatedRoomStatus = ApiService().getRoomMood(widget.playerId);
    outdatedDogStatus = ApiService().getDogStatus(widget.playerId);
    outdatedPlantStatus = ApiService().getPlantStatus(widget.playerId);
    outdatedWindowStatus = ApiService().getWindowStatus(widget.playerId);
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    super.dispose();
  }

  // =================================================
  //                PLANT UPDATE LOGIC
  // =================================================

  /// Apply one daily update to plant state given a hydration ratio in [0,1].
  /// Does NOT move time; caller is responsible for time/date changes.
  void _applyDailyUpdate(double ratio) {
    final double r = ratio.clamp(0.0, 1.0).toDouble(); // r_i

    // 2. Smoothed hydration g_i = α r_i + (1-α) g_{i-1}
    final double gNew = _alpha * r + (1 - _alpha) * _hydrationSmoothed;

    // 3. γ_i = k(2 g_i - 1)
    final double gamma = _k * (2 * gNew - 1);

    // 4. S_{i+1} = S_i + γ_i(H - S_i) - d(1 - g_i)(S_i - D)
    double sNext = _plantHealth +
        gamma * (_plantH - _plantHealth) -
        _d * (1 - gNew) * (_plantHealth - _plantD);

    // Clamp to [D, H]
    sNext = sNext.clamp(_plantD, _plantH).toDouble();

    // Save new state
    _hydrationSmoothed = gNew;
    _plantHealth = sNext;

    // New day → reset daily water
    _waterToday = 0;
  }

  /// Manual daily advance: use today's water, then move date/time by 1 day.
  void _advanceManualOneDay() {
    final double ratio = (_waterToday / _dailyGoal).clamp(0.0, 1.0).toDouble();

    _applyDailyUpdate(ratio);

    // Advance date by 1 for both date + simulatedTime
    _currentSimulatedDate = _currentSimulatedDate.add(const Duration(days: 1));
    _simulatedTime = DateTime(
      _currentSimulatedDate.year,
      _currentSimulatedDate.month,
      _currentSimulatedDate.day,
      _simulatedTime.hour,
      _simulatedTime.minute,
    );
  }

  /// Auto-sim daily advance: pick ratio based on scenario and new date.
  void _handleNewSimulatedDay(DateTime newDate) {
    double ratio;

    switch (_autoSimScenario) {
      case 'dry':
        ratio = 0.2;
        break;
      case 'ok':
        ratio = 0.6;
        break;
      case 'perfect':
        ratio = 1.0;
        break;
      default:
        ratio = 0.6;
        break;
    }

    _applyDailyUpdate(ratio);

    _currentSimulatedDate = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
    );
  }

  // =================================================
  //                TIME CONTROL LOGIC
  // =================================================

  void _stopAutoSim() {
    _simTimer?.cancel();
    _simTimer = null;
    setState(() {
      _autoSimRunning = false;
    });
  }

  void _startAutoSim(double speedMultiplier) {
    _simTimer?.cancel();
    _simSpeedMultiplier = speedMultiplier;

    setState(() {
      _autoSimRunning = true;
    });

    _simTimer = Timer.periodic(_simTickRealDuration, (timer) {
      setState(() {
        final double hoursToAdd = _hoursPerTickBase * _simSpeedMultiplier;
        final int minutesToAdd = (hoursToAdd * 60).round();

        _simulatedTime = _simulatedTime.add(
          Duration(minutes: minutesToAdd),
        );

        final DateTime newDate = DateTime(
          _simulatedTime.year,
          _simulatedTime.month,
          _simulatedTime.day,
        );

        if (newDate != _currentSimulatedDate) {
          _handleNewSimulatedDay(newDate);
        }
      });
    });
  }

  void _addHours(int hours) {
    // Manual control → stop auto sim to avoid weird conflicts
    if (_autoSimRunning) _stopAutoSim();

    setState(() {
      _simulatedTime = _simulatedTime.add(Duration(hours: hours));
      _currentSimulatedDate = DateTime(
        _simulatedTime.year,
        _simulatedTime.month,
        _simulatedTime.day,
      );
      // Daily updates via +1 day / auto sim only.
    });
  }

  void _addDays(int days) {
    if (days == 0) return;

    // Manual control → stop auto sim
    if (_autoSimRunning) _stopAutoSim();

    if (days > 0) {
      setState(() {
        for (int i = 0; i < days; i++) {
          _advanceManualOneDay();
        }
      });
    } else {
      // Going backwards in time (for debugging) won't rewind plant state.
      setState(() {
        _simulatedTime = _simulatedTime.add(Duration(days: days));
        _currentSimulatedDate = DateTime(
          _simulatedTime.year,
          _simulatedTime.month,
          _simulatedTime.day,
        );
      });
    }
  }

  // =================================================
  //                  HYDRATION LOGIC
  // =================================================

  void _addWater(int amount) {
    setState(() {
      _waterToday += amount;
      if (_waterToday > _dailyGoal) {
        _waterToday = _dailyGoal;
      }
    });
  }

  // =================================================
  //                 FORMATTING HELPERS
  // =================================================

  String get _formattedSimulatedTime {
    final d = _simulatedTime;
    String two(int n) => n.toString().padLeft(2, '0');
    return "${d.year}-${two(d.month)}-${two(d.day)}  "
        "${two(d.hour)}:${two(d.minute)}";
  }

  String get _autoSimLabel {
    String scenario;
    switch (_autoSimScenario) {
      case 'dry':
        scenario = "Dry (0.2)";
        break;
      case 'ok':
        scenario = "OK (0.6)";
        break;
      case 'perfect':
        scenario = "Perfect (1.0)";
        break;
      default:
        scenario = "OK (0.6)";
    }

    if (!_autoSimRunning) {
      return "Scenario: $scenario • Paused";
    } else {
      return "Scenario: $scenario • ${_simSpeedMultiplier.toStringAsFixed(0)}x speed";
    }
  }

  void _toggleDebug() {
    setState(() => _debugVisible = !_debugVisible);
  }

  // Color from wilted brown -> lush green based on plantHealth S in [0,1]
  Color get _plantColor {
    final t = _plantHealth.clamp(0.0, 1.0).toDouble();
    return Color.lerp(
      const Color(0xFF6B4226), // brown-ish
      const Color(0xFF4CAF50), // green-ish
      t,
    )!;
  }

  String get _plantHealthLabel {
    final s = _plantHealth;
    if (s < 0.2) return 'Dead / barely hanging on';
    if (s < 0.4) return 'Very wilted';
    if (s < 0.6) return 'Not great, needs care';
    if (s < 0.8) return 'Doing pretty well';
    return 'Lush & thriving';
  }

  // =================================================
  //                 PLANT SPRITE RENDERING
  // =================================================

  Widget _buildPlantSprite() {
    // Clamp S to [0,1]
    final double s = _plantHealth.clamp(0.0, 1.0);

    // 5 stages evenly distributed over [0, 1]:
    // [0.00, 0.20) -> stage 1
    // [0.20, 0.40) -> stage 2
    // [0.40, 0.60) -> stage 3
    // [0.60, 0.80) -> stage 4
    // [0.80, 1.00] -> stage 5
    int index;
    if (s < 0.2) {
      index = 0;
    } else if (s < 0.4) {
      index = 1;
    } else if (s < 0.6) {
      index = 2;
    } else if (s < 0.8) {
      index = 3;
    } else {
      index = 4;
    }

    return SizedBox(
      width: 180,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Image.asset(
          _plantSpritePaths[index],
          key: ValueKey(index),
          width: 180,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // =================================================
  //                     BUILD
  // =================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ---- BACKGROUND ----
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

          // ---- PLANT ON LEFT DRAWER ----
          Positioned(
            left: 1450 * (MediaQuery.of(context).size.width / 2528),
            bottom: 1006 * (MediaQuery.of(context).size.height / 1696),
            child: Transform.scale(
              scale: 2,
              child: _buildPlantSprite(),
            ),
          ),

          // ---- TOP-LEFT SMALL TIME DISPLAY ----
          if (_debugVisible)
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formattedSimulatedTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ---- BOTTOM DEBUG PANEL ----
          if (_debugVisible)
            SafeArea(
              child: Column(
                children: [
                  const Spacer(),

                  // Time controls
                  _buildDebugCard(
                    title: "Simulated Time Controls",
                    child: Wrap(
                      spacing: 10,
                      children: [
                        FancyDebugButton(
                          label: "-1 day",
                          onPressed: () => _addDays(-1),
                        ),
                        FancyDebugButton(
                          label: "-1 hour",
                          onPressed: () => _addHours(-1),
                        ),
                        FancyDebugButton(
                          label: "+1 hour",
                          onPressed: () => _addHours(1),
                        ),
                        FancyDebugButton(
                          label: "+1 day",
                          onPressed: () => _addDays(1),
                        ),
                      ],
                    ),
                  ),

                  // Hydration controls
                  _buildDebugCard(
                    title: "Hydration Debug",
                    subtitle: "Water today: $_waterToday / $_dailyGoal ml",
                    child: Wrap(
                      spacing: 10,
                      children: [
                        FancyDebugButton(
                          label: "+100 ml",
                          onPressed: () => _addWater(100),
                        ),
                        FancyDebugButton(
                          label: "+250 ml",
                          onPressed: () => _addWater(250),
                        ),
                        FancyDebugButton(
                          label: "+500 ml",
                          onPressed: () => _addWater(500),
                        ),
                      ],
                    ),
                  ),

                  // Auto simulation controls
                  _buildDebugCard(
                    title: "Auto Simulation",
                    subtitle: _autoSimLabel,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Wrap(
                          spacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            FancyDebugButton(
                              label:
                                  _autoSimRunning && _simSpeedMultiplier == 1.0
                                      ? "Pause"
                                      : "Play 1x",
                              onPressed: () {
                                if (_autoSimRunning &&
                                    _simSpeedMultiplier == 1.0) {
                                  _stopAutoSim();
                                } else {
                                  _startAutoSim(1.0);
                                }
                              },
                            ),
                            FancyDebugButton(
                              label:
                                  _autoSimRunning && _simSpeedMultiplier == 10.0
                                      ? "Pause"
                                      : "Play 10x",
                              onPressed: () {
                                if (_autoSimRunning &&
                                    _simSpeedMultiplier == 10.0) {
                                  _stopAutoSim();
                                } else {
                                  _startAutoSim(10.0);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            ScenarioChip(
                              label: "Dry (0.2)",
                              value: 'dry',
                              groupValue: _autoSimScenario,
                              onTap: () {
                                setState(() {
                                  _autoSimScenario = 'dry';
                                });
                              },
                            ),
                            ScenarioChip(
                              label: "OK (0.6)",
                              value: 'ok',
                              groupValue: _autoSimScenario,
                              onTap: () {
                                setState(() {
                                  _autoSimScenario = 'ok';
                                });
                              },
                            ),
                            ScenarioChip(
                              label: "Perfect (1.0)",
                              value: 'perfect',
                              groupValue: _autoSimScenario,
                              onTap: () {
                                setState(() {
                                  _autoSimScenario = 'perfect';
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Plant state visualization (numeric + bar)
                  _buildDebugCard(
                    title: "Plant State Debug",
                    subtitle:
                        "Health: ${_plantHealth.toStringAsFixed(2)}   |   Smoothed hydration: ${_hydrationSmoothed.toStringAsFixed(2)}",
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _plantColor,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                _plantHealthLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Health level",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: Colors.white.withOpacity(0.15),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final double t =
                                      _plantHealth.clamp(0.0, 1.0).toDouble();
                                  final double w = constraints.maxWidth * t;
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      width: w,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFEF5350),
                                            Color(0xFFFFC107),
                                            Color(0xFF66BB6A),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

          // ---- DEBUG TOGGLE BUTTON (ALWAYS ON TOP) ----
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                  icon: Icon(
                    _debugVisible
                        ? Icons.bug_report
                        : Icons.bug_report_outlined,
                    size: 22,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: _toggleDebug,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- HELPER: DEBUG PANEL CARD ----
  Widget _buildDebugCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// =====================================================
//         ✨ FULLY CUSTOM HIGH-END DEBUG BUTTON ✨
// =====================================================

class FancyDebugButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const FancyDebugButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  State<FancyDebugButton> createState() => _FancyDebugButtonState();
}

class _FancyDebugButtonState extends State<FancyDebugButton>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _pressed ? 0.94 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 90),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFF7C3AED),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (_hovering)
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
//                Scenario Toggle Chip
// =====================================================

class ScenarioChip extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final VoidCallback onTap;

  const ScenarioChip({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  bool get _selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _selected
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selected ? Colors.purpleAccent : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(_selected ? 1.0 : 0.8),
            fontSize: 12.5,
            fontWeight: _selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
