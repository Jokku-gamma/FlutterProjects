import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';

class ChatScreen extends StatelessWidget {
  final _messageController = TextEditingController();

  ChatScreen({super.key});

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('messages').add({
      'text': _messageController.text.trim(),
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'userEmail': user.email,
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet.'));
                }
                for (var doc in snapshot.data!.docs) {
                  if (doc['userId'] != FirebaseAuth.instance.currentUser!.uid) {
                    showNotification(
                      doc['userEmail'],
                      doc['text'],
                    );
                  }
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data!.docs[index];
                    bool isMe = message['userId'] == FirebaseAuth.instance.currentUser!.uid;
                    return ListTile(
                      title: Text(message['userEmail']),
                      subtitle: Text(message['text']),
                      trailing: isMe ? Icon(Icons.person) : null,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}