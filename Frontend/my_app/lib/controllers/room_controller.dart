// lib/controllers/room_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';

import '../models/plant_model.dart';
import '../models/dog_model.dart';
import '../models/time_simulation.dart';
import '../models/room_state.dart';
import '../services/api_service.dart';

class RoomController extends ChangeNotifier {
  final int userId;
  final ApiService _api = ApiService();

  // Models
  late PlantModel plant;
  late DogModel dog;
  late TimeSimulation time;

  // Daily counters
  int waterToday = 0;
  int dailyWaterGoal = 2000;
  int dailyStepGoal = 10000;

  // Loading state
  bool isLoading = true;

  // Timers
  Timer? _simTimer;
  Timer? _realTimeTimer;

  RoomController(this.userId) {
    plant = PlantModel();
    time = TimeSimulation();

    final start = DateTime(
      time.currentSimulatedDate.year,
      time.currentSimulatedDate.month,
      time.currentSimulatedDate.day,
      0,
      0,
    );
    dog = DogModel(startOfDay: start, stepGoal: dailyStepGoal);

    _initialize();
  }

  // ===================================================
  //                EFFECTIVE TIME SOURCE
  // ===================================================

  /// The time the app considers "now".
  /// - Real time if auto-sim is OFF
  /// - Simulated time if auto-sim is ON
  DateTime get effectiveNow {
    return time.autoSimRunning ? time.simulatedTime : DateTime.now();
  }

  // ===================================================
  //          CORE INITIALIZATION WITH LOADING
  // ===================================================

  Future<void> _initialize() async {
    await _loadInitialBackendState();
    isLoading = false;

    // Start real-time ticking immediately
    _startRealTimeTicker();

    notifyListeners();
  }

  // ===================================================
  //                REAL-TIME TICKER
  // ===================================================

  void _startRealTimeTicker() {
    _realTimeTimer?.cancel();
    _realTimeTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!time.autoSimRunning) {
          notifyListeners();
        }
      },
    );
  }

  void _stopRealTimeTicker() {
    _realTimeTimer?.cancel();
    _realTimeTimer = null;
  }

  // ===================================================
  //                INITIAL BACKEND FETCH
  // ===================================================

  Future<void> _loadInitialBackendState() async {
    final plantStatus = await _api.getPlantStatus(userId);
    if (plantStatus != null) {
      plant.health = plantStatus;
    }

    final dogStatus = await _api.getDogStatus(userId);
    if (dogStatus != null) {
      dog.mood = dogStatus;
    }

    final stepGoal = await _api.getStepGoal(userId);
    if (stepGoal != null) {
      dailyStepGoal = stepGoal;
      dog.stepGoal = stepGoal;
    }

    final waterGoal = await _api.getWaterintakeGoal(userId);
    if (waterGoal != null) {
      dailyWaterGoal = waterGoal;
    }
  }

  // ===================================================
  //                STATE SNAPSHOT FOR UI
  // ===================================================

  RoomState get state => RoomState(
        plantHealth: plant.health,
        dogHealth: dog.mood,
        stepsToday: dog.stepsToday,
        waterToday: waterToday,
      );

  // ===================================================
  //                PLANT UPDATE
  // ===================================================

  void applyDailyUpdate() {
    final ratio = (waterToday / dailyWaterGoal).clamp(0.0, 1.0);
    plant.applyDailyUpdate(ratio);
    waterToday = 0;
  }

  void _applyDailyUpdateFromScenario() {
    final ratio = time.scenarioRatio.clamp(0.0, 1.0);
    plant.applyDailyUpdate(ratio);
  }

  // ===================================================
  //                DOG STEP UPDATE
  // ===================================================

  void setStepsToday(int steps) {
    final clamped = steps.clamp(0, dailyStepGoal);
    dog.debugSetSteps(clamped, effectiveNow);
    notifyListeners();
  }

  // ===================================================
  //                MANUAL TIME CONTROL
  // ===================================================

  void addHours(int hours) {
    stopAutoSim();

    final prev = time.simulatedTime;
    time.addHours(hours);
    dog.runTicks(prev, time.simulatedTime);

    if (time.isNewDay()) {
      applyDailyUpdate();
      _resetDogForNewDay();
      time.updateCurrentDate();
    }

    notifyListeners();
  }

  void addDays(int days) {
    stopAutoSim();

    if (days > 0) {
      for (int i = 0; i < days; i++) {
        applyDailyUpdate();
        _resetDogForNewDay();
        time.addDays(1);
      }
    } else {
      final prev = time.simulatedTime;
      time.addDays(days);
      dog.runTicks(prev, time.simulatedTime);
    }

    time.updateCurrentDate();
    notifyListeners();
  }

  void _resetDogForNewDay() {
    final d = time.currentSimulatedDate;
    final start = DateTime(d.year, d.month, d.day, 0, 0);
    dog.resetForNewDay(start);
  }

  // ===================================================
  //                AUTO-SIMULATION
  // ===================================================

  void playAutoSim(double speedMultiplier) {
    stopAutoSim();

    _stopRealTimeTicker();

    time.simulatedTime = DateTime.now();
    time.updateCurrentDate();
    time.autoSimRunning = true;
    time.speedMultiplier = speedMultiplier;

    _simTimer = Timer.periodic(
      TimeSimulation.simTickRealDuration,
      (_) => _simTick(),
    );

    notifyListeners();
  }

  void pauseAutoSim() {
    stopAutoSim();
    notifyListeners();
  }

  void stopAutoSim() {
    time.autoSimRunning = false;
    _simTimer?.cancel();
    _simTimer = null;

    _startRealTimeTicker();
  }

  void _simTick() {
    final prev = time.simulatedTime;

    time.tickAutoSim();
    final now = time.simulatedTime;

    dog.runTicks(prev, now);

    if (time.isNewDay()) {
      _applyDailyUpdateFromScenario();
      _resetDogForNewDay();
      time.updateCurrentDate();
    }

    notifyListeners();
  }

  // ===================================================
  //                SCENARIO
  // ===================================================

  void setScenario(String scenario) {
    time.scenario = scenario;
    notifyListeners();
  }

  // ===================================================
  //                WATER CONTROL
  // ===================================================

  void addWater(int ml) {
    waterToday += ml;
    if (waterToday < 0) waterToday = 0;
    notifyListeners();
  }

  // ===================================================
  //               UPDATE SETTINGS
  // ===================================================

  Future<void> updateSettings(int newSteps, int newWater) async {
    dailyStepGoal = newSteps;
    dailyWaterGoal = newWater;
    dog.stepGoal = newSteps;

    await _api.updateStepGoal(userId, newSteps);
    await _api.updateWaterintakeGoal(userId, newWater);

    notifyListeners();
  }

  // ===================================================
  //                BACKEND SYNC
  // ===================================================

  Future<void> saveToBackend() async {
    await _api.updatePlantStatus(userId, plant.health);
    await _api.updateDogStatus(userId, dog.mood);
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _realTimeTimer?.cancel();
    super.dispose();
  }
}
