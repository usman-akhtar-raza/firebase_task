// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String email;

  const ChatScreen({
    required this.userId,
    required this.name,
    required this.email,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  final ScrollController _scrollController = ScrollController();

  late String _chatId;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _chatId = _generateChatId(currentUser.uid, widget.userId);
      _listenForMessages();
    }
  }

  String _generateChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  void _listenForMessages() {
    _db
        .ref("chats/$_chatId")
        .orderByChild("timestamp")
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final messages = data.entries.map((entry) {
        final msg = Map<String, dynamic>.from(entry.value);
        return {
          'senderId': msg['senderId'],
          'text': msg['text'],
          'timestamp': msg['timestamp'] ?? 0,
        };
      }).toList();

      // Sort messages by timestamp (just to be extra sure)
      messages.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));

      setState(() {
        _messages = messages;
      });

      // Auto-scroll to the bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  void _sendMessage() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && _messageController.text.trim().isNotEmpty) {
      final messageRef = _db.ref("chats/$_chatId").push();
      await messageRef.set({
        'senderId': currentUser.uid,
        'text': _messageController.text.trim(),
        'timestamp': ServerValue.timestamp,
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['senderId'] == _auth.currentUser?.uid;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
