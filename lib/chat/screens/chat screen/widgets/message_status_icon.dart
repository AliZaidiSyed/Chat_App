import 'package:chat_app/chat/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Builds the message status icon
/// depending on:
/// - who sent the message
/// - whether the receiver is online
/// - whether the message was read

Widget buildMessagesStatusIcon(MessageModel message, String uid) {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // Only show status for messages sent by the current user
  if (message.senderId != currentUserId) {
    return const SizedBox();
  }

  // Listen to the receiver (chat partner) user doc
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .snapshots(),
    builder: (context, userSnapshot) {
      bool isReceiverOnline = false;

      // Check if user doc exists and fetch 'isOnline' field
      if (userSnapshot.hasData && userSnapshot.data!.exists) {
        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        isReceiverOnline = userData['isOnline'] ?? false;
      }

      // Check if the receiver has read the message
      final isMessageRead = message.readBy?.containsKey(uid) ?? false;

      if (isMessageRead) {
        // Message was read by receiver -> show two white ticks
        return const Icon(Icons.done_all, size: 16, color: Colors.white);
      } else if (isReceiverOnline) {
        // Receiver is online but hasn't read -> show two black ticks
        return const Icon(Icons.done_all, size: 16, color: Colors.black54);
      } else {
        // Message delivered but receiver offline -> show single tick
        return const Icon(Icons.check, size: 16, color: Colors.black54);
      }
    },
  );
}