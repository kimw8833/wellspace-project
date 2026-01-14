// lib/models/dog_model.dart

class DogModel {
  // 0..1
  double mood;

  bool lockedHappy;

  int stepsToday;
  int stepsAtLastTick;

  DateTime lastTickTime;

  // Early-morning rule applied once per day.
  bool earlyRuleApplied;

  int stepGoal;

  static const int earlySteps = 1000;
  static const Duration tickInterval = Duration(minutes: 30);

  // Mood model parameters.
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

  void resetForNewDay(DateTime startOfDay) {
    mood = 0.5;
    lockedHappy = false;
    stepsToday = 0;
    stepsAtLastTick = 0;
    earlyRuleApplied = false;
    lastTickTime = startOfDay;
  }

  // Set steps and apply a tick at currentTime using the implied delta.
  void debugSetSteps(int newSteps, DateTime currentTime) {
    final clamped = newSteps.clamp(0, stepGoal);
    final delta = clamped - stepsToday;
    stepsToday = clamped;
    applyTick(currentTime, forcedStepsDelta: delta);
  }

  // Apply ticks between two timestamps (used for simulated time progression).
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

  void applyTick(DateTime atTime, {int? forcedStepsDelta}) {
    if (lockedHappy) return;

    final dayStart = DateTime(atTime.year, atTime.month, atTime.day);
    final minutesSinceDayStart = atTime.difference(dayStart).inMinutes;
    final isFirstHour = minutesSinceDayStart < 60;

    final int delta = forcedStepsDelta ?? (stepsToday - stepsAtLastTick);

    // First hour: one-time daily adjustment based on reaching earlySteps.
    if (isFirstHour && !earlyRuleApplied) {
      if (stepsToday >= earlySteps) {
        mood += 0.25;
      } else {
        mood -= 0.15;
      }
      earlyRuleApplied = true;
    } else {
      // Regular tick: gain on movement, decay when idle.
      if (delta > 0) {
        mood += gainPer1000 * (delta / 1000.0);
      } else {
        mood -= decayWhenIdle;
      }
    }

    // Lock at max mood once step goal is reached.
    if (stepsToday >= stepGoal) {
      mood = 1.0;
      lockedHappy = true;
    }

    mood = mood.clamp(0.0, 1.0);
    stepsAtLastTick = stepsToday;
  }
}
