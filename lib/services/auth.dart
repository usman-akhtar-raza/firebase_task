import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../auth/login.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _db = FirebaseDatabase.instance;
  Future<User?> signUp(String email, String password, String name, BuildContext context) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      if (credential.user != null) {
        // Save additional user data in Realtime Database
        await _db
            .ref()
            .child('Users')
            .child(credential.user!.uid)
            .set({
          'uid': credential.user!.uid,
          'name': name,
          'email': email,
        });

        // Ensure navigation happens after the user is fully created
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()), // This takes you to the Login screen
        );
      }
      return credential.user;
    } catch (e) {
      print("Signup Error: $e");
      return null;
    }
  }


  Future<User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return credential.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
