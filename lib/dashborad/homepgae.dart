import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../auth/login.dart';

import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('Users');
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchUsers();  // Fetch users data when user is authenticated
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),  // Redirect to login if not authenticated
        );
      }
    });
  }

  // Fetch users from Firebase Realtime Database
  fetchUsers() async {
    try {
      final snapshot = await _dbRef.get();  // Fetch data once
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          final currentUser = _auth.currentUser;
          final List<Map<String, dynamic>> loadedUsers = [];
          data.forEach((key, value) {
            if (currentUser != null && key != currentUser.uid) {
              loadedUsers.add({
                'uid': key,
                'name': value['name'] ?? '',
                'email': value['email'] ?? '',
              });
            }
          });

          setState(() {
            users = loadedUsers;
            isLoading = false;
          });
        } else {
          setState(() {
            users = [];
            errorMessage = 'No data found.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          users = [];
          errorMessage = 'No data available';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching data: $e';
      });
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        actions: [
          IconButton(
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())  // Show loading indicator
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))  // Show error message
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(user['name']),
            subtitle: Text(user['email']),
            onTap: () {
              // When a user taps on a user, navigate to chat screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    userId: user['uid'],
                    name: user['name'],
                    email: user['email'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
