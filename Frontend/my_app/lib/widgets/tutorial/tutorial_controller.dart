// lib/widgets/tutorial/tutorial_controller.dart
import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';
import 'tutorial_step.dart';

class TutorialController extends ChangeNotifier {
  final ApiService api;
  final int userId;
  final List<TutorialStep> steps;
  final VoidCallback onClose;

  int _index = 0;
  bool _closing = false;

  TutorialController({
    required this.api,
    required this.userId,
    required this.steps,
    required this.onClose,
  });

  TutorialStep get current => steps[_index];
  bool get isLast => _index == steps.length - 1;

  void next() {
    if (_closing) return;
    if (isLast) {
      finish();
    } else {
      _index++;
      notifyListeners();
    }
  }

  Future<void> skip() => _completeAndClose();
  Future<void> finish() => _completeAndClose();

  Future<void> _completeAndClose() async {
    if (_closing) return;
    _closing = true;

    try {
      await api.markTutorialComplete(userId);
    } catch (_) {}

    onClose();
  }
}
