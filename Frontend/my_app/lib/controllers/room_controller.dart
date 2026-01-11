// lib/controllers/room_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';

import '../models/plant_model.dart';
import '../models/dog_model.dart';
import '../models/time_simulation.dart';
import '../models/room_state.dart';
import '../services/api_service.dart';
import '../models/achievement_definitions.dart';

import 'dart:math';

class RoomController extends ChangeNotifier {
  final int userId;
  final bool readOnly;
  final ApiService _api = ApiService();

  // =========================
  // Debug simulation mode flag
  // =========================
  //
  // When true: simulated time is authoritative (manual + auto sim work)
  // When false: real time is authoritative
  bool debugSimActive = false;

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

  bool get _canWrite => !readOnly;

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

  final Map<int, int> _achievementTier = {1: 0, 2: 0, 3: 0};

  int achievementTier(int index) => _achievementTier[index] ?? 0;

  static const List<String> explorerRequiredEvents = [
    'open_achievements',
    'open_friends',
    'open_settings',
  ];

  RoomController(this.userId, {this.readOnly = false}) {
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

  /// In normal mode -> real time
  /// In debug sim mode -> simulated time
  DateTime get effectiveNow {
    return debugSimActive ? time.simulatedTime : DateTime.now();
  }

  // ===================================================
  //                DEBUG SIM LIFECYCLE
  // ===================================================

  /// Turn on debug sim time authority (does not persist anything by itself).
  void enterDebugSim() {
    if (!_canWrite) return;

    debugSimActive = true;

    // Anchor the sim clock to now on entry (nice default)
    time.simulatedTime = DateTime.now();
    time.updateCurrentDate();

    notifyListeners();
  }

  /// Turn off debug sim time authority and return to real time.
  void exitDebugSim({bool resetTimeToNow = true}) {
    stopAutoSim(); // also restarts real ticker
    debugSimActive = false;

    if (resetTimeToNow) {
      time.simulatedTime = DateTime.now();
      time.updateCurrentDate();
    }

    notifyListeners();
  }

  /// Explicitly persist current debug-tuned plant & dog state.
  /// Achievements are intentionally not touched here.
  Future<void> commitDebugState() async {
    if (!_canWrite) return;

    await _api.updatePlantStatus(userId, plant.health);
    await _api.updateDogStatus(userId, dog.mood);

    // Optional: you could persist coins/steps/etc here later if desired.
    // For now, strictly plant + dog as agreed.

    // Exit debug sim after committing so the system snaps back to "truth".
    exitDebugSim(resetTimeToNow: true);
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
        // Only tick UI on real time when not in debug sim and not autosimming.
        // (Autosim already notifies on each sim tick.)
        if (!debugSimActive && !time.autoSimRunning) {
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
    if (coinsFromDb != null) {
      coins = coinsFromDb;
      coinsDisplay = coinsFromDb;
    }
  }

  Future<void> _loadAchievementsFromBackend() async {
    final list = await _api.getAchievements(userId);

    int? toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '');
    }

    bool toBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = (v?.toString() ?? '').toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }

    for (final a in list) {
      final index = toInt(a['achievement_index']);
      final progress = toInt(a['progress']);

      if (index == null || progress == null) continue;
      if (!_achievementProgress.containsKey(index)) continue;

      // ✅ Progress should never go down based on a recompute later
      final current = _achievementProgress[index] ?? 0;
      final p = progress.clamp(0, 100);
      _achievementProgress[index] = max(current, p);

      // ✅ Tier (default 0 if missing)
      final tier = toInt(a['tier']) ?? 0;
      _achievementTier[index] = max(0, tier);

      // ✅ Claimed (default false if missing)
      final claimed = toBool(a['claimed']);
      if (claimed) {
        _claimedAchievements.add(index);
      } else {
        _claimedAchievements.remove(index);
      }
    }

    notifyListeners();
  }

  // ===================================================
  //                ACHIEVEMENT PUBLIC API
  // ===================================================

  int achievementProgress(int index) => _achievementProgress[index] ?? 0;

  bool isAchievementCompleted(int index) => achievementProgress(index) >= 100;

  bool isAchievementClaimed(int index) => _claimedAchievements.contains(index);

  void claimAchievement(int index) {
    if (!_canWrite) return;
    if (!isAchievementCompleted(index)) return;
    if (isAchievementClaimed(index)) return;

    _claimedAchievements.add(index);

    // ✅ Persist claimed immediately
    unawaited(_api.updateAchievementClaimed(userId, index, 1));

    final def = achievementDefinitions[index];
    if (def != null && def.rewardCoins > 0) {
      coins += def.rewardCoins;
      unawaited(_api.updateUserCoin(userId, coins));
    }

    notifyListeners();
  }

  void resetAllAchievements() {
    if (!_canWrite) return;
    for (final index in _achievementProgress.keys) {
      _achievementProgress[index] = 0;
      _achievementTier[index] = 0;
    }

    _claimedAchievements.clear();
    _explorerEventsSeen.clear();

    // ✅ Sync reset to backend (testing)
    for (final index in _achievementProgress.keys) {
      unawaited(_api.updateAchievementProgress(userId, index, 0));
      unawaited(_api.updateAchievementClaimed(userId, index, 0));
      unawaited(_api.updateAchievementTier(userId, index, 0));
    }

    notifyListeners();
  }

  // ===================================================
  //                ACHIEVEMENT 1: EXPLORER
  // ===================================================

  void registerExplorerEvent(String eventKey) {
    if (!_canWrite) return;
    if (!explorerRequiredEvents.contains(eventKey)) return;
    if (_explorerEventsSeen.contains(eventKey)) return;

    _explorerEventsSeen.add(eventKey);
    _recomputeExplorerProgressAndSync();
  }

  void _recomputeExplorerProgressAndSync() {
    final required = explorerRequiredEvents.length;
    final seen = _explorerEventsSeen.length.clamp(0, required);

    final nextProgress = ((seen * 100) / required).round().clamp(0, 100);
    _setAchievementProgressAndSync(explorerAchievementIndex, nextProgress);
  }

  void _setAchievementProgressAndSync(int index, int nextProgress) {
    final current = _achievementProgress[index] ?? 0;
    final clamped = nextProgress.clamp(0, 100);

    final effective = max(current, clamped);

    if (effective == current) {
      notifyListeners();
      return;
    }

    _achievementProgress[index] = effective;

    // Keep achievements behavior as-is (we are not changing achievements now)
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
    if (!_canWrite) return;

    // When debugging, we want the dog to use the simulated clock.
    // When not debugging, it uses real time.
    final clamped = steps.clamp(0, dailyStepGoal);
    dog.debugSetSteps(clamped, effectiveNow);

    notifyListeners();
  }

  // ===================================================
  //                MANUAL TIME CONTROL
  // ===================================================

  void addHours(int hours) {
    if (!_canWrite) return;

    // Manual time travel should always operate in debug sim authority.
    if (!debugSimActive) enterDebugSim();

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
    if (!_canWrite) return;

    if (!debugSimActive) enterDebugSim();

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
    if (!_canWrite) return;

    // Autosim is a debug simulation feature — use simulated time authority.
    if (!debugSimActive) enterDebugSim();

    stopAutoSim();

    _stopRealTimeTicker();

    // IMPORTANT: Do NOT reset simulatedTime to DateTime.now() here.
    // That was the source of the "pause snaps back / resets" feeling.
    time.autoSimRunning = true;
    time.speedMultiplier = speedMultiplier;

    _simTimer = Timer.periodic(
      TimeSimulation.simTickRealDuration,
      (_) => _simTick(),
    );

    notifyListeners();
  }

  void pauseAutoSim() {
    if (!_canWrite) return;
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
    if (!_canWrite) return;

    // Scenario selection is also part of the debug sim experience.
    if (!debugSimActive) enterDebugSim();

    time.scenario = scenario;
    notifyListeners();
  }

  // ===================================================
  //                WATER CONTROL
  // ===================================================

  void addWater(int ml) {
    if (!_canWrite) return;
    waterToday += ml;
    if (waterToday < 0) waterToday = 0;
    notifyListeners();
  }

  // ===================================================
  //               UPDATE SETTINGS
  // ===================================================

  Future<void> updateSettings(int newSteps, int newWater) async {
    if (!_canWrite) return;

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
    if (!_canWrite) return;

    // Do NOT auto-persist plant/dog while in debug sim.
    // Persistence should be explicit via commitDebugState().
    if (debugSimActive) return;

    await _api.updatePlantStatus(userId, plant.health);
    await _api.updateDogStatus(userId, dog.mood);
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _realTimeTimer?.cancel();
    _coinRampTimer?.cancel();
    super.dispose();
  }
}
