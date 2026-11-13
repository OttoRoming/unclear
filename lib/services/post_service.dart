import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String message;
  final String drink;
  final bool likedByMe;
  final int likeCount;

  Post({
    required this.id,
    required this.message,
    required this.drink,
    this.likedByMe = false,
    this.likeCount = 0,
  });
}

class PostService {
  PostService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('posts');

  CollectionReference<Map<String, dynamic>> get _likes =>
      _firestore.collection('likes');

  Future<void> createPost({required String message, required String drink}) {
    return _posts.add({'message': message.trim(), 'drink': drink.trim()});
  }

  Future<void> setLiked({
    required String uid,
    required String postId,
    required bool liked,
  }) {
    final ref = _likes.doc('${uid}_$postId');
    return liked ? ref.set({'byUser': uid, 'post': postId}) : ref.delete();
  }

  Stream<List<Post>> streamPosts(String uid) {
    // Combine the two streams
    return Stream.multi((controller) {
      List<Post>? posts;
      Map<String, int> likeCounts = {};
      Set<String> likedByMe = {};

      void emit() {
        final currentPosts = posts;
        if (currentPosts == null) {
          return;
        }

        controller.add([
          for (final post in currentPosts)
            Post(
              id: post.id,
              message: post.message,
              drink: post.drink,
              likedByMe: likedByMe.contains(post.id),
              likeCount: likeCounts[post.id] ?? 0,
            ),
        ]);
      }

      final postsSub = _posts.snapshots().listen((snapshot) {
        posts = snapshot.docs.map((doc) {
          return Post(
            id: doc.id,
            message: doc.data()['message'] ?? '',
            drink: doc.data()['drink'] ?? '',
          );
        }).toList();
        emit();
      }, onError: controller.addError);

      final likesSub = _likes.snapshots().listen((snapshot) {
        final Map<String, int> counts = {};
        final Set<String> liked = {};

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final postId = data['post'];
          if (postId is! String) {
            continue;
          }

          counts[postId] = (counts[postId] ?? 0) + 1;
          if (data['byUser'] == uid) {
            liked.add(postId);
          }
        }

        likeCounts = counts;
        likedByMe = liked;
        emit();
      }, onError: controller.addError);

      controller.onCancel = () async {
        await postsSub.cancel();
        await likesSub.cancel();
      };
    });
  }
}
