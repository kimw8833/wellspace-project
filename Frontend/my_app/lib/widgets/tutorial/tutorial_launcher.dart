// lib/widgets/tutorial/tutorial_launcher.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'tutorial_controller.dart';
import 'tutorial_overlay.dart';
import 'tutorial_step.dart';

class TutorialLauncher {
  static OverlayEntry? _entry;

  static void start({
    required BuildContext context,
    required ApiService api,
    required int userId,
    required List<TutorialStep> steps,
  }) {
    if (_entry != null) return;

    late TutorialController controller;

    void close() {
      _entry?.remove();
      _entry = null;
    }

    controller = TutorialController(
      api: api,
      userId: userId,
      steps: steps,
      onClose: close,
    );

    _entry = OverlayEntry(
      builder: (_) => TutorialOverlay(controller: controller),
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }
}
