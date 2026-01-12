// lib/widgets/tutorial/tutorial_step.dart
import 'package:flutter/widgets.dart';

class TutorialStep {
  final GlobalKey targetKey;
  final String title;
  final String body;

  const TutorialStep({
    required this.targetKey,
    required this.title,
    required this.body,
  });
}
