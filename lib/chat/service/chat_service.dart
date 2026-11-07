import 'dart:async';
import 'dart:io';

import 'package:chat_app/chat/model/chat_model.dart';
import 'package:chat_app/chat/model/message_model.dart';
import 'package:chat_app/chat/model/message_request_model.dart';
import 'package:chat_app/chat/model/user_model.dart';
import 'package:chat_app/core/service/edge_notification_service.dart';
import 'package:chat_app/core/utils/chat_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? "";

  // USERS
  Stream<List<UserModel>> getAllUsers() {
    if (currentUserId.isEmpty) return Stream.value([]);

    return _firestore
        .collection("users")
        .where("uid", isNotEqualTo: currentUserId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .where((user) => user.uid != currentUserId)
              .toList(),
        );
  }

  // Online Status
  Future<void> updateUserOnlineStatus(bool isOnline) async {
    if (currentUserId.isEmpty) return;
    try {
      await _firestore.collection("users").doc(currentUserId).update({
        "isOnline": isOnline,
        "lastSeen": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating online status: $e");
    }
  }

  // Are user friends
  Future<bool> areUserFriends(String userID1, String userID2) async {
    final chatId = generateChatId(userID1, userID2);
    final friendship = await _firestore
        .collection("friendships")
        .doc(chatId)
        .get();
    return friendship.exists;
  }

  // Unfriend user
  Future<String> unfriendUser(String chatId, String friendId) async {
    try {
      final batch = _firestore.batch();
      batch.delete(_firestore.collection("friendships").doc(chatId));
      batch.delete(_firestore.collection("chats").doc(chatId));

      final messages = await _firestore
          .collection("messages")
          .where("chatId", isEqualTo: chatId)
          .get();

      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // Send message request
  Future<String> sendMessageRequest({
    required String receiverId,
    required String receiverName,
    required String receiverEmail,
  }) async {
    try {
      final currentUser = _auth.currentUser!;
      final requestId = "${currentUserId}_$receiverId";

      final userDoc = await _firestore
          .collection("users")
          .doc(currentUserId)
          .get();
      String? userPhotoURL;
      if (userDoc.exists) {
        final userModel = UserModel.fromMap(userDoc.data()!);
        userPhotoURL = userModel.photoURL;
      }
      final existingRequest = await _firestore
          .collection("messageRequests")
          .doc(requestId)
          .get();

      if (existingRequest.exists &&
          existingRequest.data()?['status'] == "pending") {
        return "Request already sent";
      }
      final request = MessageRequestModel(
        id: requestId,
        senderId: currentUserId,
        receiverId: receiverId,
        senderName: currentUser.displayName ?? "user",
        senderEmail: currentUser.email ?? "",
        status: 'pending',
        createdAt: DateTime.now(),
        photoURL: userPhotoURL,
      );

      await _firestore
          .collection('messageRequests')
          .doc(requestId)
          .set(request.toMap());

      await _sendFriendRequestNotification(
        receiverId: receiverId,
        senderName: currentUser.displayName ?? 'User',
        senderPhotoURL: userPhotoURL,
      );
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<MessageRequestModel>> getPendingRequest() {
    if (currentUserId.isEmpty) return Stream.value([]);
    return _firestore
        .collection("messageRequests")
        .where("receiverId", isEqualTo: currentUserId)
        .where("status", isEqualTo: "pending")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageRequestModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Accept message request
  Future<String> acceptMessageRequest(String requestId, String senderId) async {
    try {
      final batch = _firestore.batch();
      batch.update(_firestore.collection("messageRequests").doc(requestId), {
        "status": "accepted",
      });

      final friendshipId = generateChatId(currentUserId, senderId);
      batch.set(_firestore.collection('friendships').doc(friendshipId), {
        "participants": [currentUserId, senderId],
        "createdAt": FieldValue.serverTimestamp(),
      });

      batch.set(_firestore.collection('chats').doc(friendshipId), {
        "participants": [currentUserId, senderId],
        "lastMessage": "",
        "lastSenderId": "",
        "lastMessageTime": FieldValue.serverTimestamp(),
        "unreadCount": {currentUserId: 0, senderId: 0},
      });

      final messageId = _firestore.collection("messages").doc().id;
      batch.set(_firestore.collection("messages").doc(messageId), {
        "messageId": messageId,
        "chatId": friendshipId,
        "senderId": "system",
        "senderName": "System",
        "message": "Request has been accepted. You can now start chatting!",
        "timestamp": FieldValue.serverTimestamp(),
        "time": "system",
      });
      await batch.commit();
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // Reject message request
  Future<String> rejectMessageRequest(
    String requestId, {
    bool deleteRequest = true,
  }) async {
    try {
      if (deleteRequest) {
        await _firestore.collection("messageRequests").doc(requestId).delete();
      } else {
        await _firestore.collection("messageRequests").doc(requestId).update({
          "status": "rejected",
        });
      }
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // ------------CHATS-----------
  final Map<String, List<ChatModel>> _chatsCache = {};

  Stream<List<ChatModel>> getUserChats() {
    if (currentUserId.isEmpty) return Stream.value([]);
    return _firestore
        .collection("chats")
        .where("participants", arrayContains: currentUserId)
        .orderBy("lastMessageTime", descending: true)
        .limit(20)
        .snapshots()
        .map((snapshots) {
          final docs = snapshots.docs.map((doc) {
            return ChatModel.fromMap({...doc.data(), 'chatId': doc.id});
          }).toList();

          return docs;
        });
  }

  Stream<List<MessageModel>> getChatMessages(
    String chatId, {
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) {
    Query query = _firestore
        .collection("messages")
        .where("chatId", isEqualTo: chatId)
        .orderBy("timestamp", descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    return query.snapshots().map((snapshot) {
      final docs = snapshot.docs
          .map(
            (doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
      return docs;
    });
  }

  // ---------send chat messages
  Future<String> sendMessage({
    required String chatId,
    required String message,
  }) async {
    if (chatId.trim().isEmpty || currentUserId.isEmpty) {
      return "Invalid chat ID or user session";
    }

    try {
      final currentUser = _auth.currentUser!;
      final messageId = _firestore.collection("messages").doc().id;
      final batch = _firestore.batch();

      batch.set(_firestore.collection("messages").doc(messageId), {
        "messageId": messageId,
        "senderId": currentUserId,
        "senderName": currentUser.displayName ?? "User",
        "message": message,
        "timestamp": FieldValue.serverTimestamp(),
        "readBy": {},
        "chatId": chatId,
        "type": "user",
      });

      final chatDoc = await _firestore.collection("chats").doc(chatId).get();
      if (!chatDoc.exists) {
        return "Chat not found";
      }
      final chatData = chatDoc.data()!;
      final participants = List<String>.from(chatData['participants']);
      final otherUserId = participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      if (otherUserId.isEmpty) {
        return "Receiver not found";
      }

      batch.update(_firestore.collection('chats').doc(chatId), {
        "lastMessage": message,
        "lastMessageTime": FieldValue.serverTimestamp(),
        "lastSenderId": currentUserId,
        'unreadCount.$otherUserId': FieldValue.increment(1),
        'unreadCount.$currentUserId': 0,
      });
      await batch.commit();

      await _sendMessageNotification(
        chatId: chatId,
        message: message,
        otherUserId: otherUserId,
      );
      return "success";
    } catch (e) {
      print("Error sending message $e");
      return e.toString();
    }
  }

  // ------------UPLOAD IMAGES---------------------//

  Future<String> uploadImage(File imageFile, String chatId) async {
    try {
      final fileName =
          "${DateTime.now().microsecondsSinceEpoch}_$currentUserId.jpg";
      final filePath = "chat_pics/$chatId/$fileName";

      await Supabase.instance.client.storage
          .from("chat_files")
          .upload(filePath, imageFile);

      final downloadUrl = Supabase.instance.client.storage
          .from("chat_files")
          .getPublicUrl(filePath);

      return downloadUrl;
    } catch (e) {
      print("Error uploading image:$e");
      return "";
    }
  }

  // send image message
  Future<String> sendImageMessage({
    required String chatId,
    required String imageUrl,
    String? caption,
  }) async {
    if (chatId.trim().isEmpty || currentUserId.isEmpty) {
      return "Invalid chat ID or user session";
    }

    try {
      final currentUser = _auth.currentUser!;
      final messageId = _firestore.collection("messages").doc().id;
      final batch = _firestore.batch();

      batch.set(_firestore.collection("messages").doc(messageId), {
        "messageId": messageId,
        "senderId": currentUserId,
        "senderName": currentUser.displayName ?? "User",
        "message": caption ?? "",
        "imageUrl": imageUrl,
        "timestamp": FieldValue.serverTimestamp(),
        "readBy": {},
        "chatId": chatId,
        "type": "image",
      });

      final chatDoc = await _firestore.collection("chats").doc(chatId).get();
      if (!chatDoc.exists) {
        return "Chat not found";
      }
      final chatData = chatDoc.data()!;
      final participants = List<String>.from(chatData['participants']);
      final otherUserId = participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      if (otherUserId.isEmpty) {
        return "Receiver not found";
      }

      batch.update(_firestore.collection("chats").doc(chatId), {
        "lastMessage": caption?.isNotEmpty == true ? caption : '📷 Photo',
        "lastMessageTime": FieldValue.serverTimestamp(),
        "lastSenderId": currentUserId,
        "unreadCount.$otherUserId": FieldValue.increment(1),
        "unreadCount.$currentUserId": 0,
      });
      await batch.commit();
      await _sendMessageNotification(
        chatId: chatId,
        message: caption?.trim().isNotEmpty == true ? caption! : '📷 Photo',
        otherUserId: otherUserId,
      );
      return 'success';
    } catch (e) {
      print("Error sending message $e");
      return e.toString();
    }
  }

  Future<String> sendImageWithUpload({
    required String chatId,
    required File imageFile,
    String? caption,
  }) async {
    final imageUrl = await uploadImage(imageFile, chatId);
    if (imageUrl.isEmpty) {
      return "Failed to upload image";
    }
    return await sendImageMessage(
      chatId: chatId,
      imageUrl: imageUrl,
      caption: caption,
    );
  }

  // --------CALL HISTORY------------
  Future<String> addCallHistory({
    required String chatId,
    required bool isVideoCall,
    required String callStatus,
    int? duration,
  }) async {
    try {
      final currentUser = _auth.currentUser!;
      final messageId = _firestore.collection('messages').doc().id;
      final batch = _firestore.batch();

      batch.set(_firestore.collection('messages').doc(messageId), {
        "messageId": messageId,
        "senderId": currentUserId,
        "senderName": currentUser.displayName ?? "User",
        "message": isVideoCall ? "Video call" : "Audio Call",
        "callType": isVideoCall ? "video" : "audio",
        "timestamp": FieldValue.serverTimestamp(),
        "callStatus": callStatus,
        "readBy": {},
        "chatId": chatId,
        "type": "call",
      });

      batch.update(_firestore.collection('chats').doc(chatId), {
        "lastMessage": isVideoCall ? "Video call" : "Audio call",
        "lastMessageTime": FieldValue.serverTimestamp(),
        "lastSenderId": currentUserId,
      });

      await batch.commit();
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // ---------------MARK MESSAGES AS READ(MESSAGE STATUS)-----------------//

  Future<void> markMessagesAsRead(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || chatId.trim().isEmpty) return;
    try {
      final batch = _firestore.batch();

      final chatRef = _firestore.collection("chats").doc(chatId);
      batch.update(chatRef, {
        'unreadCount.${currentUser.uid}': 0,
        "lastReadTime.${currentUser.uid}": FieldValue.serverTimestamp(),
      });

      final messageQuery = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .where('senderId', isNotEqualTo: currentUser.uid)
          .where("readBy.${currentUser.uid}", isEqualTo: null)
          .get();

      for (var doc in messageQuery.docs) {
        batch.update(doc.reference, {
          "readBy.${currentUser.uid}": FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      _chatsCache.clear();
    } catch (e) {
      print("Error marking messages as read:$e");
    }
  }

  //----------------TYPING INDICATOR---------------//

  Stream<Map<String, bool>> getTypingStatus(String chatId) {
    return _firestore.collection("chats").doc(chatId).snapshots().map((doc) {
      if (!doc.exists) return <String, bool>{};
      final data = doc.data() as Map<String, dynamic>;
      final typing = data['typing'] as Map<String, dynamic>? ?? {};

      final typingTimestamp =
          data["typingTimestamp"] as Map<String, dynamic>? ?? {};
      final result = <String, bool>{};
      final now = DateTime.now();

      typing.forEach((userid, isTyping) {
        if (userid != currentUserId) {
          final timestamp = typingTimestamp[userid];

          if (timestamp != null && isTyping == true) {
            final typingTime = (timestamp as Timestamp).toDate();
            final isRecent = now.difference(typingTime).inSeconds < 5;
            result[userid] = isRecent;
          } else {
            result[userid] = false;
          }
        }
      });
      return result;
    });
  }

  Future<void> setTypingStatus(String chatId, bool isTyping) async {
    if (currentUserId.isEmpty) return;
    try {
      await _firestore.collection("chats").doc(chatId).update({
        "typing.$currentUserId": isTyping,
        "typingTimestamp.$currentUserId": FieldValue.serverTimestamp(),
      });

      if (!isTyping) {
        Future.delayed(const Duration(seconds: 1), () async {
          try {
            await _firestore.collection("chats").doc(chatId).update({
              "typing.$currentUserId": false,
            });
          } catch (e) {
            // ignore error for cleanup
          }
        });
      }
    } catch (e) {
      print("Error updating typing status: $e");
    }
  }

  // ------------ SEND NOTIFICATION MESSAGE ------------

  Future<void> _sendMessageNotification({
    required String chatId,
    required String message,
    required String otherUserId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      final notificationId = _firestore.collection('users').doc().id;

      // Create notification document that triggers Cloud Function
      await _firestore
          .collection('users')
          .doc(otherUserId)
          .collection('notifications')
          .doc(notificationId)
          .set({
            'uid': currentUser?.uid,
            'username': currentUser?.displayName ?? 'User',
            'description': message,
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'message',
            'chatId': chatId,
          });

      unawaited(
        PushNotificationEdgeService.sendNotification(
          recipientUid: otherUserId,
          notificationId: notificationId,
        ),
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  //------SEND MESSAGE REQUEST NOTIFICATION------------//
  Future<void> _sendFriendRequestNotification({
    required String receiverId,
    required String senderName,
    String? senderPhotoURL,
  }) async {
    try {
      final notificationId = _firestore.collection('users').doc().id;

      // Create notification document that triggers Cloud Function
      await _firestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .doc(notificationId)
          .set({
            'uid': currentUserId,
            'username': senderName,
            'description': '$senderName sent you a friend request',
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'friend_request',
            'senderPhotoURL': senderPhotoURL,
            'read': false,
          });

      unawaited(
        PushNotificationEdgeService.sendNotification(
          recipientUid: receiverId,
          notificationId: notificationId,
        ),
      );

      print('Friend request notification sent to $receiverId');
    } catch (e) {
      print('Error sending friend request notification: $e');
      // Don't throw - allow friend request to succeed even if notification fails
    }
  }
}
