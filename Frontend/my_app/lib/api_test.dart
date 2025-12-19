import 'dart:async';
import '/services/api_service.dart';

String _randomUsername([String prefix = "WellspaceUser"]) {
  final ms = DateTime.now().millisecondsSinceEpoch;
  return "${prefix}_$ms";
}


Future<void> main() async {
  final api = ApiService();

  print("==== TESTING API SERVICE ====\n");

  // ---------------------------------------------------------
  // 0) REGISTER + VERIFY + DELETE (cleanup)
  // ---------------------------------------------------------
  print("🔹 Testing register() + deleteUser() flow ...");

  final newUsername = _randomUsername();
  const newPassword = "1234";

  final reg = await api.register(newUsername, newPassword);
  print("Register result: $reg");

  int? newUserId;
  if (reg["success"] == true) {
    final u = reg["user"];
    final v = u["id"];
    if (v is int) newUserId = v;
    if (v is num) newUserId = v.toInt();
    if (v is String) newUserId = int.tryParse(v);

    print("Registered user = $newUsername (id=$newUserId)");

    // Optional: login new user to confirm it works
    print("🔹 Testing login() with newly registered user ...");
    final loginNew = await api.login(newUsername, newPassword);
    print("Login(new user) result: $loginNew");

    // Verify room_status exists by calling an existing endpoint
    if (newUserId != null) {
      print("🔹 Verifying room_status exists (getFullRoomStatus) ...");
      final rs = await api.getFullRoomStatus(newUserId!);
      if (rs != null && rs.isNotEmpty) {
        print("room_status exists for new user. plant_status=${rs['plant_status']}");
      } else {
        // fallback check: plant status
        print("getFullRoomStatus failed or empty. Trying getPlantStatus() ...");
        final ps = await api.getPlantStatus(newUserId!);
        print("Plant status (new user) = $ps");
      }
    }

    // Cleanup: delete new user
    if (newUserId != null) {
      print("🔹 Cleanup: deleteUser($newUserId) ...");
      final del = await api.deleteUser(newUserId!);
      print("Delete result: $del");
    }
  } else {
    print("Register failed -> skipping delete cleanup for new user.");
  }

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
  // ACHIEVEMENTS (GET + PUT + GET)
  // ---------------------------------------------------------
  print("\n=== ACHIEVEMENTS TEST ===");

  // 1) GET achievements (before)
  final beforeAch = await api.getAchievements(userId);
  print("Achievements BEFORE: $beforeAch");

  // 2) UPDATE progress
  final ok1 = await api.updateAchievementProgress(userId, 1, 55);
  if (ok1) {
    print("OK: update achievement index=1 to 55");
  } else {
    print("FAIL: update achievement index=1 to 55");
  }

  final ok2 = await api.updateAchievementProgress(userId, 2, 100);
  if (ok2) {
    print("OK: update achievement index=2 to 100");
  } else {
    print("FAIL: update achievement index=2 to 100");
  }

  // 3) GET achievements (after)
  final afterAch = await api.getAchievements(userId);
  print("Achievements AFTER: $afterAch");

  // 4) Verify values
  int? p1;
  int? p2;

  for (final a in afterAch) {
    if (a["achievement_index"] == 1) {
      p1 = a["progress"];
    }
    if (a["achievement_index"] == 2) {
      p2 = a["progress"];
    }
  }

  if (p1 == 55) {
    print("OK: achievement 1 progress is 55");
  } else {
    print("FAIL: achievement 1 progress expected 55, got $p1");
  }

  if (p2 == 100) {
    print("OK: achievement 2 progress is 100");
  } else {
    print("FAIL: achievement 2 progress expected 100, got $p2");
  }
  print("=== END ACHIEVEMENTS TEST ===\n");

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
  final newDog = await api.getDogStatus(userId);
  final newWin = await api.getWindowStatus(userId);
  final newMood = await api.getRoomMood(userId);

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
  final okWater = await api.updateWaterintakeGoal(
    userId,
    (waterGoal ?? 2000) + 500,
  );
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

  // ---------------------------------------------------------
  // 14) FULL ROOM STATUS (statuses + timestamps)
  // ---------------------------------------------------------
  print("🔹 Testing getFullRoomStatus() ...");
  final fullStatus = await api.getFullRoomStatus(userId);

  if (fullStatus != null) {
    print("Full room_status from backend:");
    print("  user_id            : ${fullStatus['user_id']}");
    print("  plant_status       : ${fullStatus['plant_status']}");
    print("  dog_status         : ${fullStatus['dog_status']}");
    print("  window_status      : ${fullStatus['window_status']}");
    print("  room_mood          : ${fullStatus['room_mood']}");
    print("  last_plant_update  : ${fullStatus['last_plant_update']}");
    print("  last_dog_update    : ${fullStatus['last_dog_update']}");
    print("  last_window_update : ${fullStatus['last_window_update']}");
    print("  last_room_update   : ${fullStatus['last_room_update']}");
    print("  last_plant_read    : ${fullStatus['last_plant_read']}");
    print("  last_dog_read      : ${fullStatus['last_dog_read']}");
    print("  last_window_read   : ${fullStatus['last_window_read']}");
    print("  last_room_read     : ${fullStatus['last_room_read']}");
    print("  updated_at         : ${fullStatus['updated_at']}\n");
  } else {
    print("Failed to fetch full room status.\n");
  }

  // ---------------------------------------------------------
  // 15) FRIENDS FLOW TEST
  // Kim -> send request to Tommy -> Tommy accepts -> list -> remove
  // ---------------------------------------------------------
  print("\n🔹 Testing FRIENDS flow ...");

  const friendUsername = "Tommy";

  // 15.1 Kim sends friend request to Tommy
  print("🔸 15.1 sendFriendRequest($friendUsername) ...");
  final sent = await api.sendFriendRequest(userId, friendUsername);
  print("Send request success = $sent");

  // 15.2 Login as Tommy to accept (so we can test incoming requests correctly)
  print("\n🔸 15.2 login() as Tommy ...");
  final loginTommy = await api.login("Tommy", "1234");
  print("Tommy login result: $loginTommy");

  if (loginTommy["success"] != true) {
    print("Tommy login failed, skipping accept/list/remove tests.");
  } else {
    final tommyUser = loginTommy["user"];
    final int tommyId = tommyUser["id"];
    print("Logged in as Tommy (id = $tommyId)");

    // 15.3 Tommy checks incoming friend requests
    print("\n🔸 15.3 getIncomingFriendRequests(Tommy) ...");
    final incoming = await api.getIncomingFriendRequests(tommyId);
    print("Incoming requests count = ${incoming.length}");
    for (final r in incoming) {
      print("  - from ${r["requester_username"]} (requester_id=${r["requester_id"]})");
    }

    // find request from Kim (userId)
    final reqFromKim = incoming.where((r) => r["requester_id"] == userId).toList();

    if (reqFromKim.isEmpty) {
      print("No pending request from Kim found for Tommy.");
      print("   (Maybe already accepted, already friends, or request not created.)");
    } else {
      // 15.4 Tommy accepts Kim's request
      print("\n🔸 15.4 acceptFriendRequest(Tommy accepts Kim) ...");
      final accepted = await api.acceptFriendRequest(tommyId, userId);
      print("Accept success = $accepted");
    }

    // 15.5 List friends for Kim
    print("\n🔸 15.5 getFriends(Kim) ...");
    final kimFriends = await api.getFriends(userId);
    print("Kim friends (${kimFriends.length}):");
    for (final f in kimFriends) {
      print("  - ${f["username"]} (id=${f["id"]})");
    }

    // 15.6 List friends for Tommy
    print("\n🔸 15.6 getFriends(Tommy) ...");
    final tommyFriends = await api.getFriends(tommyId);
    print("Tommy friends (${tommyFriends.length}):");
    for (final f in tommyFriends) {
      print("  - ${f["username"]} (id=${f["id"]})");
    }

    // หา friendId ของ Tommy จาก friend list ของ Kim (ถ้ามี)
    int? tommyIdFromKimList;
    for (final f in kimFriends) {
      if ((f["username"]?.toString() ?? "") == "Tommy") {
        final v = f["id"];
        if (v is int) tommyIdFromKimList = v;
        if (v is num) tommyIdFromKimList = v.toInt();
        if (v is String) tommyIdFromKimList = int.tryParse(v);
      }
    }

    // 15.7 Remove friend (optional cleanup)
    if (tommyIdFromKimList != null) {
      print("\n🔸 15.7 removeFriend(Kim removes Tommy) ...");
      final removed = await api.removeFriend(userId, tommyIdFromKimList!);
      print("Remove success = $removed");

      // Re-check lists
      print("\n🔸 15.8 Re-check getFriends(Kim) ...");
      final kimFriends2 = await api.getFriends(userId);
      print("Kim friends (${kimFriends2.length}):");
      for (final f in kimFriends2) {
        print("  - ${f["username"]} (id=${f["id"]})");
      }

      print("\n🔸 15.9 Re-check getFriends(Tommy) ...");
      final tommyFriends2 = await api.getFriends(tommyId);
      print("Tommy friends (${tommyFriends2.length}):");
      for (final f in tommyFriends2) {
        print("  - ${f["username"]} (id=${f["id"]})");
      }
    } else {
      print("\nTommy not found in Kim's friend list, so skipping removeFriend().");
    }
  }

  print("==== DONE TESTING ====");
}
