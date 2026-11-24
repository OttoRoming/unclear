import 'package:flutter/material.dart';
import '../services/user_service.dart';

class ScreenFriends extends StatefulWidget {
  const ScreenFriends({super.key});

  @override
  State<ScreenFriends> createState() => _ScreenFriendsState();
}

class _ScreenFriendsState extends State<ScreenFriends> {
  final _userService = UserService();
  final _searchController = TextEditingController();
  List<UserSearchResult> _userResults = [];

  Future<void> _searchUsers() async {
    final users = await _userService.searchUsername(
      _searchController.text.trim(),
    );
    if (mounted) {
      setState(() => _userResults = users);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search username',
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchUsers(),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _searchUsers,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 24),
                for (final user in _userResults)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(user.username),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
