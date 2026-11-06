import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/app_bar.dart';
import '../widgets/navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.authService});

  final AuthService authService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;

  Future<void> _signOut(BuildContext context) async {
    try {
      await widget.authService.signOut();
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
      stream: widget.authService.userChanges,
      builder: (context, snapshot) {
        final user = snapshot.data ?? widget.authService.currentUser;
        final displayName = user?.displayName?.trim();
        final greetingName = (displayName == null || displayName.isEmpty)
            ? 'there'
            : displayName;
        final theme = Theme.of(context);

        return Scaffold(
          appBar: UnclearAppBar(onSignOut: () => _signOut(context)),
          body: _currentPageIndex == 0
              ? Center(
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
                )
              : _currentPageIndex == 1
              ? const Placeholder()
              : const Placeholder(),
          bottomNavigationBar: UnclearNavigationBar(
            selectedIndex: _currentPageIndex,
            onDestinationSelected: (index) =>
                setState(() => _currentPageIndex = index),
          ),
        );
      },
    );
  }
}
