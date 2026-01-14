// lib/models/plant_model.dart

class PlantModel {
  // State variables
  // S ∈ [0, 1]: plant health
  // g ∈ [0, 1]: smoothed hydration
  double health;
  double hydrationSmoothed;

  // State bounds
  static const double H = 1.0;
  static const double D = 0.0;

  // Model parameters
  static const double k = 0.10;     // growth rate
  static const double d = 0.05;     // decay rate
  static const double alpha = 0.35; // hydration smoothing factor

  PlantModel({
    this.health = 0.7,
    this.hydrationSmoothed = 0.7,
  });

  // Update plant state given daily hydration ratio r ∈ [0, 1].
  void applyDailyUpdate(double ratio) {
    final r = ratio.clamp(0.0, 1.0);

    // Exponential smoothing of hydration:
    // g_i = α r_i + (1 − α) g_{i−1}
    final gNew = alpha * r + (1 - alpha) * hydrationSmoothed;

    // Zone-dependent multipliers based on current health.
    double growthMul;
    double decayMul;

    if (health < 0.40) {
      // Low-health zone
      growthMul = 2.2;
      decayMul = 0.5;
    } else if (health < 0.70) {
      // Stable zone
      growthMul = 1.0;
      decayMul = 1.0;
    } else if (health < 0.85) {
      // High-health zone
      growthMul = 0.6;
      decayMul = 1.3;
    } else {
      // Near-maximum health
      growthMul = 0.3;
      decayMul = 1.8;
    }

    // Growth driver:
    // γ_i = k (2 g_i − 1) · growthMul
    final gamma = k * (2 * gNew - 1) * growthMul;

    // State update:
    // S_{i+1} = S_i
    //          + γ_i (H − S_i)
    //          − d · decayMul · (1 − g_i) · (S_i − D)
    final sNext =
        health +
        gamma * (H - health) -
        (d * decayMul) * (1 - gNew) * (health - D);

    health = sNext.clamp(D, H);
    hydrationSmoothed = gNew;
  }
}
