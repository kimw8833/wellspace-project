// lib/utils/constants.dart

import 'package:flutter/material.dart';

/// Canvas sizes used in sprite positioning.
/// These should match your background room image resolution.
class CanvasSize {
  static const double width = 2528;
  static const double height = 1696;
}

/// Sprite scale factors (used in Positioned + Transform.scale).
class SpriteScale {
  static const double plant = 2.0;
  static const double dog = 1.8;
}

/// Default debug UI values.
class DebugUI {
  static const double panelMaxWidth = 420;
  static const double panelMaxHeight = 650;
  static const double panelBlurSigma = 20;

  static const Color panelBackground =
      Color.fromARGB(140, 0, 0, 0); // black w/ opacity
}

/// Simulation constants shared across UI
class SimulationConstants {
  static const double defaultDailyWaterGoal = 2000;
}
