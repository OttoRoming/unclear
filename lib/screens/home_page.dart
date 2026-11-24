import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unclear/widgets/screen_friends.dart';

import '../services/auth_service.dart';
import '../widgets/app_bar.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/screen_explore.dart';
import '../widgets/screen_post.dart';

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
        return Scaffold(
          appBar: UnclearAppBar(onSignOut: () => _signOut(context)),
          body: _currentPageIndex == 0
              ? ScreenExplore()
              : _currentPageIndex == 1
              ? ScreenPost(
                  goToExplore: () {
                    setState(() {
                      _currentPageIndex = 0;
                    });
                  },
                )
              : _currentPageIndex == 2
              ? ScreenFriends()
              : const Placeholder(),
          bottomNavigationBar: UnclearNavigationBar(
            selectedIndex: _currentPageIndex,
            onDestinationSelected: (index) {
              setState(() => _currentPageIndex = index);
              if (index == 0) {
                // _loadPosts();
              }
            },
          ),
        );
      },
    );
  }
}
