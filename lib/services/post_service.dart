import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String message;
  final String drink;

  Post({required this.id, required this.message, required this.drink});
}

/// Thin wrapper around the `posts` collection in Firestore.
class PostService {
  PostService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('posts');

  Future<void> createPost({required String message, required String drink}) {
    return _posts.add({'message': message.trim(), 'drink': drink.trim()});
  }

  Future<List<Post>> fetchPosts() async {
    final result = await _posts.get();

    return result.docs.map((doc) {
      return Post(
        id: doc.id,
        message: doc.data()['message'] ?? '',
        drink: doc.data()['drink'] ?? '',
      );
    }).toList();
  }
}
