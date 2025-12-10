import 'dart:ui';
import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {
  final int currentStepGoal;
  final int currentWaterGoal;

  const SettingsDialog({
    super.key,
    required this.currentStepGoal,
    required this.currentWaterGoal,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController stepCtrl;
  late TextEditingController waterCtrl;

  @override
  void initState() {
    super.initState();
    stepCtrl = TextEditingController(text: widget.currentStepGoal.toString());
    waterCtrl = TextEditingController(text: widget.currentWaterGoal.toString());
  }

  @override
  void dispose() {
    stepCtrl.dispose();
    waterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        // transparent so we keep our custom glass look
        type: MaterialType.transparency,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55), // less see-through
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _fieldLabel("Daily Step Goal"),
                  _numberInput(stepCtrl),

                  const SizedBox(height: 16),

                  _fieldLabel("Daily Water Goal (ml)"),
                  _numberInput(waterCtrl),

                  const SizedBox(height: 26),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _dialogButton(
                        label: "Cancel",
                        onTap: () => Navigator.of(context).pop(null),
                      ),
                      _dialogButton(
                        label: "Save",
                        onTap: () {
                          final steps =
                              int.tryParse(stepCtrl.text) ??
                              widget.currentStepGoal;
                          final water =
                              int.tryParse(waterCtrl.text) ??
                              widget.currentWaterGoal;

                          Navigator.of(
                            context,
                          ).pop({"steps": steps, "water": water});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
      ),
    );
  }

  Widget _numberInput(TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _dialogButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
