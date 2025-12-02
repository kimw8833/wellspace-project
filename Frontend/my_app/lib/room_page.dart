import 'package:flutter/material.dart';

class MyRoomPage extends StatefulWidget {
  final int playerId;
  const MyRoomPage({super.key, required this.playerId});

  @override
  State<MyRoomPage> createState() => _MyRoomPageState();
}

class _MyRoomPageState extends State<MyRoomPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/roomHappy.png"),
          //fit: BoxFit.cover,
        ),
      ),
    );
  }
}
