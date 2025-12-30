// Frontend/my_app/lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://paragogically-unlegible-grazyna.ngrok-free.dev';

  // Common headers for ALL requests
  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

  Map<String, String> get _getHeaders => {
        'ngrok-skip-browser-warning': 'true',
      };

  //
  // REGISTER (plain text)
  //
  // returns:
  // { "success": true, "user": {id, username} }
  // or { "success": false, "error": "..." }
  //
  Future<Map<String, dynamic>> register(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/register');

    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: json.encode({'username': username, 'password': password}),
      );

      print("REGISTER RAW: ${response.body}");
      final data = json.decode(response.body);

      // backend should return { ok: true, user: {...} }
      if (response.statusCode == 201 && data['ok'] == true) {
        return {"success": true, "user": data["user"]};
      }

      // Incase backend returns success:true (For the future)
      if ((response.statusCode == 200 || response.statusCode == 201) && data['success'] == true) {
        return {"success": true, "user": data["user"]};
      }

      return {
        "success": false,
        "error": data["error"] ?? data["message"] ?? "Register failed"
      };
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  //
  // DELETE USER
  //
  Future<Map<String, dynamic>> deleteUser(int userId) async {
    final url = Uri.parse('$baseUrl/api/users/$userId');

    try {
      final response = await http.delete(url, headers: _jsonHeaders);

      print("DELETE USER RAW: ${response.body}");

      // Sometimes backend may send empty body -> Just in case, we handle that
      Map<String, dynamic> data = {};
      try {
        data = json.decode(response.body);
      } catch (_) {}

      if (response.statusCode == 200 && (data["ok"] == true || data["success"] == true)) {
        return {"success": true, "data": data};
      }

      return {
        "success": false,
        "error": data["error"] ?? data["message"] ?? "Delete user failed"
      };
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

// --------------------------------------------------
// ACHIEVEMENTS
// --------------------------------------------------

// GET achievements for a user
//
// Backend:
//   GET /api/achievements/:userId
// Expected response:
//   { "success": true, "achievements": [ { "achievement_index": 1, "progress": 55 }, ... ] }
//
// Returns:
//   List of maps: [{achievement_index: int, progress: int}, ...]
//   If anything fails, returns [].
Future<List<Map<String, dynamic>>> getAchievements(int userId) async {
  final url = Uri.parse('$baseUrl/api/achievements/$userId');

  try {
    final response = await http.get(url, headers: _getHeaders);
    print("Achievements RAW: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Support both:
      // - { success:true, achievements:[...] }
      // - { ok:true, achievements:[...] } (just in case)
      final ok = data["success"] == true || data["ok"] == true;
      if (!ok) return [];

      final List list = data["achievements"] ?? [];
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return [];
  } catch (e) {
    print("Get achievements error: $e");
    return [];
  }
}

// UPDATE/UPSERT achievement progress
//
// Backend:
//   PUT /api/achievements/:userId/:index
// Body:
//   { "progress": 0..100 }
//
// Expected response:
//   { "success": true, ... }  (or at least statusCode 200)
//
// Returns:
//   true if statusCode == 200
Future<bool> updateAchievementProgress(int userId, int achievementIndex, int progress) async {
  final url = Uri.parse('$baseUrl/api/achievements/$userId/$achievementIndex');

  // Clamp to valid range to avoid accidental invalid calls from UI
  final int safeProgress = progress.clamp(0, 100);

  try {
    final response = await http.put(
      url,
      headers: _jsonHeaders,
      body: json.encode({"progress": safeProgress}),
    );

    print("Update achievement RAW: ${response.body}");
    return response.statusCode == 200;
  } catch (e) {
    print("Update achievement error: $e");
    return false;
  }
}

  //
  // GET FULL ROOM STATUS
  //
  Future<Map<String, dynamic>?> getFullRoomStatus(int userId) async {
    final url = Uri.parse('$baseUrl/api/room-status/$userId');

    try {
      final response = await http.get(url, headers: _getHeaders);
      print("🔥 Room-status RAW: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, dynamic>.from(data["room_status"] ?? {});
      }
    } catch (_) {}
    return null;
  }

  //
  // STEP GOAL
  //
  Future<int?> getStepGoal(int userId) async {
    final url = Uri.parse('$baseUrl/api/step-goal/$userId');
    print("🌍 HITTING STEP-GOAL URL: $url");

    try {
      final response = await http.get(url, headers: _getHeaders);
      print("🔥 API RAW step-goal response for user $userId: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("🧩 Decoded step-goal JSON for user $userId: $data");

        final value = data["step_goal"];
        if (value is num) return value.toInt();
        return int.tryParse(value.toString());
      }
    } catch (e) {
      print("❌ Step goal fetch error: $e");
    }
    return null;
  }

  Future<bool> updateStepGoal(int userId, int newGoal) async {
    final url = Uri.parse('$baseUrl/api/step-goal/$userId');

    try {
      final response = await http.put(
        url,
        headers: _jsonHeaders,
        body: json.encode({"step_goal": newGoal}),
      );

      print("⬆️ Updated step-goal → ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Step-goal update error: $e");
      return false;
    }
  }

  //
  // WATER GOAL
  //
  Future<int?> getWaterintakeGoal(int userId) async {
    final url = Uri.parse('$baseUrl/api/waterintake-goal/$userId');

    try {
      final response = await http.get(url, headers: _getHeaders);
      print("🔥 Water-goal RAW: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final value = data["waterintake_goal"];
        if (value is num) return value.toInt();
        return int.tryParse(value.toString());
      }
    } catch (_) {}

    return null;
  }

  Future<bool> updateWaterintakeGoal(int userId, int newGoal) async {
    final url = Uri.parse('$baseUrl/api/waterintake-goal/$userId');

    try {
      final response = await http.put(
        url,
        headers: _jsonHeaders,
        body: json.encode({"waterintake_goal": newGoal}),
      );

      print("⬆️ Updated water-goal → ${response.body}");
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  //
  // USER LOCATION
  //
  Future<String?> getUserLocation(int userId) async {
    final url = Uri.parse('$baseUrl/api/user-location/$userId');

    try {
      final response = await http.get(url, headers: _getHeaders);
      print("🔥 Location RAW: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["user_location"]?.toString();
      }
    } catch (_) {}

    return null;
  }

  Future<bool> updateUserLocation(int userId, String newLocation) async {
    final url = Uri.parse('$baseUrl/api/user-location/$userId');

    try {
      final response = await http.put(
        url,
        headers: _jsonHeaders,
        body: json.encode({"user_location": newLocation}),
      );

      print("⬆️ Updated user-location → ${response.body}");
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  //
  // PLANT STATUS
  //
  Future<double?> getPlantStatus(int userId) async {
    final url = Uri.parse('$baseUrl/api/plant-status/$userId');

    try {
      final response = await http.get(url, headers: _getHeaders);
      print("🌿 Plant RAW: ${response.body}");

      if (response.statusCode == 200) {
        final value = json.decode(response.body)["plant_status"];
        if (value is num) return value.toDouble();
        return double.tryParse(value.toString());
      }
    } catch (_) {}
    return null;
  }

  Future<bool> updatePlantStatus(int userId, double newValue) async {
    final url = Uri.parse('$baseUrl/api/plant-status/$userId');

    try {
      final response = await http.put(
        url,
        headers: _jsonHeaders,
        body: json.encode({"plant_status": newValue}),
      );
      print("⬆️ Updated plant-status: ${response.body}");
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  //
  // DOG STATUS
  //
  Future<double?> getDogStatus(int userId) async {
    final url = Uri.parse('$baseUrl/api/dog-status/$userId');

    try {
      final response = await http.get(url, headers: _getHeaders);
      print("🐶 Dog RAW: ${response.body}");

      if (response.statusCode == 200) {
        final value = json.decode(response.body)["dog_status"];
        if (value is num) return value.toDouble();
        return double.tryParse(value.toString());
      }
    } catch (_) {}

    return null;
  }

  Future<bool> updateDogStatus(int userId, double newValue) async {
    final url = Uri.parse('$baseUrl/api/dog-status/$userId');

    try {
      final response = await http.put(
        url,
        headers: _jsonHeaders,
        body: json.encode({"dog_status": newValue}),
      );
      print("⬆️ Updated dog-status: ${response.body}");
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  //
  // WINDOW STATUS
  //
  Future<double?> getWindowStatus(int userId) async {
    final url = Uri.parse('$baseUrl/api/window-status/$userId');

    try {
      final response = await http.get(url, headers: _getHeaders);
      print("🪟 Window RAW: ${response.body}");

      if (response.statusCode == 200) {
        final value = json.decode(response.body)["window_status"];
        if (value is num) return value.toDouble();
        return double.tryParse(value.toString());
      }
    } catch (_) {}
    return null;
  }

  Future<bool> updateWindowStatus(int userId, double newValue) async {
    final url = Uri.parse('$baseUrl/api/window-status/$userId');

    try {
      final response = await http.put(
        url,
        headers: _jsonHeaders,
        body: json.encode({"window_status": newValue}),
      );
      print("⬆️ Updated window-status: ${response.body}");
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  //
  // ROOM MOOD
  //
  Future<double?> getRoomMood(int userId) async {
    final url = Uri.parse('$baseUrl/api/room-mood/$userId');

    try {
      final response = await http.get(url, headers: _getHeaders);
      print("🎭 Room-mood RAW: ${response.body}");

      if (response.statusCode == 200) {
        final value = json.decode(response.body)["room_mood"];
        if (value is num) return value.toDouble();
        return double.tryParse(value.toString());
      }
    } catch (_) {}
    return null;
  }

  Future<bool> updateRoomMood(int userId, double newValue) async {
    final url = Uri.parse('$baseUrl/api/room-mood/$userId');

    try {
      final response = await http.put(
        url,
        headers: _jsonHeaders,
        body: json.encode({"room_mood": newValue}),
      );
      print("⬆️ Updated room-mood: ${response.body}");
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  //
  // LOGIN
  //
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/login');

    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: json.encode({'username': username, 'password': password}),
      );

      print("🔐 LOGIN RAW: ${response.body}");
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['ok'] == true) {
        return {"success": true, "user": data["user"]};
      }
      return {"success": false, "error": data["error"] ?? "Login failed"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // --------------------------------------------------
  // FRIENDS
  // --------------------------------------------------

  //
  // SEND FRIEND REQUEST (by username)
  //
  Future<bool> sendFriendRequest(int userId, String friendUsername) async {
    final url = Uri.parse('$baseUrl/api/friends/add');

    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: json.encode({
          "userId": userId,
          "friendUsername": friendUsername,
        }),
      );

      print("Send friend request RAW: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("Send friend request error: $e");
      return false;
    }
  }

  //
  // GET INCOMING FRIEND REQUESTS (pending)
  //
  // returns:
  // [
  //   { friendship_id, requester_id, requester_username, created_at }
  // ]
  //
  Future<List<Map<String, dynamic>>> getIncomingFriendRequests(int userId) async {
    final url = Uri.parse('$baseUrl/api/friend-requests/$userId');

    try {
      final response = await http.get(url, headers: _getHeaders);
      print("Incoming friend requests RAW: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data["requests"] ?? [];
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print("Get incoming friend requests error: $e");
    }

    return [];
  }

  //
  // ACCEPT FRIEND REQUEST (by ids)
  //
  Future<bool> acceptFriendRequest(int userId, int requesterId) async {
    final url = Uri.parse('$baseUrl/api/friends/accept');

    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: json.encode({
          "userId": userId,
          "requesterId": requesterId,
        }),
      );

      print("Accept friend request RAW: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("Accept friend request error: $e");
      return false;
    }
  }

  //
  // REJECT FRIEND REQUEST
  //
  Future<bool> rejectFriendRequest(int userId, int requesterId) async {
    final url = Uri.parse('$baseUrl/api/friends/reject');

    try {
      final response = await http.post(
        url,
        headers: _jsonHeaders,
        body: json.encode({
          "userId": userId,
          "requesterId": requesterId,
        }),
      );

      print("Reject friend request RAW: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("Reject friend request error: $e");
      return false;
    }
  }

  //
  // GET FRIEND LIST (accepted friends)
  //
  // returns:
  // [
  //   { id, username }
  // ]
  //
  Future<List<Map<String, dynamic>>> getFriends(int userId) async {
    final url = Uri.parse('$baseUrl/api/friends/$userId');

    try {
      final response = await http.get(url, headers: _getHeaders);
      print("Friends list RAW: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data["friends"] ?? [];
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print("Get friends error: $e");
    }

    return [];
  }

  //
  // REMOVE FRIEND (unfriend)
  //
  Future<bool> removeFriend(int userId, int friendId) async {
    final url = Uri.parse('$baseUrl/api/friends');

    try {
      final response = await http.delete(
        url,
        headers: _jsonHeaders,
        body: json.encode({
          "userId": userId,
          "friendId": friendId,
        }),
      );

      print("Remove friend RAW: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("Remove friend error: $e");
      return false;
    }
  }


  //
  // COINS
  //

  // GET user coin amount
  //
  // Backend:
  //   GET /api/coins/:userId
  //
  // Expected response:
  //   { "success": true, "coins": 123 }
  //
  // Returns:
  //   int coin count, or null if anything fails
  Future<int?> getUserCoin(int userId) async {
    final url = Uri.parse('$baseUrl/api/coins/$userId');

    try {
      final response = await http.get(url, headers: _getHeaders);
      print("🪙 Get coins RAW: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final value = data["coins"];
        if (value is num) return value.toInt();
        return int.tryParse(value.toString());
      }
    } catch (e) {
      print("❌ Get user coin error: $e");
    }

    return null;
  }


  // UPDATE user coin amount
  //
  // Backend:
  //   PUT /api/coins/:userId
  // Body:
  //   { "coins": newValue }
  //
  // Returns:
  //   true if successful
  Future<bool> updateUserCoin(int userId, int newCoinValue) async {
    final url = Uri.parse('$baseUrl/api/coins/$userId');

    // Prevent negative coins unless backend allows it later
    final safeValue = newCoinValue < 0 ? 0 : newCoinValue;

    try {
      final response = await http.put(
        url,
        headers: _jsonHeaders,
        body: json.encode({"coins": safeValue}),
      );

      print("🪙 Update coins RAW: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Update user coin error: $e");
      return false;
    }
  }



}


