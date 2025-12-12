// lib/models/plant_model.dart

class PlantModel {
  double health;            // S in [0,1]
  double hydrationSmoothed; // g in [0,1]

  // Bounds
  static const double H = 1.0;
  static const double D = 0.0;

  // Base dynamics (keep these familiar)
  static const double k = 0.10;     // growth-rate constant
  static const double d = 0.05;     // decay-rate constant
  static const double alpha = 0.35; // hydration smoothing

  PlantModel({
    this.health = 0.7,
    this.hydrationSmoothed = 0.7,
  });

  /// Update plant state given hydration ratio in [0,1].
  ///
  /// Design goals:
  /// - Escape DEAD zone fast with perfect hydration
  /// - Stage 3 (alive) is the main dopamine milestone
  /// - Stage 5 (perfect) is rare and fragile
  /// - No instant full revival
  void applyDailyUpdate(double ratio) {
    final r = ratio.clamp(0.0, 1.0);

    // --- Smooth hydration ---
    // g_i = α r_i + (1−α) g_{i−1}
    final gNew = alpha * r + (1 - alpha) * hydrationSmoothed;

    // --- Zone-based multipliers ---
    // Zones are tuned to VISUAL meaning of sprites
    double growthMul;
    double decayMul;

    if (health < 0.40) {
      // DEAD ZONE (stages 1–2)
      growthMul = 2.2; // strong recovery
      decayMul  = 0.5; // already punished enough
    } else if (health < 0.70) {
      // ALIVE ZONE (stage 3)
      growthMul = 1.0; // stable, habit-forming
      decayMul  = 1.0;
    } else if (health < 0.85) {
      // HEALTHY ZONE (stage 4)
      growthMul = 0.6; // diminishing returns
      decayMul  = 1.3; // needs maintenance
    } else {
      // PERFECT ZONE (stage 5)
      growthMul = 0.3; // very hard to improve
      decayMul  = 1.8; // fragile
    }

    // --- Growth driver ---
    // γ_i = k(2 g_i − 1) * growthMul
    final gamma = k * (2 * gNew - 1) * growthMul;

    // --- State update ---
    // S_{i+1} = S_i + γ_i(H − S_i) − d·decayMul·(1 − g_i)(S_i − D)
    double sNext =
        health +
        gamma * (H - health) -
        (d * decayMul) * (1 - gNew) * (health - D);

    // Clamp and save
    health = sNext.clamp(D, H);
    hydrationSmoothed = gNew;
  }
}
