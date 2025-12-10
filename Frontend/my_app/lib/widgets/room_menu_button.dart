import 'package:flutter/material.dart';

class RoomMenuButton extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback onFriends;
  final VoidCallback onSettings;
  final VoidCallback onAchievements;

  const RoomMenuButton({
    super.key,
    required this.onLogout,
    required this.onFriends,
    required this.onSettings,
    required this.onAchievements,
  });

  @override
  State<RoomMenuButton> createState() => _RoomMenuButtonState();
}

class _RoomMenuButtonState extends State<RoomMenuButton> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // =============================
        //         MENU BUTTON
        // =============================
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.menu, color: Colors.white, size: 22),
          ),
        ),

        // Small gap between button and dropdown
        if (_open) const SizedBox(height: 8),

        // =============================
        //        DROPDOWN PANEL
        // =============================
        if (_open) _buildDropdown(),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      width: 190,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.60),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // text left-aligned
        mainAxisSize: MainAxisSize.min,
        children: [
          _menuItem("Achievements", Icons.emoji_events, widget.onAchievements),
          _menuItem("Friends", Icons.people, widget.onFriends),
          _menuItem("Settings", Icons.settings, widget.onSettings),
          _menuItem("Logout", Icons.logout, widget.onLogout),
        ],
      ),
    );
  }

  Widget _menuItem(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _open = false);
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.85), size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
