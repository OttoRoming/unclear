import 'package:cloud_firestore/cloud_firestore.dart';

class UserSearchResult {
  final String id;
  final String username;

  UserSearchResult({required this.id, required this.username});
}

class UserService {
  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> saveUsername(String uid, String username) {
    final trimmed = username.trim();
    return _users.doc(uid).set({
      'username': trimmed,
      'usernameLower': trimmed.toLowerCase(),
    });
  }

  Future<List<UserSearchResult>> searchUsername(String query) async {
    // https://stackoverflow.com/questions/68224256/how-to-search-text-in-flutter-using-firestore
    final result = await _users
        .where(
          "usernameLower",
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                    String.fromCharCode(query.codeUnitAt(query.length - 1) + 1),
        )
        .get();

    return result.docs.map((doc) {
      return UserSearchResult(
        id: doc.id,
        username: doc.data()['username'] ?? '',
      );
    }).toList();
  }
}
