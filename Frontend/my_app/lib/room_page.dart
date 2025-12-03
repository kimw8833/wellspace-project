import 'package:flutter/material.dart';
import 'api_service.dart';

class MyRoomPage extends StatefulWidget {
  final int playerId;
  const MyRoomPage({super.key, required this.playerId});

  @override
  State<MyRoomPage> createState() => _MyRoomPageState();
}

class _MyRoomPageState extends State<MyRoomPage> {
  late Future<int?> roomMood;
  late Future<int?> dogMood;

  @override
  void initState() {
    super.initState();
    roomMood = ApiService().getRoomMood(widget.playerId);
    dogMood = ApiService().getDogStatus(widget.playerId);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/roomHappy.png"),
              //fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 30,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<int?>(
                future: roomMood,
                builder: (context, snapshot) {
                  return Text(
                    "Room mood: ${snapshot.data}",
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              FutureBuilder<int?>(
                future: dogMood,
                builder: (context, snapshot) {
                  return Text(
                    "Dog mood: ${snapshot.data}",
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
