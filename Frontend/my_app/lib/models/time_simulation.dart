// lib/models/time_simulation.dart

class TimeSimulation {
  DateTime simulatedTime;
  DateTime currentSimulatedDate;

  bool autoSimRunning = false;
  double speedMultiplier = 1.0;

  static const Duration simTickRealDuration = Duration(milliseconds: 300);
  static const double hoursPerTickBase = 1.0;

  String scenario = 'ok'; // 'dry', 'ok', 'perfect'

  TimeSimulation()
      : simulatedTime = DateTime.now(),
        currentSimulatedDate = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );

  /// Return hydration ratio based on scenario.
  double get scenarioRatio {
    switch (scenario) {
      case 'dry':
        return 0.2;
      case 'perfect':
        return 1.0;
      case 'ok':
      default:
        return 0.6;
    }
  }

  /// Manual hours (does NOT run plant/dog — controller will).
  void addHours(int hours) {
    simulatedTime = simulatedTime.add(Duration(hours: hours));
    currentSimulatedDate = DateTime(
      simulatedTime.year,
      simulatedTime.month,
      simulatedTime.day,
    );
  }

  /// Manual days (controller decides how to update plant/dog).
  void addDays(int days) {
    simulatedTime = simulatedTime.add(Duration(days: days));
    currentSimulatedDate = DateTime(
      simulatedTime.year,
      simulatedTime.month,
      simulatedTime.day,
    );
  }

  /// Called externally by timer to advance time.
  /// Returns how many minutes were advanced.
  int tickAutoSim() {
    final hoursToAdd = hoursPerTickBase * speedMultiplier;
    final minutes = (hoursToAdd * 60).round();
    simulatedTime = simulatedTime.add(Duration(minutes: minutes));
    return minutes;
  }

  /// Detect if date changed.
  bool isNewDay() {
    final newDate = DateTime(
      simulatedTime.year,
      simulatedTime.month,
      simulatedTime.day,
    );
    return newDate != currentSimulatedDate;
  }

  /// Sync date after detecting change.
  void updateCurrentDate() {
    currentSimulatedDate = DateTime(
      simulatedTime.year,
      simulatedTime.month,
      simulatedTime.day,
    );
  }

  String get formattedTime {
    final d = simulatedTime;
    String two(int n) => n.toString().padLeft(2, '0');
    return "${d.year}-${two(d.month)}-${two(d.day)}  ${two(d.hour)}:${two(d.minute)}";
  }
}
