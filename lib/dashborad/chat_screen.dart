// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class ChatScreen extends StatefulWidget {
//   final String userId;
//   final String name;
//   final String email;
//
//   const ChatScreen({
//     required this.userId,
//     required this.name,
//     required this.email,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseDatabase _db = FirebaseDatabase.instance;
//   final ScrollController _scrollController = ScrollController();
//
//   late String _chatId;
//   List<Map<String, dynamic>> _messages = [];
//
//   @override
//   void initState() {
//     super.initState();
//     final currentUser = _auth.currentUser;
//     if (currentUser != null) {
//       _chatId = _generateChatId(currentUser.uid, widget.userId);
//       _listenForMessages();
//     }
//   }
//
//   String _generateChatId(String uid1, String uid2) {
//     return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
//   }
//
//   void _listenForMessages() {
//     _db.ref("chats/$_chatId").orderByChild("timestamp").onValue.listen((event) {
//       final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
//       final messages = data.entries.map((entry) {
//         final msg = Map<String, dynamic>.from(entry.value);
//         return {
//           'senderId': msg['senderId'],
//           'text': msg['text'],
//           'timestamp': msg['timestamp'] ?? 0,
//           'type': msg['type'] ?? 'text',
//         };
//       }).toList();
//       messages.sort(
//           (a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));
//       setState(() => _messages = messages);
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollController.hasClients) {
//           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//         }
//       });
//     });
//   }
//
//   void _sendMessage({String? text, String type = 'text'}) async {
//     final currentUser = _auth.currentUser;
//     if (currentUser != null && (text?.trim().isNotEmpty ?? false)) {
//       final messageRef = _db.ref("chats/$_chatId").push();
//       await messageRef.set({
//         'senderId': currentUser.uid,
//         'text': text,
//         'type': type,
//         'timestamp': ServerValue.timestamp,
//       });
//       _messageController.clear();
//     }
//   }
//
//   Future<void> _sendImage() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       final file = File(picked.path);
//       final fileName = DateTime.now().millisecondsSinceEpoch.toString();
//       final ref =
//           FirebaseStorage.instance.ref().child('chat_images/$fileName.jpg');
//
//       await ref.putFile(file);
//       final downloadUrl = await ref.getDownloadURL();
//
//       _sendMessage(text: downloadUrl, type: 'image');
//     }
//   }
//
//   Future<void> _sendVideo() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickVideo(source: ImageSource.gallery);
//     if (picked != null) {
//       final file = File(picked.path);
//       final fileName = DateTime.now().millisecondsSinceEpoch.toString();
//       final ref =
//           FirebaseStorage.instance.ref().child('chat_videos/$fileName.mp4');
//
//       await ref.putFile(file);
//       final downloadUrl = await ref.getDownloadURL();
//
//       _sendMessage(text: downloadUrl, type: 'video');
//     }
//   }
//
//   Future<void> _sendAudio() async {
//     final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom, allowedExtensions: ['mp3', 'wav', 'm4a']);
//     if (result != null && result.files.single.path != null) {
//       final file = File(result.files.single.path!);
//       final fileName = DateTime.now().millisecondsSinceEpoch.toString();
//       final ref = FirebaseStorage.instance
//           .ref()
//           .child('chat_audios/$fileName.${result.files.single.extension}');
//
//       await ref.putFile(file);
//       final downloadUrl = await ref.getDownloadURL();
//
//       _sendMessage(text: downloadUrl, type: 'audio');
//     }
//   }
//
//   Future<void> _sendLocation() async {
//     var permission = await Permission.location.request();
//     if (permission.isGranted) {
//       Position pos = await Geolocator.getCurrentPosition();
//       String location = 'Lat: ${pos.latitude}, Lng: ${pos.longitude}';
//       _sendMessage(text: location, type: 'location');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.name)),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[index];
//                 final isMe = message['senderId'] == _auth.currentUser?.uid;
//                 return Align(
//                   alignment:
//                       isMe ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.all(6),
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: isMe ? Colors.blue : Colors.grey,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: _buildMessageContent(message),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Row(
//             children: [
//               IconButton(icon: const Icon(Icons.image), onPressed: _sendImage),
//               IconButton(
//                   icon: const Icon(Icons.videocam), onPressed: _sendVideo),
//               IconButton(
//                   icon: const Icon(Icons.audiotrack), onPressed: _sendAudio),
//               IconButton(
//                   icon: const Icon(Icons.location_on),
//                   onPressed: _sendLocation),
//               Expanded(
//                 child: TextField(
//                   controller: _messageController,
//                   decoration:
//                       const InputDecoration(hintText: 'Type a message...'),
//                 ),
//               ),
//               IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () {
//                     _sendMessage(text: _messageController.text);
//                   }),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessageContent(Map<String, dynamic> message) {
//     switch (message['type']) {
//       case 'image':
//         return Image.network(message['text'], width: 150,
//             errorBuilder: (context, error, stackTrace) {
//           return const Text('[Image failed to load]');
//         });
//       case 'video':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('[Video]'),
//             InkWell(
//               child: Text(message['text'],
//                   style: const TextStyle(
//                       color: Colors.blue,
//                       decoration: TextDecoration.underline)),
//               onTap: () => launchUrl(Uri.parse(message['text'])),
//             ),
//           ],
//         );
//
//       case 'audio':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('[Audio]'),
//             InkWell(
//               child: Text(message['text'],
//                   style: const TextStyle(
//                       color: Colors.blue,
//                       decoration: TextDecoration.underline)),
//               onTap: () => launchUrl(Uri.parse(message['text'])),
//             ),
//           ],
//         );
//
//       case 'location':
//         return Text('[Location] ${message['text']}');
//       default:
//         return Text(message['text'] ?? '',
//             style: const TextStyle(color: Colors.white));
//     }
//   }
// }
//
// // // lib/screens/chat_screen.dart
// //
// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:firebase_database/firebase_database.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'package:firebase_storage/firebase_storage.dart';
// //
// // Future<void> _pickAndSendFile() async {
// //   final result = await FilePicker.platform.pickFiles(type: FileType.any);
// //   if (result != null && result.files.single.path != null) {
// //     final file = result.files.single;
// //     final ext = file.extension ?? 'file';
// //     String mediaType = 'none';
// //
// //     if (['jpg', 'jpeg', 'png'].contains(ext)) mediaType = 'image';
// //     else if (['mp3', 'wav'].contains(ext)) mediaType = 'audio';
// //     else if (['mp4', 'mov'].contains(ext)) mediaType = 'video';
// //
// //     final storageRef = FirebaseStorage.instance
// //         .ref()
// //         .child('chat_media/$_chatId/${DateTime.now().millisecondsSinceEpoch}.$ext');
// //
// //     final uploadTask = await storageRef.putData(file.bytes!);
// //     final downloadUrl = await uploadTask.ref.getDownloadURL();
// //
// //     final currentUser = _auth.currentUser;
// //     if (currentUser != null) {
// //       final messageRef = _db.ref("chats/$_chatId").push();
// //       await messageRef.set({
// //         'senderId': currentUser.uid,
// //         'text': '',
// //         'mediaUrl': downloadUrl,
// //         'mediaType': mediaType,
// //         'timestamp': ServerValue.timestamp,
// //       });
// //     }
// //   }
// // }
// //
// //
// // class ChatScreen extends StatefulWidget {
// //   final String userId;
// //   final String name;
// //   final String email;
// //
// //   const ChatScreen({
// //     required this.userId,
// //     required this.name,
// //     required this.email,
// //     Key? key,
// //   }) : super(key: key);
// //
// //   @override
// //   State<ChatScreen> createState() => _ChatScreenState();
// // }
// //
// // class _ChatScreenState extends State<ChatScreen> {
// //   final TextEditingController _messageController = TextEditingController();
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final FirebaseDatabase _db = FirebaseDatabase.instance;
// //
// //   final ScrollController _scrollController = ScrollController();
// //
// //   late String _chatId;
// //   List<Map<String, dynamic>> _messages = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     final currentUser = _auth.currentUser;
// //     if (currentUser != null) {
// //       _chatId = _generateChatId(currentUser.uid, widget.userId);
// //       _listenForMessages();
// //     }
// //   }
// //
// //   String _generateChatId(String uid1, String uid2) {
// //     return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
// //   }
// //
// //   void _listenForMessages() {
// //     _db.ref("chats/$_chatId").orderByChild("timestamp").onValue.listen((event) {
// //       final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
// //       final messages = data.entries.map((entry) {
// //         final msg = Map<String, dynamic>.from(entry.value);
// //         return {
// //           'senderId': msg['senderId'],
// //           'text': msg['text'],
// //           'timestamp': msg['timestamp'] ?? 0,
// //         };
// //       }).toList();
// //
// //       // Sort messages by timestamp (just to be extra sure)
// //       messages.sort(
// //           (a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));
// //
// //       setState(() {
// //         _messages = messages;
// //       });
// //
// //       // Auto-scroll to the bottom
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         if (_scrollController.hasClients) {
// //           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
// //         }
// //       });
// //     });
// //   }
// //
// //   void _sendMessage() async {
// //     final currentUser = _auth.currentUser;
// //     if (currentUser != null && _messageController.text.trim().isNotEmpty) {
// //       final messageRef = _db.ref("chats/$_chatId").push();
// //       await messageRef.set({
// //         'senderId': currentUser.uid,
// //         'text': _messageController.text.trim(),
// //         'timestamp': ServerValue.timestamp,
// //       });
// //
// //       _messageController.clear();
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text(widget.name)),
// //       body: Column(
// //         children: [
// //           Expanded(
// //             child: ListView.builder(
// //               controller: _scrollController,
// //               itemCount: _messages.length,
// //               itemBuilder: (context, index) {
// //                 final message = _messages[index];
// //                 final isMe = message['senderId'] == _auth.currentUser?.uid;
// //                 return Align(
// //                   alignment:
// //                       isMe ? Alignment.centerRight : Alignment.centerLeft,
// //                   child: Container(
// //                     padding: const EdgeInsets.all(10),
// //                     margin: const EdgeInsets.all(5),
// //                     decoration: BoxDecoration(
// //                       color: isMe ? Colors.blue : Colors.grey,
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: Text(
// //                       message['text'] ?? '',
// //                       style: const TextStyle(color: Colors.white),
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //           Row(
// //             children: [
// //               IconButton(
// //                 icon: const Icon(Icons.attach_file),
// //                 onPressed: _pickAndSendFile,
// //               ),
// //               Expanded(
// //                 child: TextField(
// //                   controller: _messageController,
// //                   decoration: const InputDecoration(
// //                     hintText: 'Type a message...',
// //                     contentPadding: EdgeInsets.symmetric(horizontal: 12),
// //                   ),
// //                 ),
// //               ),
// //               IconButton(
// //                 onPressed: _sendMessage,
// //                 icon: const Icon(Icons.send),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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
      print("auth");
      _chatId = _generateChatId(currentUser.uid, widget.userId);
      _listenForMessages();
    }
  }

  String _generateChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  void _listenForMessages() {
    _db.ref("chats/$_chatId").orderByChild("timestamp").onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final messages = data.entries.map((entry) {
        final msg = Map<String, dynamic>.from(entry.value);
        return {
          'senderId': msg['senderId'],
          'text': msg['text'] ?? '',
          'timestamp': msg['timestamp'] ?? 0,
          'type': msg['type'] ?? 'text',
        };
      }).toList();
      messages.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));
      setState(() => _messages = messages);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  void _sendMessage({String? text, String type = 'text'}) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && (text?.trim().isNotEmpty ?? false)) {
      final messageRef = _db.ref("chats/$_chatId").push();
      await messageRef.set({
        'senderId': currentUser.uid,
        'text': text,
        'type': type,
        'timestamp': ServerValue.timestamp,
      });
      _messageController.clear();
    }
  }

  Future<void> _sendMedia(FileType fileType, List<String> allowedExtensions, String folder, String mediaType) async {
    final result = await FilePicker.platform.pickFiles(type: fileType, allowedExtensions: allowedExtensions);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('$folder/$fileName.${result.files.single.extension}');
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      _sendMessage(text: downloadUrl, type: mediaType);
    }
  }

  Future<void> _sendLocation() async {
    var permission = await Permission.location.request();
    if (permission.isGranted) {
      Position pos = await Geolocator.getCurrentPosition();
      String location = 'Lat: ${pos.latitude}, Lng: ${pos.longitude}';
      _sendMessage(text: location, type: 'location');
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
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildMessageContent(message),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () => _sendMedia(FileType.image, ['jpg', 'jpeg', 'png'], 'chat_images', 'image')),
              IconButton(
                  icon: const Icon(Icons.videocam),
                  onPressed: () => _sendMedia(FileType.video, ['mp4', 'mov'], 'chat_videos', 'video')),
              IconButton(
                  icon: const Icon(Icons.audiotrack),
                  onPressed: () => _sendMedia(FileType.custom, ['mp3', 'wav', 'm4a'], 'chat_audios', 'audio')),
              IconButton(icon: const Icon(Icons.location_on), onPressed: _sendLocation),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(hintText: 'Type a message...'),
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(text: _messageController.text)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'image':
        return Image.network(message['text'], width: 150, errorBuilder: (context, error, stackTrace) => const Text('[Image failed to load]'));
      case 'video':
        return _mediaLinkWidget('[Video]', message['text']);
      case 'audio':
        return _mediaLinkWidget('[Audio]', message['text']);
      case 'location':
        return Text('[Location] ${message['text']}');
      default:
        return Text(message['text'] ?? '', style: const TextStyle(color: Colors.white));
    }
  }

  Widget _mediaLinkWidget(String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        InkWell(
          child: Text(url, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
          onTap: () => launchUrl(Uri.parse(url)),
        ),
      ],
    );
  }
}
