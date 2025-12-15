import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_app/services/api_service.dart';

enum FriendsTab { friends, requests, add }

class FriendsDialog extends StatefulWidget {
  final int userId;

  const FriendsDialog({super.key, required this.userId});

  @override
  State<FriendsDialog> createState() => _FriendsDialogState();
}

class _FriendsDialogState extends State<FriendsDialog> {
  final ApiService api = ApiService();

  FriendsTab currentTab = FriendsTab.friends;

  late Future<List<Map<String, dynamic>>> friendsFuture;
  late Future<List<Map<String, dynamic>>> requestsFuture;

  final TextEditingController addFriendCtrl = TextEditingController();
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  void _refreshAll() {
    friendsFuture = api.getFriends(widget.userId);
    requestsFuture = api.getIncomingFriendRequests(widget.userId);
    setState(() {});
  }

  @override
  void dispose() {
    addFriendCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Friends",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _tabBar(),
                  const SizedBox(height: 16),
                  SizedBox(height: 200, child: _buildTab()),
                  const SizedBox(height: 16),
                  _closeButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // TABS
  Widget _tabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _tabButton("Friends", FriendsTab.friends),
        _tabButton("Requests", FriendsTab.requests),
        _tabButton("Add", FriendsTab.add),
      ],
    );
  }

  Widget _tabButton(String label, FriendsTab tab) {
    final isActive = currentTab == tab;

    return GestureDetector(
      onTap: () => setState(() => currentTab = tab),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white54,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

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

  // FRIENDS LIST
  Widget _friendsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: friendsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final friends = snapshot.data!;
        if (friends.isEmpty) {
          return const Center(
            child: Text(
              "No friends yet",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, i) {
            final friend = friends[i];
            final username = friend['username'];
            final friendId = friend['id'];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: _glassBox(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// FRIEND ROW (tap prints)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        print("Tapped friend: $username");
                      },
                      child: Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  /// REMOVE BUTTON
                  GestureDetector(
                    onTap: () async {
                      await api.removeFriend(widget.userId, friendId);
                      _refreshAll();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.redAccent.withOpacity(0.4),
                        ),
                      ),
                      child: const Text(
                        "Remove",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // FRIEND REQUESTS
  Widget _requestsList() {
    return FutureBuilder(
      future: requestsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final requests = snapshot.data!;
        if (requests.isEmpty) {
          return const Center(
            child: Text("No requests", style: TextStyle(color: Colors.white70)),
          );
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, i) {
            final req = requests[i];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: _glassBox(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    req['requester_username'],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _actionButton("Accept", () async {
                        await api.acceptFriendRequest(
                          widget.userId,
                          req['requester_id'],
                        );
                        _refreshAll();
                      }),
                      const SizedBox(width: 10),
                      _actionButton("Reject", () async {
                        await api.rejectFriendRequest(
                          widget.userId,
                          req['requester_id'],
                        );
                        _refreshAll();
                      }),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ADD FRIEND
  Widget _addFriend() {
    return Column(
      children: [
        _input(addFriendCtrl, "Username"),
        const SizedBox(height: 14),
        _actionButton(
          isSending ? "Sending..." : "Send Request",
          isSending
              ? null
              : () async {
                  setState(() => isSending = true);
                  await api.sendFriendRequest(
                    widget.userId,
                    addFriendCtrl.text.trim(),
                  );
                  addFriendCtrl.clear();
                  setState(() => isSending = false);
                },
        ),
      ],
    );
  }

  Widget _input(TextEditingController ctrl, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _glassBox(),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _actionButton(String text, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: _glassBox(),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _closeButton() {
    return _actionButton("Close", () => Navigator.of(context).pop());
  }

  BoxDecoration _glassBox() => BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      );
}
