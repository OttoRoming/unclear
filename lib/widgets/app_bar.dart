import 'package:flutter/material.dart';

/// The application's shared top bar.
class UnclearAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UnclearAppBar({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.colorScheme.inversePrimary,
      title: const Text('Unclear'),
      actions: [
        IconButton(
          onPressed: onSignOut,
          icon: const Icon(Icons.logout),
          tooltip: 'Sign out',
        ),
      ],
    );
  }
}
