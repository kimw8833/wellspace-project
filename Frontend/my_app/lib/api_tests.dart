import 'dart:async';
import '/services/api_service.dart';

String _randomUsername([String prefix = "WellspaceUser"]) {
  final ms = DateTime.now().millisecondsSinceEpoch;
  return "${prefix}_$ms";
}

// ---------------------------------------------------------
// Mini Test Runner (PASS/FAIL + summary)
// ---------------------------------------------------------
class TestRunner {
  int passed = 0;
  int failed = 0;

  Future<void> test(String name, Future<void> Function() body) async {
    try {
      await body();
      passed++;
      print('PASS: $name');
    } catch (e) {
      failed++;
      print('FAIL: $name');
      print('   -> $e');
    }
  }

  void expect(bool condition, String message) {
    if (!condition) throw Exception(message);
  }

  void expectEq(dynamic actual, dynamic expected, String message) {
    if (actual != expected) {
      throw Exception('$message (expected=$expected, got=$actual)');
    }
  }

  void summary() {
    print('\n==== TEST SUMMARY ====');
    print('Passed: $passed');
    print('Failed: $failed');
    print('======================\n');
  }
}

Future<void> main() async {
  final api = ApiService();
  final t = TestRunner();

  print("==== TESTING API SERVICE ====\n");

  // ---------------------------------------------------------
  // 0) REGISTER + VERIFY + DELETE (cleanup)
  // ---------------------------------------------------------
  await t.test('REGISTER -> login -> verify room_status -> DELETE', () async {
    final newUsername = _randomUsername();
    const newPassword = "1234";

    final reg = await api.register(newUsername, newPassword);
    t.expect(reg["success"] == true, 'register() should succeed');

    final u = reg["user"];
    t.expect(u != null, 'register() should return user');
    final v = u["id"];

    int? newUserId;
    if (v is int) newUserId = v;
    if (v is num) newUserId = v.toInt();
    if (v is String) newUserId = int.tryParse(v);

    t.expect(newUserId != null, 'register() should return a valid user id');

    // login new user
    final loginNew = await api.login(newUsername, newPassword);
    t.expect(loginNew["success"] == true, 'login(new user) should succeed');

    // verify room_status exists (prefer full room status, fallback plant)
    final rs = await api.getFullRoomStatus(newUserId!);
    if (rs == null || rs.isEmpty) {
      final ps = await api.getPlantStatus(newUserId);
      t.expect(ps != null, 'plant status fallback should return a value');
    }

    // cleanup delete
    final del = await api.deleteUser(newUserId);
    t.expect(del["success"] == true, 'deleteUser() should succeed');
  });

  // ---------------------------------------------------------
  // 1) LOGIN (Kim)
  // ---------------------------------------------------------
  int userId = -1;
  await t.test('LOGIN Kim', () async {
    final loginResult = await api.login("Kim", "1234");
    t.expect(loginResult["success"] == true, 'login(Kim) should succeed');

    final user = loginResult["user"];
    t.expect(user != null, 'login() should return user');

    final id = user["id"];
    t.expect(id is int, 'user.id should be int');
    userId = id as int;

    t.expect(userId > 0, 'userId should be > 0');
  });

  // If login failed, skip rest of tests
  if (userId <= 0) {
    t.summary();
    return;
  }

  // ---------------------------------------------------------
  // 2) ACHIEVEMENTS (GET + PUT + GET) + claimed + tier
  // ---------------------------------------------------------
  await t.test('ACHIEVEMENTS: progress + claimed + tier', () async {
    int _toInt(dynamic v, [int def = 0]) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? def;
    }

    // before (optional)
    final before = await api.getAchievements(userId);
    t.expect(before is List, 'getAchievements should return a list');

    // -------------------------
    // UPDATE
    // -------------------------
    final okP1 = await api.updateAchievementProgress(userId, 1, 55);
    t.expect(okP1 == true, 'updateAchievementProgress(index=1,55) should succeed');

    final okP2 = await api.updateAchievementProgress(userId, 2, 100);
    t.expect(okP2 == true, 'updateAchievementProgress(index=2,100) should succeed');

    // set claimed + tier (ตัวอย่าง: index1 claimed=1 tier=2, index2 claimed=0 tier=1)
    final okC1 = await api.updateAchievementClaimed(userId, 1, 1);
    t.expect(okC1 == true, 'updateAchievementClaimed(index=1,1) should succeed');

    final okT1 = await api.updateAchievementTier(userId, 1, 2);
    t.expect(okT1 == true, 'updateAchievementTier(index=1,2) should succeed');

    final okC2 = await api.updateAchievementClaimed(userId, 2, 0);
    t.expect(okC2 == true, 'updateAchievementClaimed(index=2,0) should succeed');

    final okT2 = await api.updateAchievementTier(userId, 2, 1);
    t.expect(okT2 == true, 'updateAchievementTier(index=2,1) should succeed');

    // -------------------------
    // VERIFY
    // -------------------------
    final after = await api.getAchievements(userId);

    Map<String, dynamic>? a1;
    Map<String, dynamic>? a2;

    for (final a in after) {
      if (a["achievement_index"] == 1) a1 = a;
      if (a["achievement_index"] == 2) a2 = a;
    }

    t.expect(a1 != null, 'achievement index 1 should exist');
    t.expect(a2 != null, 'achievement index 2 should exist');

    // progress
    t.expectEq(_toInt(a1!["progress"]), 55, 'achievement 1 progress should be 55');
    t.expectEq(_toInt(a2!["progress"]), 100, 'achievement 2 progress should be 100');

    // claimed (0/1)
    t.expectEq(_toInt(a1["claimed"]), 1, 'achievement 1 claimed should be 1');
    t.expectEq(_toInt(a2["claimed"]), 0, 'achievement 2 claimed should be 0');

    // tier
    t.expectEq(_toInt(a1["tier"]), 2, 'achievement 1 tier should be 2');
    t.expectEq(_toInt(a2["tier"]), 1, 'achievement 2 tier should be 1');
  });

  // ---------------------------------------------------------
  // 3) STATUSES: GET endpoints
  // ---------------------------------------------------------
  await t.test('GET plant status', () async {
    final plant = await api.getPlantStatus(userId);
    t.expect(plant != null, 'plant status should not be null');
  });

  await t.test('GET dog status', () async {
    final dog = await api.getDogStatus(userId);
    t.expect(dog != null, 'dog status should not be null');
  });

  await t.test('GET window status', () async {
    final window = await api.getWindowStatus(userId);
    t.expect(window != null, 'window status should not be null');
  });

  await t.test('GET room mood', () async {
    final mood = await api.getRoomMood(userId);
    t.expect(mood != null, 'room mood should not be null');
  });

  // ---------------------------------------------------------
  // 4) STATUSES: UPDATE endpoints + recheck
  // ---------------------------------------------------------
  await t.test('UPDATE statuses then recheck', () async {
    final okPlant = await api.updatePlantStatus(userId, 0.20);
    t.expect(okPlant == true, 'updatePlantStatus should succeed');

    final okDog = await api.updateDogStatus(userId, 0.50);
    t.expect(okDog == true, 'updateDogStatus should succeed');

    final okWindow = await api.updateWindowStatus(userId, 1.00);
    t.expect(okWindow == true, 'updateWindowStatus should succeed');

    final okRoom = await api.updateRoomMood(userId, 0.75);
    t.expect(okRoom == true, 'updateRoomMood should succeed');

    final newPlant = await api.getPlantStatus(userId);
    final newDog = await api.getDogStatus(userId);
    final newWin = await api.getWindowStatus(userId);
    final newMood = await api.getRoomMood(userId);

    // Simple null checks
    t.expect(newPlant != null, 'recheck plant should not be null');
    t.expect(newDog != null, 'recheck dog should not be null');
    t.expect(newWin != null, 'recheck window should not be null');
    t.expect(newMood != null, 'recheck mood should not be null');
  });

  // ---------------------------------------------------------
  // 5) STEP GOAL (GET + PUT + GET)
  // ---------------------------------------------------------
  await t.test('STEP GOAL: GET -> PUT -> GET', () async {
    final stepGoal = await api.getStepGoal(userId);
    t.expect(stepGoal != null, 'stepGoal should not be null');

    final ok = await api.updateStepGoal(userId, (stepGoal ?? 4000) + 1000);
    t.expect(ok == true, 'updateStepGoal should succeed');

    final stepGoal2 = await api.getStepGoal(userId);
    t.expect(stepGoal2 != null, 'stepGoal after update should not be null');
  });

  // ---------------------------------------------------------
  // 6) WATER GOAL (GET + PUT + GET)
  // ---------------------------------------------------------
  await t.test('WATER GOAL: GET -> PUT -> GET', () async {
    final waterGoal = await api.getWaterintakeGoal(userId);
    t.expect(waterGoal != null, 'waterGoal should not be null');

    final ok = await api.updateWaterintakeGoal(userId, (waterGoal ?? 2000) + 500);
    t.expect(ok == true, 'updateWaterintakeGoal should succeed');

    final waterGoal2 = await api.getWaterintakeGoal(userId);
    t.expect(waterGoal2 != null, 'waterGoal after update should not be null');
  });

  // ---------------------------------------------------------
  // 7) USER LOCATION (GET + PUT + GET)
  // ---------------------------------------------------------
  await t.test('USER LOCATION: toggle inside/outside', () async {
    final loc = await api.getUserLocation(userId);
    t.expect(loc != null, 'user_location should not be null');

    final newLoc = (loc == 'inside') ? 'outside' : 'inside';
    final ok = await api.updateUserLocation(userId, newLoc);
    t.expect(ok == true, 'updateUserLocation should succeed');

    final loc2 = await api.getUserLocation(userId);
    t.expect(loc2 != null, 'user_location after update should not be null');
    t.expectEq(loc2, newLoc, 'user_location should match toggled value');
  });

  // ---------------------------------------------------------
  // 8) FULL ROOM STATUS (GET)
  // ---------------------------------------------------------
  await t.test('FULL ROOM STATUS: getFullRoomStatus returns data', () async {
    final fullStatus = await api.getFullRoomStatus(userId);
    t.expect(fullStatus != null && fullStatus.isNotEmpty, 'full room_status should not be empty');
  });

  // ---------------------------------------------------------
  // 9) COIN (GET + PUT + GET)
  // ---------------------------------------------------------
  await t.test('COIN: GET -> PUT -> GET updates correctly', () async {
    final before = await api.getUserCoin(userId);
    t.expect(before != null, 'coinBefore should not be null');

    final newValue = (before ?? 0) + 10;
    final ok = await api.updateUserCoin(userId, newValue);
    t.expect(ok == true, 'updateUserCoin should succeed');

    final after = await api.getUserCoin(userId);
    t.expect(after != null, 'coinAfter should not be null');
    t.expectEq(after, newValue, 'coin should match updated value');
  });

  // ---------------------------------------------------------
  // 10) FRIENDS FLOW (Kim -> Tommy -> accept -> list -> remove)
  // ---------------------------------------------------------
  await t.test('FRIENDS: send -> accept -> list -> remove', () async {
    const friendUsername = "Tommy";

    // send request
    final sent = await api.sendFriendRequest(userId, friendUsername);
    t.expect(sent == true, 'sendFriendRequest should succeed');

    // login as Tommy
    final loginTommy = await api.login("Tommy", "1234");
    t.expect(loginTommy["success"] == true, 'login(Tommy) should succeed');

    final tommyUser = loginTommy["user"];
    t.expect(tommyUser != null, 'Tommy user should exist');
    final int tommyId = tommyUser["id"];

    // incoming requests
    final incoming = await api.getIncomingFriendRequests(tommyId);

    final reqFromKim = incoming.where((r) => r["requester_id"] == userId).toList();
    t.expect(reqFromKim.isNotEmpty, 'Tommy should have pending request from Kim');

    // accept
    final accepted = await api.acceptFriendRequest(tommyId, userId);
    t.expect(accepted == true, 'acceptFriendRequest should succeed');

    // list friends Kim
    final kimFriends = await api.getFriends(userId);
    t.expect(kimFriends is List, 'getFriends(Kim) should return list');

    int? tommyIdFromKimList;
    for (final f in kimFriends) {
      if ((f["username"]?.toString() ?? "") == "Tommy") {
        final v = f["id"];
        if (v is int) tommyIdFromKimList = v;
        if (v is num) tommyIdFromKimList = v.toInt();
        if (v is String) tommyIdFromKimList = int.tryParse(v);
      }
    }

    t.expect(tommyIdFromKimList != null, 'Tommy should appear in Kim friend list after accept');

    // remove friend (cleanup)
    final removed = await api.removeFriend(userId, tommyIdFromKimList!);
    t.expect(removed == true, 'removeFriend should succeed');
  });

  // ---------------------------------------------------------
  t.summary();
}
