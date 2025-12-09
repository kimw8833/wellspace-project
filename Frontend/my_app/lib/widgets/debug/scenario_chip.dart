// lib/widgets/debug/scenario_chip.dart

import 'package:flutter/material.dart';

class ScenarioChip extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final VoidCallback onTap;

  const ScenarioChip({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  bool get _selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _selected
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selected ? Colors.purpleAccent : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(_selected ? 1.0 : 0.8),
            fontSize: 12.5,
            fontWeight: _selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
