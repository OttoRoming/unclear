import 'package:flutter/widgets.dart';
import '../services/post_service.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final _postService = PostService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _postService.streamPosts(),
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final post in posts)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${post.message} - ${post.drink}'),
              ),
          ],
        );
      },
    );
  }
}
