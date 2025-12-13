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

}