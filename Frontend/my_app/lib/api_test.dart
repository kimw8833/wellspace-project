import 'dart:async';
import 'api_service.dart';

void main() async {
  final api = ApiService();

  print("==== TESTING API SERVICE ====\n");

  // 1) Test Login
  print("🔹 Testing Login()");
  final loginResult = await api.login("Kim", "1234");
  print("Result: $loginResult\n");

  // 2) Test Plant Status
  print("🔹 Testing getPlantStatus()");
  final plant = await api.getPlantStatus(1);
  print("Plant status = $plant\n");

  // 3) Test Dog Status
  print("🔹 Testing getDogStatus()");
  final dog = await api.getDogStatus(1);
  print("Dog status = $dog\n");

  // 4) Test Window Status
  print("🔹 Testing getWindowStatus()");
  final window = await api.getWindowStatus(1);
  print("Window status = $window\n");

  // 5) Test Room Mood
  print("🔹 Testing getRoomMood()");
  final mood = await api.getRoomMood(1);
  print("Room mood = $mood\n");

  print("==== DONE TESTING ====");
}
