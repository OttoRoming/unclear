import 'package:flutter/material.dart';
import '../services/post_service.dart';

class Feed extends StatefulWidget {
  const Feed({super.key, required this.userId, this.postService});

  final String userId;
  final PostService? postService;

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  late final PostService _postService = widget.postService ?? PostService();
  late final Stream<List<Post>> _postsStream = _postService.streamPosts(
    widget.userId,
  );

  Future<void> _toggleLike(Post post) async {
    try {
      await _postService.setLiked(
        uid: widget.userId,
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
