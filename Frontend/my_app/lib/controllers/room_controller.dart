// lib/controllers/room_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';

import '../models/plant_model.dart';
import '../models/dog_model.dart';
import '../models/time_simulation.dart';
import '../models/room_state.dart';
import '../services/api_service.dart';
import '../models/achievement_definitions.dart';

import 'dart:async';
import 'dart:math';



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
  
  // COINS
  int coins = 0;
  int coinsDisplay = 0;

  Timer? _coinRampTimer;

  void setCoinsImmediate(int v) {
    coins = v;
    coinsDisplay = v;
    notifyListeners();
  }

  void rampCoinsDisplayTo(
    int target, {
    Duration duration = const Duration(milliseconds: 650),
  }) {
    _coinRampTimer?.cancel();
    target = max(0, target);

    final start = coinsDisplay;
    final diff = target - start;
    if (diff == 0) return;

    final ticks = max(1, (duration.inMilliseconds / 16).round());
    final step = diff / ticks;

    var tick = 0;
    _coinRampTimer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      tick++;
      final next = start + (step * tick);
      final rounded = diff > 0 ? next.floor() : next.ceil();
      coinsDisplay = diff > 0 ? min(rounded, target) : max(rounded, target);
      notifyListeners();

      if (tick >= ticks || coinsDisplay == target) {
        coinsDisplay = target;
        notifyListeners();
        t.cancel();
      }
    });
  }



  // Loading state
  bool isLoading = true;

  // Timers
  Timer? _simTimer;
  Timer? _realTimeTimer;

  // ===================================================
  //                ACHIEVEMENTS (INDEX-DRIVEN)
  // ===================================================

  /// achievement_index -> progress (0–100)
  final Map<int, int> _achievementProgress = {1: 0, 2: 0, 3: 0};

  /// achievement_index values that have been claimed (frontend-only for now)
  final Set<int> _claimedAchievements = {};

  /// Explorer achievement (index 1): unique events only
  final Set<String> _explorerEventsSeen = {};

  static const int explorerAchievementIndex = 1;

  /// These are the only events that should count toward “Welcome Home”.
  /// (You can add more later, but keep it explicit.)
  static const List<String> explorerRequiredEvents = [
    'open_achievements',
    'open_friends',
    'open_settings',
  ];
  


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
    coinsDisplay = coins;

    _initialize();
  }

  // ===================================================
  //                EFFECTIVE TIME SOURCE
  // ===================================================

  DateTime get effectiveNow {
    return time.autoSimRunning ? time.simulatedTime : DateTime.now();
  }

  // ===================================================
  //          CORE INITIALIZATION WITH LOADING
  // ===================================================

  Future<void> _initialize() async {
    await _loadInitialBackendState();
    await _loadAchievementsFromBackend();
    isLoading = false;

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

    final coinsFromDb = await _api.getUserCoin(userId);
    if(coinsFromDb != null) {
      coins = coinsFromDb;
    }
  }

  Future<void> _loadAchievementsFromBackend() async {
    // ApiService returns List<Map<String, dynamic>>
    final list = await _api.getAchievements(userId);
    for (final a in list) {
      final index = a['achievement_index'];
      final progress = a['progress'];
      if (index is int && progress is int && _achievementProgress.containsKey(index)) {
        _achievementProgress[index] = progress.clamp(0, 100);
      }
    }
  }

  // ===================================================
  //                ACHIEVEMENT PUBLIC API
  // ===================================================

  int achievementProgress(int index) => _achievementProgress[index] ?? 0;

  bool isAchievementCompleted(int index) => achievementProgress(index) >= 100;

  bool isAchievementClaimed(int index) => _claimedAchievements.contains(index);

  void claimAchievement(int index) {
    if (!isAchievementCompleted(index)) return;
    if (isAchievementClaimed(index)) return;

    _claimedAchievements.add(index);

    final def = achievementDefinitions[index];
    if (def != null && def.rewardCoins > 0) {
      coins += def.rewardCoins;

      unawaited(_api.updateUserCoin(userId, coins));

    }

    notifyListeners();
  }

  void resetAllAchievements() {
    // Reset progress for all achievement indices
    for (final index in _achievementProgress.keys) {
      _achievementProgress[index] = 0;
    }

    // Clear claimed achievements
    _claimedAchievements.clear();

    // Reset explorer achievement state
    _explorerEventsSeen.clear();

    // IMPORTANT:
    // - Do NOT touch coins
    // - Do NOT sync to backend
    // This is debug-only, local reset

    notifyListeners();
  }




  // ===================================================
  //                ACHIEVEMENT 1: EXPLORER
  // ===================================================

  /// Call this from UI when the user opens a feature.
  /// Only counts the FIRST time per eventKey.
  void registerExplorerEvent(String eventKey) {
    if (!explorerRequiredEvents.contains(eventKey)) return;
    if (_explorerEventsSeen.contains(eventKey)) return;

    _explorerEventsSeen.add(eventKey);
    _recomputeExplorerProgressAndSync();
  }

  void _recomputeExplorerProgressAndSync() {
    final required = explorerRequiredEvents.length;
    final seen = _explorerEventsSeen.length.clamp(0, required);

    // Deterministic progress: 0..100
    final nextProgress = ((seen * 100) / required).round().clamp(0, 100);
    _setAchievementProgressAndSync(explorerAchievementIndex, nextProgress);
  }

  void _setAchievementProgressAndSync(int index, int nextProgress) {
    final current = _achievementProgress[index] ?? 0;
    final clamped = nextProgress.clamp(0, 100);

    if (clamped == current) {
      notifyListeners();
      return;
    }

    _achievementProgress[index] = clamped;
    // Persist progress via your existing backend method
    _api.updateAchievementProgress(userId, index, clamped);
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

  void addCoins(int amount) {
    coins += amount;
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
