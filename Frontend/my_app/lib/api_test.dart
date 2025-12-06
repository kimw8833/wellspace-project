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

  // ---------------------------------------------------------
  // 2) Test GET Plant Status
  // ---------------------------------------------------------
  print("🔹 Testing getPlantStatus() ...");
  final plant = await api.getPlantStatus(1);
  print("Plant status = $plant\n");

  // ---------------------------------------------------------
  // 3) Test GET Dog Status
  // ---------------------------------------------------------
  print("🔹 Testing getDogStatus() ...");
  final dog = await api.getDogStatus(1);
  print("Dog status = $dog\n");

  // ---------------------------------------------------------
  // 4) Test GET Window Status
  // ---------------------------------------------------------
  print("🔹 Testing getWindowStatus() ...");
  final window = await api.getWindowStatus(1);
  print("Window status = $window\n");

  // ---------------------------------------------------------
  // 5) Test GET Room Mood
  // ---------------------------------------------------------
  print("🔹 Testing getRoomMood() ...");
  final mood = await api.getRoomMood(1);
  print("Room mood = $mood\n");


  // ---------------------------------------------------------
  // 6) UPDATE Plant Status
  // ---------------------------------------------------------
  print("🔹 Testing updatePlantStatus() ...");
  final okPlant = await api.updatePlantStatus(1, 0.20);
  print("Update Plant Status success = $okPlant\n");

  // ---------------------------------------------------------
  // 7) UPDATE Dog Status
  // ---------------------------------------------------------
  print("🔹 Testing updateDogStatus() ...");
  final okDog = await api.updateDogStatus(1, 0.50);
  print("Update Dog Status success = $okDog\n");

  // ---------------------------------------------------------
  // 8) UPDATE Window Status
  // ---------------------------------------------------------
  print("🔹 Testing updateWindowStatus() ...");
  final okWindow = await api.updateWindowStatus(1, 1.00);
  print("Update Window Status success = $okWindow\n");

  // ---------------------------------------------------------
  // 9) UPDATE Room Mood
  // ---------------------------------------------------------
  print("🔹 Testing updateRoomMood() ...");
  final okRoom = await api.updateRoomMood(1, 0.75);
  print("Update Room Mood success = $okRoom\n");

  // ---------------------------------------------------------
  // 10) Read again after update
  // ---------------------------------------------------------
  print("🔹 Re-checking values after update ...");
  final newPlant = await api.getPlantStatus(1);
  final newDog   = await api.getDogStatus(1);
  final newWin   = await api.getWindowStatus(1);
  final newMood  = await api.getRoomMood(1);

  print("Updated Plant Status  = $newPlant");
  print("Updated Dog Status    = $newDog");
  print("Updated Window Status = $newWin");
  print("Updated Room Mood     = $newMood\n");

  print("==== DONE TESTING ====");
}
