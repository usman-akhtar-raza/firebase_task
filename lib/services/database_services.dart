import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> createUser(String uid, String email) async {
    await _db.child('users').child(uid).set({'email': email});
  }

  Future<List<Map<String, String>>> getAllUsers(String uid) async {
    final snapshot = await _db.child('users').get();
    final users = <Map<String, String>>[];
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((key, value) {
        users.add({'uid': key, 'email': value['email']});
      });
    }
    return users;
  }

  Stream<DatabaseEvent> getMessages(String chatId) {
    return _db.child('messages').child(chatId).onValue;
  }

  Future<void> sendMessage(String chatId, String senderId, String message) async {
    final msgRef = _db.child('messages').child(chatId).push();
    await msgRef.set({
      'senderId': senderId,
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
