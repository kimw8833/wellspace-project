// lib/models/time_simulation.dart

class TimeSimulation {
  DateTime simulatedTime;
  DateTime currentSimulatedDate;

  bool autoSimRunning = false;
  double speedMultiplier = 1.0;

  static const Duration simTickRealDuration = Duration(milliseconds: 300);
  static const double hoursPerTickBase = 1.0;

  // Discrete hydration scenarios.
  String scenario = 'ok'; // 'dry', 'ok', 'perfect'

  TimeSimulation()
      : simulatedTime = DateTime.now(),
        currentSimulatedDate = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );

  // Hydration ratio derived from active scenario.
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

  // Advance simulated time by whole hours.
  void addHours(int hours) {
    simulatedTime = simulatedTime.add(Duration(hours: hours));
    currentSimulatedDate = DateTime(
      simulatedTime.year,
      simulatedTime.month,
      simulatedTime.day,
    );
  }

  // Advance simulated time by whole days.
  void addDays(int days) {
    simulatedTime = simulatedTime.add(Duration(days: days));
    currentSimulatedDate = DateTime(
      simulatedTime.year,
      simulatedTime.month,
      simulatedTime.day,
    );
  }

  // Advance simulated time during auto-simulation.
  // Returns elapsed minutes.
  int tickAutoSim() {
    final hoursToAdd = hoursPerTickBase * speedMultiplier;
    final minutes = (hoursToAdd * 60).round();
    simulatedTime = simulatedTime.add(Duration(minutes: minutes));
    return minutes;
  }

  // Check whether simulated date boundary was crossed.
  bool isNewDay() {
    final newDate = DateTime(
      simulatedTime.year,
      simulatedTime.month,
      simulatedTime.day,
    );
    return newDate != currentSimulatedDate;
  }

  // Update cached date after a detected boundary.
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
    return "${d.year}-${two(d.month)}-${two(d.day)}  "
           "${two(d.hour)}:${two(d.minute)}";
  }
}
