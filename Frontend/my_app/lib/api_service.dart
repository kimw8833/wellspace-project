import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //final String baseUrl = 'http://127.0.0.1:8000'; //for testing locally
  final String baseUrl = 'https://paragogically-unlegible-grazyna.ngrok-free.dev'; //ngrok URL


  //
  // ROOM MOOD FUNCTION
  //
  Future<int?> getRoomMood(int userId) async {
    final url = Uri.parse('$baseUrl/api/room-mood/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["room_mood"]; // ← får room mood 0,1,2,...
      } else {
        return null; // error
      }
    } catch (e) {
      return null;
    }
  }

  //
  // DOG STATUS FUNCTION
  //
  Future<int?> getDogStatus(int userId) async {
    final url = Uri.parse('$baseUrl/api/dog-status/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["dog_status"]; // ← får dog status 0,1,2,...
      } else {
        return null; // error
      }
    } catch (e) {
      return null;
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
