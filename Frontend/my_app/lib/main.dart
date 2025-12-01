import 'package:flutter/material.dart';
import 'RoomPage.dart';
import 'api_service.dart';

// HTTP package
import 'package:http/http.dart' as http;
import 'dart:convert';
const String baseUrl = 'https://paragogically-unlegible-grazyna.ngrok-free.dev'; // Ändra url här 
// 

/* Example POST request:

final url = Uri.parse('$baseUrl/api/login');

final response = await http.post(
  url,
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'username': _usernameController.text.trim(),
    'password': _passwordController.text.trim(),
  }),
);

Andra exempel (typ likadant):
POST https://paragogically-unlegible-grazyna.ngrok-free.dev/api/login
{
  "username": "kim",
  "password": "1234"
}

*/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellspace',
      home: const MyHomePage(title: 'Wellspace'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late Future<List<dynamic>> usersData;
  List<Map<String, dynamic>> users = [];
/*
  void initState() {
    super.initState();

    usersData = ApiService().getAllUsers();
    usersData.then((fetchedData) {
      setState(() {
        users = fetchedData.map<Map<String, dynamic>>((item) {
          return {
            'UserID': item['UserID'],
            'Nickname': item['Nickname'],
            'OnlineStatus': item['OnlineStatus'],
          };
        }).toList();
      });
    }).catchError((error) {
      print("Error fetching users: $error");
    });
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(146, 202, 170, 1),
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 50),
            SizedBox(
              width: 400,
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 400,
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 400,
              child: ElevatedButton(
                onPressed: () {
                  //if (_usernameController.text == username &&
                  //  _passwordController.text == password) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RoomPage()),
                  );
                  //   }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(146, 202, 170, 1),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
