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
  static const int dailyGoal = 2000; // same as before

  // Timer for auto-simulation
  Timer? _simTimer;

  RoomController(this.userId) {
    plant = PlantModel();
    time = TimeSimulation();

    // Initialize dog for the start of the day
    final start = DateTime(
      time.currentSimulatedDate.year,
      time.currentSimulatedDate.month,
      time.currentSimulatedDate.day,
      0,
      0,
    );
    dog = DogModel(startOfDay: start);

    _loadInitialBackendState();
  }

  // ===================================================
  //                INITIAL BACKEND FETCH
  // ===================================================
  Future<void> _loadInitialBackendState() async {
    final roomMood = await _api.getRoomMood(userId);
    if (roomMood != null) {
      // You can choose to map roomMood → plant/dog if needed
    }

    final plantStatus = await _api.getPlantStatus(userId);
    if (plantStatus != null) plant.health = plantStatus;

    final dogStatus = await _api.getDogStatus(userId);
    if (dogStatus != null) dog.mood = dogStatus;

    final windowStatus = await _api.getWindowStatus(userId);
    // You can store window if needed

    notifyListeners();
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
  //                DAILY HYDRATION → PLANT UPDATE
  // ===================================================
  void applyDailyUpdate() {
    final ratio = (waterToday / dailyGoal).clamp(0.0, 1.0);
    plant.applyDailyUpdate(ratio);
    waterToday = 0;
  }

  /// Daily update used by the auto-simulation.
  ///
  /// Instead of using the real `waterToday` counter, this uses
  /// the current [`TimeSimulation.scenarioRatio`] so that the
  /// hydration level in the time-lapse simulation actually
  /// matches the selected scenario (dry / ok / perfect).
  void _applyDailyUpdateFromScenario() {
    final ratio = time.scenarioRatio.clamp(0.0, 1.0);
    plant.applyDailyUpdate(ratio);
    // We deliberately *do not* touch `waterToday` here; that
    // counter is only for the real-world / manual flow.
  }

  // ===================================================
  //                DOG STEP UPDATE
  // ===================================================
  void setStepsToday(int steps) {
    final clamped = steps.clamp(0, DogModel.stepGoal);
    dog.debugSetSteps(clamped, time.simulatedTime);
    notifyListeners();
  }

  // ===================================================
  //                MANUAL TIME CONTROL
  // ===================================================
  void addHours(int hours) {
    stopAutoSim();

    final previousTime = time.simulatedTime;
    time.addHours(hours);

    // Run dog ticks for time difference
    dog.runTicks(previousTime, time.simulatedTime);

    // Daily boundary?
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
      // negative days
      final prev = time.simulatedTime;
      time.addDays(days);
      dog.runTicks(prev, time.simulatedTime);
    }

    time.updateCurrentDate();
    notifyListeners();
  }

  void _resetDogForNewDay() {
    final date = time.currentSimulatedDate;
    final start = DateTime(date.year, date.month, date.day, 0, 0);
    dog.resetForNewDay(start);
  }

  // ===================================================
  //                AUTO-SIMULATION CONTROL
  // ===================================================
  void playAutoSim(double speedMultiplier) {
    stopAutoSim();

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
  }

  void _simTick() {
    final prev = time.simulatedTime;

    time.tickAutoSim();
    final now = time.simulatedTime;

    // Dog updates
    dog.runTicks(prev, now);

    // Check for day boundary
    if (time.isNewDay()) {
      _applyDailyUpdateFromScenario();
      _resetDogForNewDay();
      time.updateCurrentDate();
    }

    notifyListeners();
  }

  // ===================================================
  //                SCENARIO SETTING
  // ===================================================
  void setScenario(String scenario) {
    time.scenario = scenario;
    notifyListeners();
  }

  // ===================================================
  //                WATER INTAKE CONTROL
  // ===================================================
  void addWater(int ml) {
    waterToday += ml;
    if (waterToday < 0) waterToday = 0;
    notifyListeners();
  }

  // ===================================================
  //                BACKEND SYNC (OPTIONAL)
  // ===================================================
  Future<void> saveToBackend() async {
    // Write back current states if you want
    await _api.updatePlantStatus(userId, plant.health);
    await _api.updateDogStatus(userId, dog.mood);
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    super.dispose();
  }
}
