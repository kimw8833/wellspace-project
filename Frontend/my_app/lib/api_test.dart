import 'dart:async';
import 'api_service.dart';

Future<void> main() async {
  final api = ApiService();

  print("==== TESTING API SERVICE ====\n");

  // ---------------------------------------------------------
  // 1) Test Login
  // ---------------------------------------------------------
  print("🔹 Testing login() ...");
  final loginResult = await api.login("Kim", "1234");
  print("Result: $loginResult\n");

  if (loginResult["success"] != true) {
    print("Login failed, aborting further tests.");
    return;
  }

  // ใช้ userId จาก backend ตรง ๆ (Kim = id 2 ใน DB ปัจจุบัน)
  final user = loginResult["user"];
  final int userId = user["id"];
  print("Logged in as ${user["username"]} (id = $userId)\n");

  // ---------------------------------------------------------
  // 2) Test GET Plant Status
  // ---------------------------------------------------------
  print("🔹 Testing getPlantStatus() ...");
  final plant = await api.getPlantStatus(userId);
  print("Plant status = $plant\n");

  // ---------------------------------------------------------
  // 3) Test GET Dog Status
  // ---------------------------------------------------------
  print("🔹 Testing getDogStatus() ...");
  final dog = await api.getDogStatus(userId);
  print("Dog status = $dog\n");

  // ---------------------------------------------------------
  // 4) Test GET Window Status
  // ---------------------------------------------------------
  print("🔹 Testing getWindowStatus() ...");
  final window = await api.getWindowStatus(userId);
  print("Window status = $window\n");

  // ---------------------------------------------------------
  // 5) Test GET Room Mood
  // ---------------------------------------------------------
  print("🔹 Testing getRoomMood() ...");
  final mood = await api.getRoomMood(userId);
  print("Room mood = $mood\n");

  // ---------------------------------------------------------
  // 6) UPDATE Plant Status
  // ---------------------------------------------------------
  print("🔹 Testing updatePlantStatus() ...");
  final okPlant = await api.updatePlantStatus(userId, 0.20);
  print("Update Plant Status success = $okPlant\n");

  // ---------------------------------------------------------
  // 7) UPDATE Dog Status
  // ---------------------------------------------------------
  print("🔹 Testing updateDogStatus() ...");
  final okDog = await api.updateDogStatus(userId, 0.50);
  print("Update Dog Status success = $okDog\n");

  // ---------------------------------------------------------
  // 8) UPDATE Window Status
  // ---------------------------------------------------------
  print("🔹 Testing updateWindowStatus() ...");
  final okWindow = await api.updateWindowStatus(userId, 1.00);
  print("Update Window Status success = $okWindow\n");

  // ---------------------------------------------------------
  // 9) UPDATE Room Mood
  // ---------------------------------------------------------
  print("🔹 Testing updateRoomMood() ...");
  final okRoom = await api.updateRoomMood(userId, 0.75);
  print("Update Room Mood success = $okRoom\n");

  // ---------------------------------------------------------
  // 10) Read again after update
  // ---------------------------------------------------------
  print("🔹 Re-checking values after update ...");
  final newPlant = await api.getPlantStatus(userId);
  final newDog   = await api.getDogStatus(userId);
  final newWin   = await api.getWindowStatus(userId);
  final newMood  = await api.getRoomMood(userId);

  print("Updated Plant Status  = $newPlant");
  print("Updated Dog Status    = $newDog");
  print("Updated Window Status = $newWin");
  print("Updated Room Mood     = $newMood\n");

  // ---------------------------------------------------------
  // 11) STEP GOAL
  // ---------------------------------------------------------
  print("🔹 Testing getStepGoal() ...");
  final stepGoal = await api.getStepGoal(userId);
  print("Current step_goal = $stepGoal");

  print("🔹 Testing updateStepGoal() ...");
  final okStep = await api.updateStepGoal(userId, (stepGoal ?? 4000) + 1000);
  print("Update Step Goal success = $okStep");

  final newStepGoal = await api.getStepGoal(userId);
  print("Re-checked step_goal = $newStepGoal\n");

  // ---------------------------------------------------------
  // 12) WATER INTAKE GOAL
  // ---------------------------------------------------------
  print("🔹 Testing getWaterintakeGoal() ...");
  final waterGoal = await api.getWaterintakeGoal(userId);
  print("Current waterintake_goal = $waterGoal");

  print("🔹 Testing updateWaterintakeGoal() ...");
  final okWater = await api.updateWaterintakeGoal(userId, (waterGoal ?? 2000) + 500);
  print("Update Water Intake Goal success = $okWater");

  final newWaterGoal = await api.getWaterintakeGoal(userId);
  print("Re-checked waterintake_goal = $newWaterGoal\n");

  // ---------------------------------------------------------
  // 13) USER LOCATION (inside / outside)
  // ---------------------------------------------------------
  print("🔹 Testing getUserLocation() ...");
  final loc = await api.getUserLocation(userId);
  print("Current user_location = $loc");

  print("🔹 Testing updateUserLocation() ...");
  final newLoc = (loc == 'inside') ? 'outside' : 'inside';
  final okLoc = await api.updateUserLocation(userId, newLoc);
  print("Update User Location success = $okLoc");

  final recheckLoc = await api.getUserLocation(userId);
  print("Re-checked user_location = $recheckLoc\n");

  print("==== DONE TESTING ====");
}
