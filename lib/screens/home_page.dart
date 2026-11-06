import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/post_service.dart';
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

  final _postService = PostService();
  final _postFormKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _drinkController = TextEditingController();

  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final posts = await _postService.fetchPosts();
    if (mounted) {
      setState(() => _posts = posts);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _drinkController.dispose();
    super.dispose();
  }

  String? _validateMessage(String? value) {
    final message = value?.trim() ?? '';
    if (message.isEmpty) {
      return 'Enter a message.';
    }
    return null;
  }

  String? _validateDrink(String? value) {
    final drink = value?.trim() ?? '';
    if (drink.isEmpty) {
      return 'Enter a drink.';
    }
    return null;
  }

  Future<void> _onPostPressed() async {
    if (!_postFormKey.currentState!.validate()) {
      return;
    }

    await _postService.createPost(
      message: _messageController.text.trim(),
      drink: _drinkController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    _messageController.clear();
    _drinkController.clear();
    setState(() => _currentPageIndex = 0);
    await _loadPosts();
  }

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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: () => _signOut(context),
                              icon: const Icon(Icons.logout),
                              label: const Text('Sign out'),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Latest posts',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          if (_posts.isEmpty)
                            const Text('No posts yet.')
                          else
                            for (final post in _posts)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text('${post.message} - ${post.drink}'),
                              ),
                        ],
                      ),
                    ),
                  ),
                )
              : _currentPageIndex == 1
              ? SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Form(
                          key: _postFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _messageController,
                                decoration: const InputDecoration(
                                  labelText: 'Message',
                                  alignLabelWithHint: true,
                                ),
                                minLines: 3,
                                maxLines: 5,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                validator: _validateMessage,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _drinkController,
                                decoration: const InputDecoration(
                                  labelText: 'Drink',
                                ),
                                textInputAction: TextInputAction.done,
                                validator: _validateDrink,
                                onFieldSubmitted: (_) => _onPostPressed(),
                              ),
                              const SizedBox(height: 24),
                              FilledButton.icon(
                                onPressed: _onPostPressed,
                                icon: const Icon(Icons.send),
                                label: const Text('Post'),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const Placeholder(),
          bottomNavigationBar: UnclearNavigationBar(
            selectedIndex: _currentPageIndex,
            onDestinationSelected: (index) {
              setState(() => _currentPageIndex = index);
              if (index == 0) {
                _loadPosts();
              }
            },
          ),
        );
      },
    );
  }
}
