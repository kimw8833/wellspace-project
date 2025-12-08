import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //final String baseUrl = 'http://127.0.0.1:8000'; //for testing locally
  final String baseUrl = 'https://paragogically-unlegible-grazyna.ngrok-free.dev'; //ngrok URL

  //
  // GET FULL ROOM STATUS (statuses + timestamps)
  //
  Future<Map<String, dynamic>?> getFullRoomStatus(int userId) async {
    final url = Uri.parse('$baseUrl/api/room-status/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["ok"] == true && data["room_status"] != null) {
          return Map<String, dynamic>.from(data["room_status"]);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //
  // --- STEP GOAL / WATER GOAL / USER LOCATION ---
  //

  //
  // GET STEP GOAL
  //
  Future<int?> getStepGoal(int userId) async {
    final url = Uri.parse('$baseUrl/api/step-goal/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final value = data["step_goal"];
        if (value is num) {
          return value.toInt();
        }
        return int.tryParse(value.toString());
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //
  // UPDATE STEP GOAL
  //
  Future<bool> updateStepGoal(int userId, int newGoal) async {
    final url = Uri.parse('$baseUrl/api/step-goal/$userId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "step_goal": newGoal,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  //
  // GET WATER INTAKE GOAL (ml)
  //
  Future<int?> getWaterintakeGoal(int userId) async {
    final url = Uri.parse('$baseUrl/api/waterintake-goal/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final value = data["waterintake_goal"];
        if (value is num) {
          return value.toInt();
        }
        return int.tryParse(value.toString());
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //
  // UPDATE WATER INTAKE GOAL
  //
  Future<bool> updateWaterintakeGoal(int userId, int newGoal) async {
    final url = Uri.parse('$baseUrl/api/waterintake-goal/$userId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "waterintake_goal": newGoal,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  //
  // GET USER LOCATION (inside / outside)
  //
  Future<String?> getUserLocation(int userId) async {
    final url = Uri.parse('$baseUrl/api/user-location/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["user_location"]?.toString();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //
  // UPDATE USER LOCATION
  //
  Future<bool> updateUserLocation(int userId, String newLocation) async {
    // expected: "inside" or "outside"
    final url = Uri.parse('$baseUrl/api/user-location/$userId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "user_location": newLocation,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  //
  // GET PLANT STATUS 
  //
  Future<double?> getPlantStatus(int userId) async {
    final url = Uri.parse('$baseUrl/api/plant-status/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final value = data["plant_status"];
        if (value is num) {
          return value.toDouble();
        }
        return double.tryParse(value.toString());
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //
  // UPDATE PLANT STATUS
  //
  Future<bool> updatePlantStatus(int userId, double newValue) async {
    final url = Uri.parse('$baseUrl/api/plant-status/$userId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "plant_status": newValue,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  //
  // GET DOG STATUS 
  //
  Future<double?> getDogStatus(int userId) async {
    final url = Uri.parse('$baseUrl/api/dog-status/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final value = data["dog_status"];
        if (value is num) {
          return value.toDouble();
        }
        return double.tryParse(value.toString());
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //
  // UPDATE DOG STATUS
  //
  Future<bool> updateDogStatus(int userId, double newValue) async {
    final url = Uri.parse('$baseUrl/api/dog-status/$userId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "dog_status": newValue,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  //
  // GET WINDOW STATUS 
  //
  Future<double?> getWindowStatus(int userId) async {
    final url = Uri.parse('$baseUrl/api/window-status/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final value = data["window_status"];
        if (value is num) {
          return value.toDouble();
        }
        return double.tryParse(value.toString());
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //
  // UPDATE WINDOW STATUS
  //
  Future<bool> updateWindowStatus(int userId, double newValue) async {
    final url = Uri.parse('$baseUrl/api/window-status/$userId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "window_status": newValue,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  //
  // GET ROOM MOOD 
  //
  Future<double?> getRoomMood(int userId) async {
    final url = Uri.parse('$baseUrl/api/room-mood/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final value = data["room_mood"];
        if (value is num) {
          return value.toDouble();
        }
        return double.tryParse(value.toString());
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //
  // UPDATE ROOM MOOD
  //
  Future<bool> updateRoomMood(int userId, double newValue) async {
    final url = Uri.parse('$baseUrl/api/room-mood/$userId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "room_mood": newValue,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  //
  // LOGIN FUNCTION
  //
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['ok'] == true) {
        // login success
        return {
          "success": true,
          "user": data["user"], // { id: ..., username: ... }
        };
      } else {
        // login fail ex. user/password stämmer inte
        return {
          "success": false,
          "error": data["error"] ?? "Login failed",
        };
      }
    } catch (e) {
      // network error eller server error
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }
  
  // Fetch games for a specific user. Takes playerId as argument.
  Future<List<dynamic>> getUserLoginData() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));

    if (response.statusCode == 200) {
      return json.decode(response.body); // Convert JSON response to List
    } else {
      throw Exception('Failed to user data');
    }
  }
}
