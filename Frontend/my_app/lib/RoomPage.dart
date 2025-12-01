import 'package:flutter/material.dart';

class RoomPage extends StatelessWidget {
  const RoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyRoomPage(playerId: 1),
    );
  }
}

class MyRoomPage extends StatefulWidget {
  final int playerId;
  const MyRoomPage({super.key, required this.playerId});
  @override
  _MyRoomPageState createState() => _MyRoomPageState(playerId: playerId);
}

class _MyRoomPageState extends State<MyRoomPage> {
  final int playerId;
  _MyRoomPageState({required this.playerId});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/roomHappy.png"),
          //fit: BoxFit.cover,
        ),
      ),
    );
  }
}
