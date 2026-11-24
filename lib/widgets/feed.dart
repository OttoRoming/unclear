import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  late final _authService = AuthService();
  late final _postService = PostService();
  late final _userId = _authService.currentUser!.uid;

  late final Stream<List<Post>> _postsStream = _postService.streamPosts(
    _userId,
  );

  Future<void> _toggleLike(Post post) async {
    try {
      await _postService.setLiked(
        uid: _userId,
        postId: post.id,
        liked: !post.likedByMe,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not update like.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Post>>(
      stream: _postsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Could not load posts.");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading posts...");
        }

        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return Text("No posts yet.");
        }

        final theme = Theme.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final post in posts)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text('${post.message} - ${post.drink}')),
                    IconButton(
                      tooltip: post.likedByMe ? 'Unlike' : 'Like',
                      color: post.likedByMe ? theme.colorScheme.error : null,
                      icon: Icon(
                        post.likedByMe ? Icons.favorite : Icons.favorite_border,
                      ),
                      onPressed: () => _toggleLike(post),
                    ),
                    Text('${post.likeCount}'),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
