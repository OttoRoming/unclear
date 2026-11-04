import 'package:cloud_firestore/cloud_firestore.dart';

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
}
