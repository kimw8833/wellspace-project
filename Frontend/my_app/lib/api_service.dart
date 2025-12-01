import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000'; //for testing locally

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
