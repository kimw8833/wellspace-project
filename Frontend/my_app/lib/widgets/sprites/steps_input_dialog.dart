// lib/widgets/steps_input_dialog.dart

import 'package:flutter/material.dart';

class StepsInputDialog extends StatefulWidget {
  final int stepsToday;
  final int dailyGoal;

  /// Called with the chosen delta steps (e.g. +500).
  final void Function(int delta) onAdd;

  const StepsInputDialog({
    super.key,
    required this.stepsToday,
    required this.dailyGoal,
    required this.onAdd,
  });

  @override
  State<StepsInputDialog> createState() => _StepsInputDialogState();
}

class _StepsInputDialogState extends State<StepsInputDialog> {
  late int _stepsLocal;

  /// Stack of recent adds so we can undo.
  /// Stores actual deltas applied (after clamping).
  final List<int> _history = [];

  @override
  void initState() {
    super.initState();
    _stepsLocal = widget.stepsToday;
  }

  bool get _goalMet => widget.dailyGoal > 0 && _stepsLocal >= widget.dailyGoal;

  void _add(int delta) {
    if (delta <= 0) return;

    // Block adding once goal is met (unless goal is 0/invalid)
    if (_goalMet) return;

    // Clamp so we can reach exactly the goal but never exceed it
    final remaining = widget.dailyGoal - _stepsLocal;
    final actual = widget.dailyGoal > 0 ? delta.clamp(0, remaining) : delta;

    if (actual <= 0) return;

    widget.onAdd(actual); // updates controller

    setState(() {
      _stepsLocal += actual;
      if (_stepsLocal < 0) _stepsLocal = 0;
      _history.add(actual);
    });
  }

  void _undo() {
    if (_history.isEmpty) return;

    final last = _history.removeLast();
    widget.onAdd(-last); // subtract in controller (your RoomPage should support this)

    setState(() {
      _stepsLocal -= last;
      if (_stepsLocal < 0) _stepsLocal = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeGoal = widget.dailyGoal <= 0 ? 1 : widget.dailyGoal;
    final progress = (_stepsLocal / safeGoal).clamp(0.0, 1.0);
    final remaining = (widget.dailyGoal - _stepsLocal).clamp(0, 1 << 30);

    Widget addButton(int steps) {
      final disabled = _goalMet;
      return Expanded(
        child: ElevatedButton(
          onPressed: disabled ? null : () => _add(steps),
          child: Text("+ $steps"),
        ),
      );
    }

    return AlertDialog(
      title: const Text("Walk the dog"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: numbers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today"),
              Text("$_stepsLocal / ${widget.dailyGoal}"),
            ],
          ),
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
            ),
          ),

          const SizedBox(height: 10),

          // Status text
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _goalMet ? "Goal hit 🐾" : "Remaining: $remaining steps",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          const SizedBox(height: 16),

          // Quick amounts
          Row(
            children: [
              addButton(500),
              const SizedBox(width: 12),
              addButton(1000),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              addButton(2000),
              const SizedBox(width: 12),
              addButton(5000),
            ],
          ),

          const SizedBox(height: 12),

          // Undo
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _history.isEmpty ? null : _undo,
                  icon: const Icon(Icons.undo),
                  label: const Text("Undo"),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
