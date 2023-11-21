import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/12.1%20message_bubble.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found.'),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Somthing went wrong...'),
          );
        }
        final loadedMessages = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (BuildContext ctx, index) {
            final _chatMessage = loadedMessages[index].data();
            final _nextMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;
            final currentMessageUserId = _chatMessage['userId'];
            final nextMessageUserId =
                _nextMessage != null ? _nextMessage['userId'] : null;
            final bool nextUserIsSame =
                nextMessageUserId == currentMessageUserId;
            if (nextUserIsSame) {
              return MessageBubble.next(
                  message: _chatMessage['text'],
                  isMe: authUser!.uid == currentMessageUserId);
            } else {
              return MessageBubble.first(
                  userImage: _chatMessage['userImage'],
                  username: _chatMessage['username'],
                  message: _chatMessage['text'],
                  isMe: authUser!.uid == currentMessageUserId);
            }
          },
        );
      },
    );
  }
}
