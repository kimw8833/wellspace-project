// lib/widgets/water_input_dialog.dart

import 'package:flutter/material.dart';

class WaterInputDialog extends StatefulWidget {
  final int waterToday;
  final int dailyGoal;

  /// Called with the chosen amount (e.g. 250 or 500).
  final void Function(int ml) onAdd;

  const WaterInputDialog({
    super.key,
    required this.waterToday,
    required this.dailyGoal,
    required this.onAdd,
  });

  @override
  State<WaterInputDialog> createState() => _WaterInputDialogState();
}

class _WaterInputDialogState extends State<WaterInputDialog> {
  late int _waterTodayLocal;

  @override
  void initState() {
    super.initState();
    _waterTodayLocal = widget.waterToday;
  }

  void _add(int ml) {
    widget.onAdd(ml); // updates controller
    setState(() {
      _waterTodayLocal += ml; // updates dialog UI immediately
      if (_waterTodayLocal < 0) _waterTodayLocal = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeGoal = widget.dailyGoal <= 0 ? 1 : widget.dailyGoal;
    final progress = (_waterTodayLocal / safeGoal).clamp(0.0, 1.0);
    final remaining = (widget.dailyGoal - _waterTodayLocal).clamp(0, 1 << 30);

    String fmtMl(int ml) => "${ml} ml";

    Widget addButton(int ml) {
      return Expanded(
        child: ElevatedButton(
          onPressed: () => _add(ml),
          child: Text("+ ${fmtMl(ml)}"),
        ),
      );
    }

    return AlertDialog(
      title: const Text("Water the plant"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: numbers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today"),
              Text("$_waterTodayLocal / ${widget.dailyGoal} ml"),
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
              progress >= 1.0 ? "Goal hit 🎉" : "Remaining: $remaining ml",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          const SizedBox(height: 16),

          // Quick amounts
          Row(
            children: [
              addButton(250),
              const SizedBox(width: 12),
              addButton(500),
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
