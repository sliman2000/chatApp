import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  _sendMessage() async {
    final _enteredMessage = _messageController.text;
    if (_enteredMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    _messageController.clear();
    final User? user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    FirebaseFirestore.instance.collection('chat').add({
      'text': _enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: const InputDecoration(labelText: 'Send a message'),
            autocorrect: true,
            textCapitalization: TextCapitalization.sentences,
            enableSuggestions: true,
          ),
        ),
        IconButton(
          onPressed: _sendMessage,
          icon: Icon(
            Icons.send,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ]),
    );
  }
}
