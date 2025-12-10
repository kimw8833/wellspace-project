// lib/models/dog_model.dart

import 'package:flutter/foundation.dart'; // ONLY for debug-printing if needed; safe to remove.

class DogModel {
  double mood; // 0..1
  bool lockedHappy;
  int stepsToday;
  int stepsAtLastTick;
  DateTime lastTickTime;
  bool earlyRuleApplied;

  // Constants from your code
  int stepGoal;
  static const int earlySteps = 1000;
  static const Duration tickInterval = Duration(minutes: 30);
  static const double gainPer1000 = 0.18;
  static const double decayWhenIdle = 0.03;

  DogModel({
    this.mood = 0.5,
    this.lockedHappy = false,
    this.stepsToday = 0,
    this.stepsAtLastTick = 0,
    required this.stepGoal,
    DateTime? startOfDay,
    this.earlyRuleApplied = false,
  }) : lastTickTime = startOfDay ?? DateTime.now();

  /// Reset dog at start of day (same as _resetDogForNewDay).
  void resetForNewDay(DateTime startOfDay) {
    mood = 0.5;
    lockedHappy = false;
    stepsToday = 0;
    stepsAtLastTick = 0;
    earlyRuleApplied = false;
    lastTickTime = startOfDay;
  }

  /// Apply steps directly (debug feature).
  void debugSetSteps(int newSteps, DateTime currentTime) {
    final clamped = newSteps.clamp(0, stepGoal);
    final delta = clamped - stepsToday;
    stepsToday = clamped;
    applyTick(currentTime, forcedStepsDelta: delta);
  }

  /// Advance dog ticks between two simulated times.
  void runTicks(DateTime from, DateTime to) {
    if (lockedHappy) {
      lastTickTime = to;
      return;
    }

    DateTime tickTime = lastTickTime;
    if (tickTime.isBefore(from)) {
      tickTime = from;
    }

    while (true) {
      final nextTick = tickTime.add(tickInterval);
      if (nextTick.isAfter(to)) break;
      applyTick(nextTick);
      tickTime = nextTick;
    }

    lastTickTime = tickTime;
  }

  /// Apply one dog tick.
  void applyTick(DateTime atTime, {int? forcedStepsDelta}) {
    if (lockedHappy) return;

    final dayStart = DateTime(atTime.year, atTime.month, atTime.day);
    final minutesSinceDayStart = atTime.difference(dayStart).inMinutes;
    final isFirstHour = minutesSinceDayStart < 60;

    int delta = forcedStepsDelta ?? (stepsToday - stepsAtLastTick);

    // Early morning rule (once per day)
    if (isFirstHour && !earlyRuleApplied) {
      if (stepsToday >= earlySteps) {
        mood += 0.25;
      } else {
        mood -= 0.15;
      }
      earlyRuleApplied = true;
    } else {
      // Normal tick rule
      if (delta > 0) {
        mood += gainPer1000 * (delta / 1000.0);
      } else {
        mood -= decayWhenIdle;
      }
    }

    if (stepsToday >= stepGoal) {
      mood = 1.0;
      lockedHappy = true;
    }

    mood = mood.clamp(0.0, 1.0);
    stepsAtLastTick = stepsToday;
  }
}
