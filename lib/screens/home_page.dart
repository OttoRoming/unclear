import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.authService});

  final AuthService authService;

  Future<void> _signOut(BuildContext context) async {
    try {
      await authService.signOut();
    } on FirebaseAuthException catch (exception) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authErrorMessage(exception))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.userChanges,
      builder: (context, snapshot) {
        final user = snapshot.data ?? authService.currentUser;
        final displayName = user?.displayName?.trim();
        final greetingName = (displayName == null || displayName.isEmpty)
            ? 'there'
            : displayName;
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: theme.colorScheme.inversePrimary,
            title: const Text('Unclear'),
            actions: [
              IconButton(
                onPressed: () => _signOut(context),
                icon: const Icon(Icons.logout),
                tooltip: 'Sign out',
              ),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome, $greetingName!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    if (user?.email != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        user!.email!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: () => _signOut(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
