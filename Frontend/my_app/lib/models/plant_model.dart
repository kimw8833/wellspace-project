// lib/models/plant_model.dart

class PlantModel {
  double health;               // S in [0,1]
  double hydrationSmoothed;    // g in [0,1]

  // Constants (same as your room_page.dart)
  static const double H = 1.0;     // upper bound
  static const double D = 0.0;     // lower bound
  static const double k = 0.10;    // growth-rate constant
  static const double d = 0.05;    // decay-rate constant
  static const double alpha = 0.35; // hydration smoothing

  PlantModel({
    this.health = 0.7,
    this.hydrationSmoothed = 0.7,
  });

  /// Update plant state given hydration ratio in [0,1].
  /// Mirrors _applyDailyUpdate exactly.
  void applyDailyUpdate(double ratio) {
    final r = ratio.clamp(0.0, 1.0);

    // Smooth hydration: g_i = α r_i + (1−α) g_{i−1}
    final gNew = alpha * r + (1 - alpha) * hydrationSmoothed;

    // γ_i = k(2 g_i - 1)
    final gamma = k * (2 * gNew - 1);

    // S_{i+1} = S_i + γ_i(H - S_i) − d(1 − g_i)(S_i − D)
    double sNext =
        health +
        gamma * (H - health) -
        d * (1 - gNew) * (health - D);

    // Clamp and save
    health = sNext.clamp(D, H);
    hydrationSmoothed = gNew;
  }
}
