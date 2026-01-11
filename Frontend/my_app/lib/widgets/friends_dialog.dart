import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_app/services/api_service.dart';

// ✅ Add this import (adjust path if your folder structure differs)
import 'package:my_app/pages/room_page.dart';

enum FriendsTab { friends, requests, add }

class FriendsDialog extends StatefulWidget {
  final int userId;

  const FriendsDialog({super.key, required this.userId});

  @override
  State<FriendsDialog> createState() => _FriendsDialogState();
}

class _FriendsDialogState extends State<FriendsDialog>
    with SingleTickerProviderStateMixin {
  final ApiService api = ApiService();

  FriendsTab currentTab = FriendsTab.friends;

  late Future<List<Map<String, dynamic>>> friendsFuture;
  late Future<List<Map<String, dynamic>>> requestsFuture;

  final TextEditingController addFriendCtrl = TextEditingController();
  bool isSending = false;

  // ✅ Frontend-only feedback (no backend changes needed)
  String? _sendStatus;
  bool _sendOk = false;

  // 🔹 Animation
  late final AnimationController _animCtrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _refreshAll();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..forward();

    _fade = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
    );

    _scale = Tween<double>(begin: 0.98, end: 1.0).animate(_fade);
  }

  void _refreshAll() {
    friendsFuture = api.getFriends(widget.userId);
    requestsFuture = api.getIncomingFriendRequests(widget.userId);
    setState(() {});
  }

  @override
  void dispose() {
    addFriendCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _visitFriendRoom(int friendId, String friendUsername) {
    // Close dialog first so it doesn't sit "behind" the next page
    Navigator.of(context).pop();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MyRoomPage(
          userId: friendId, // ✅ room owner id
          viewerUserId: widget.userId, // ✅ viewer id (you)
          roomOwnerUsername: friendUsername, // ✅ banner text
        ),
      ),
    );
  }

  Future<bool> _confirmRemove(String username) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF6F0E8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Remove friend?"),
        content: Text('Remove "$username" from your friends list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text("Remove"),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Center(
          child: Material(
            type: MaterialType.transparency,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  width: 620,
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F0E8).withOpacity(0.94),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 30,
                        offset: const Offset(0, 18),
                        color: Colors.black.withOpacity(0.25),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _header(context),
                      const SizedBox(height: 12),
                      _tabs(),
                      const SizedBox(height: 14),
                      SizedBox(height: 220, child: _buildTab()),
                      const SizedBox(height: 14),
                      _footer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _header(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const Icon(Icons.people_alt_outlined, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Friends",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _subtitleForTab(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          splashRadius: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  String _subtitleForTab() {
    switch (currentTab) {
      case FriendsTab.friends:
        return "People who can visit your space.";
      case FriendsTab.requests:
        return "Invitations waiting at your door.";
      case FriendsTab.add:
        return "Send an invite by username.";
    }
  }

  // TABS
  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: FriendsTab.values.map((tab) {
          final active = currentTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  currentTab = tab;
                  if (tab != FriendsTab.add) _sendStatus = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tab.name[0].toUpperCase() + tab.name.substring(1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.black87,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // BODY
  Widget _buildTab() {
    switch (currentTab) {
      case FriendsTab.friends:
        return _friendsList();
      case FriendsTab.requests:
        return _requestsList();
      case FriendsTab.add:
        return _addFriend();
    }
  }

  Widget _friendsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: friendsFuture,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.data!.isEmpty) {
          return _emptyState(
            Icons.person_outline,
            "No friends yet",
            "Add a friend and their presence will show up here.",
          );
        }

        return ListView(
          children: snap.data!.map((f) {
            final friendId = f["id"];
            final friendUsername = (f["username"] ?? "").toString();

            final canUseId = friendId is int;

            return _friendRow(
              username: friendUsername,
              onVisit: canUseId ? () => _visitFriendRoom(friendId, friendUsername) : null,
              onRemove: canUseId
                  ? () async {
                      final ok = await _confirmRemove(friendUsername);
                      if (!ok) return;
                      await api.removeFriend(widget.userId, friendId);
                      _refreshAll();
                    }
                  : null,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _requestsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: requestsFuture,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.data!.isEmpty) {
          return _emptyState(
            Icons.mark_email_read_outlined,
            "No requests",
            "When someone adds you, their request will appear here.",
          );
        }

        return ListView(
          children: snap.data!.map((r) {
            return _row(
              title: (r["requester_username"] ?? "").toString(),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () async {
                      await api.acceptFriendRequest(
                        widget.userId,
                        r["requester_id"],
                      );
                      _refreshAll();
                    },
                    child: const Text("Accept"),
                  ),
                  TextButton(
                    onPressed: () async {
                      await api.rejectFriendRequest(
                        widget.userId,
                        r["requester_id"],
                      );
                      _refreshAll();
                    },
                    child: const Text("Reject"),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _addFriend() {
    return Column(
      children: [
        _input(),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: isSending
                ? null
                : () async {
                    final username = addFriendCtrl.text.trim();
                    if (username.isEmpty) {
                      setState(() {
                        _sendOk = false;
                        _sendStatus = "Enter a username first.";
                      });
                      return;
                    }

                    setState(() {
                      isSending = true;
                      _sendStatus = null;
                    });

                    final ok =
                        await api.sendFriendRequest(widget.userId, username);

                    if (!mounted) return;

                    setState(() {
                      isSending = false;
                      _sendOk = ok;
                      _sendStatus = ok
                          ? 'Invite sent to "$username".'
                          : 'Couldn’t send invite. Double-check the username.';
                    });

                    if (ok) {
                      addFriendCtrl.clear();
                      _refreshAll();
                      setState(() => currentTab = FriendsTab.requests);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(146, 202, 170, 1),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(isSending ? "Sending..." : "Send invite"),
          ),
        ),
        if (_sendStatus != null) ...[
          const SizedBox(height: 10),
          Text(
            _sendStatus!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _sendOk
                  ? Colors.black.withOpacity(0.70)
                  : Colors.redAccent.withOpacity(0.85),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          "Tip: usernames are case-sensitive.",
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _input() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.12)),
      ),
      child: TextField(
        controller: addFriendCtrl,
        onChanged: (_) {
          if (_sendStatus != null) setState(() => _sendStatus = null);
        },
        decoration: const InputDecoration(
          hintText: "Username",
          border: InputBorder.none,
        ),
      ),
    );
  }

  // --- NEW: nicer friend bar row ---
  Widget _friendRow({
    required String username,
    VoidCallback? onVisit,
    VoidCallback? onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              username,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF1F1F1F),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Visit = primary pill
          _pillButton(
            label: "Visit",
            icon: Icons.open_in_new_rounded,
            onTap: onVisit,
            filled: true,
          ),
          const SizedBox(width: 8),

          // Remove = icon-only destructive (with confirmation outside)
          _iconDangerButton(
            icon: Icons.close_rounded,
            tooltip: "Remove",
            onTap: onRemove,
          ),
        ],
      ),
    );
  }

  Widget _pillButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    bool filled = false,
  }) {
    final disabled = onTap == null;

    final bg = filled
        ? const Color.fromRGBO(146, 202, 170, 1)
        : Colors.white.withOpacity(0.55);

    final border = filled ? Colors.transparent : Colors.black.withOpacity(0.10);

    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
            boxShadow: filled
                ? [
                    BoxShadow(
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                      color: Colors.black.withOpacity(0.10),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.black.withOpacity(0.85)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconDangerButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
  }) {
    final disabled = onTap == null;

    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.45),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.redAccent.withOpacity(0.25)),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.redAccent.withOpacity(0.85),
            ),
          ),
        ),
      ),
    );
  }
  // --- end new friend bar row ---

  // Existing generic row (used for requests tab)
  Widget _row({required String title, required Widget trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _emptyState(IconData icon, String title, String subtitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 32, color: Colors.black45),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _footer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: _refreshAll,
          icon: const Icon(Icons.refresh),
          label: const Text("Refresh"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(146, 202, 170, 1),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
