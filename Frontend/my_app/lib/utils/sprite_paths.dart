// lib/utils/sprite_paths.dart

class PlantSprites {
  static const List<String> stages = [
    "assets/images/plants/stage_1_plant.png",
    "assets/images/plants/stage_2_plant.png",
    "assets/images/plants/stage_3_plant.png",
    "assets/images/plants/stage_4_plant.png",
    "assets/images/plants/stage_5_plant.png",
  ];

  /// Convert plant health (0..1) → index 0–4
  static int indexForHealth(double s) {
    if (s < 0.20) return 0;
    if (s < 0.40) return 1;
    if (s < 0.60) return 2;
    if (s < 0.80) return 3;
    return 4;
  }
}

class DogSprites {
  static const String sad = "assets/images/dogs/sad_dog.png";
  static const String neutral = "assets/images/dogs/neutral_dog.png";
  static const String happy = "assets/images/dogs/happy_dog.png";

  static String forMood(double d) {
    if (d < 0.33) return sad;
    if (d < 0.66) return neutral;
    return happy;
  }
}
