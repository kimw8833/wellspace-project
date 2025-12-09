// lib/widgets/debug/debug_panel.dart

import 'dart:ui';
import 'package:flutter/material.dart';

import 'fancy_debug_button.dart';
import 'scenario_chip.dart';

class DebugPanel extends StatelessWidget {
  final DateTime simulatedTime;
  final String autoSimLabel;
  final int stepsToday;
  final int dogStepGoal;
  final double dogMood;
  final String dogMoodLabel;
  final double plantHealth;
  final double hydrationSmoothed;
  final String plantHealthLabel;

  // Controller callbacks
  final VoidCallback onAddDayMinus1;
  final VoidCallback onAddHourMinus1;
  final VoidCallback onAddHourPlus1;
  final VoidCallback onAddDayPlus1;
  final VoidCallback onPlay1x;
  final VoidCallback onPlay10x;
  final VoidCallback onPause;
  final Function(String) onScenarioChanged;
  final Function(double) onDogStepsChanged;

  final Widget dogSprite;
  final Color plantColor;

  const DebugPanel({
    super.key,
    required this.simulatedTime,
    required this.autoSimLabel,

    required this.stepsToday,
    required this.dogStepGoal,
    required this.dogMood,
    required this.dogMoodLabel,

    required this.plantHealth,
    required this.hydrationSmoothed,
    required this.plantHealthLabel,

    required this.onAddDayMinus1,
    required this.onAddHourMinus1,
    required this.onAddHourPlus1,
    required this.onAddDayPlus1,
    required this.onPlay1x,
    required this.onPlay10x,
    required this.onPause,
    required this.onScenarioChanged,
    required this.onDogStepsChanged,

    required this.dogSprite,
    required this.plantColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,          // <<< MOVED FROM bottomCenter
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 24, bottom: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 420,
            maxHeight: 650,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // handle
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),

                      // TIME CONTROLS -----------------------------------------
                      const Text(
                        "Simulated Time Controls",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          FancyDebugButton(
                            label: "-1 day",
                            onPressed: onAddDayMinus1,
                          ),
                          FancyDebugButton(
                            label: "-1 hour",
                            onPressed: onAddHourMinus1,
                          ),
                          FancyDebugButton(
                            label: "+1 hour",
                            onPressed: onAddHourPlus1,
                          ),
                          FancyDebugButton(
                            label: "+1 day",
                            onPressed: onAddDayPlus1,
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 12),

                      // AUTO SIM ---------------------------------------------
                      const Text(
                        "Auto Simulation",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        autoSimLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          FancyDebugButton(
                            label: "Play 1x",
                            onPressed: onPlay1x,
                          ),
                          FancyDebugButton(
                            label: "Play 10x",
                            onPressed: onPlay10x,
                          ),
                          FancyDebugButton(
                            label: "Pause",
                            onPressed: onPause,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          ScenarioChip(
                            label: "Dry (0.2)",
                            value: "dry",
                            groupValue: "",
                            onTap: () => onScenarioChanged("dry"),
                          ),
                          ScenarioChip(
                            label: "OK (0.6)",
                            value: "ok",
                            groupValue: "",
                            onTap: () => onScenarioChanged("ok"),
                          ),
                          ScenarioChip(
                            label: "Perfect (1.0)",
                            value: "perfect",
                            groupValue: "",
                            onTap: () => onScenarioChanged("perfect"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 12),

                      // DOG DEBUG --------------------------------------------
                      const Text(
                        "Dog Step / Mood Debug",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        "Steps today: $stepsToday / $dogStepGoal   |   Mood: ${dogMood.toStringAsFixed(2)}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        dogMoodLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Slider(
                        value: stepsToday.toDouble(),
                        min: 0,
                        max: dogStepGoal.toDouble(),
                        divisions: 100,
                        label: stepsToday.toString(),
                        onChanged: onDogStepsChanged,
                      ),

                      const SizedBox(height: 6),

                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(height: 72, child: dogSprite),
                      ),

                      const SizedBox(height: 14),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 12),

                      // PLANT DEBUG ------------------------------------------
                      const Text(
                        "Plant State Debug",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        "Health: ${plantHealth.toStringAsFixed(2)}   |   Smoothed hydration: ${hydrationSmoothed.toStringAsFixed(2)}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: plantColor,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: Colors.white, width: 1.1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              plantHealthLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Health level",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 4),

                      SizedBox(
                        height: 8,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final t =
                                plantHealth.clamp(0.0, 1.0);
                            final w = constraints.maxWidth * t;

                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color:
                                        Colors.white.withOpacity(0.15),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 250),
                                  width: w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFEF5350),
                                        Color(0xFFFFC107),
                                        Color(0xFF66BB6A),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
