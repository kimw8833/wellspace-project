// lib/models/room_state.dart

class RoomState {
  final double plantHealth;
  final double dogHealth;
  final int stepsToday;
  final int waterToday;

  RoomState({
    required this.plantHealth,
    required this.dogHealth,
    required this.stepsToday,
    required this.waterToday,
  });
}
