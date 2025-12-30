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

  final String currentScenario;

  // Controller callbacks
  final VoidCallback onAddDayMinus1;
  final VoidCallback onAddHourMinus1;
  final VoidCallback onAddHourPlus1;
  final VoidCallback onAddDayPlus1;
  final VoidCallback onPlay1x;
  final VoidCallback onPlay10x;
  final VoidCallback onPause;
  final VoidCallback onResetAchievements;
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

    required this.currentScenario,

    required this.onAddDayMinus1,
    required this.onAddHourMinus1,
    required this.onAddHourPlus1,
    required this.onAddDayPlus1,
    required this.onPlay1x,
    required this.onPlay10x,
    required this.onPause,
    required this.onResetAchievements,
    required this.onScenarioChanged,
    required this.onDogStepsChanged,

    required this.dogSprite,
    required this.plantColor,
  });

  String _formatTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${d.year}-${two(d.month)}-${two(d.day)}  "
        "${two(d.hour)}:${two(d.minute)}:${two(d.second)}";
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // HANDLE
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

                      // CLOCK
                      Text(
                        _formatTime(simulatedTime),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Divider(color: Colors.white24),

                      // TIME CONTROLS
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
                          FancyDebugButton(label: "-1 day", onPressed: onAddDayMinus1),
                          FancyDebugButton(label: "-1 hour", onPressed: onAddHourMinus1),
                          FancyDebugButton(label: "+1 hour", onPressed: onAddHourPlus1),
                          FancyDebugButton(label: "+1 day", onPressed: onAddDayPlus1),
                        ],
                      ),

                      const SizedBox(height: 14),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 12),

                      // AUTO SIM
                      const Text(
                        "Auto Simulation",
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
                          FancyDebugButton(label: "Play 1x", onPressed: onPlay1x),
                          FancyDebugButton(label: "Play 10x", onPressed: onPlay10x),
                          FancyDebugButton(label: "Pause", onPressed: onPause),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          ScenarioChip(
                            label: "Dry (0.2)",
                            value: "dry",
                            groupValue: currentScenario,
                            onTap: () => onScenarioChanged("dry"),
                          ),
                          ScenarioChip(
                            label: "OK (0.6)",
                            value: "ok",
                            groupValue: currentScenario,
                            onTap: () => onScenarioChanged("ok"),
                          ),
                          ScenarioChip(
                            label: "Perfect (1.0)",
                            value: "perfect",
                            groupValue: currentScenario,
                            onTap: () => onScenarioChanged("perfect"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 12),

                      // DOG DEBUG
                      const Text(
                        "Dog Step / Mood Debug",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Slider(
                        value: stepsToday.toDouble(),
                        min: 0,
                        max: dogStepGoal.toDouble(),
                        onChanged: onDogStepsChanged,
                      ),

                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(height: 72, child: dogSprite),
                      ),

                      const SizedBox(height: 14),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 12),

                      // PLANT DEBUG
                      const Text(
                        "Plant State Debug",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Health: ${plantHealth.toStringAsFixed(2)}   |   Smoothed hydration: ${hydrationSmoothed.toStringAsFixed(2)}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 14),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 12),

                      // ACHIEVEMENTS DEBUG
                      const Text(
                        "Achievements Debug",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      FancyDebugButton(
                        label: "Reset Achievements",
                        onPressed: onResetAchievements,
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
