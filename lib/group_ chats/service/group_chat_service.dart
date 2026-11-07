import 'dart:async';
import 'dart:io';

import 'package:chat_app/core/service/edge_notification_service.dart';
import 'package:chat_app/core/utils/chat_id.dart';
import 'package:chat_app/group_%20chats/model/group_chat_model.dart';
import 'package:chat_app/group_%20chats/model/group_message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class GroupChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String get currentUserId => _auth.currentUser?.uid ?? "";

  //----------- Are user friends-------------//
  Future<bool> areUserFriends(String userID1, String userID2) async {
    final chatId = generateChatId(userID1, userID2);
    final friendship = await _firestore
        .collection("friendships")
        .doc(chatId)
        .get();
    return friendship.exists;
  }

  //----------  Upload Images  -------------//

  Future<String> uploadImage(File imageFile, String chatId) async {
    try {
      final fileName =
          "${DateTime.now().millisecondsSinceEpoch}_$currentUserId.jpg";
      final filePath = "group_pics/$chatId/$fileName";

      // Upload to Supabase 'chat_files' bucket inside 'group_pics' folder
      await Supabase.instance.client.storage
          .from('chat_files')
          .upload(filePath, imageFile);

      // Get the public URL for the uploaded image
      final downloadUrl = Supabase.instance.client.storage
          .from('chat_files')
          .getPublicUrl(filePath);

      return downloadUrl;
    } catch (e) {
      print('Error uploading image to Supabase: $e');
      return "";
    }
  }

  //--------CREATE GROUP----------//

  Future<String> createGroup({
    required String groupName,
    required List<String> memberIds,
    String? groupPhotoURL,
  }) async {
    try {
      final currentUser = _auth.currentUser!;

      //member must be a fiend before display on the group creation
      for (String memberId in memberIds) {
        if (memberId != currentUserId) {
          bool areFriends = await areUserFriends(currentUserId, memberId);

          if (!areFriends) {
            return "Can only add friends to group";
          }
        }
      }

      final groupId = _firestore.collection("groups").doc().id;
      final allMembers = {...memberIds, currentUserId}.toList();

      final unreadCount = <String, int>{};
      for (String memberId in allMembers) {
        unreadCount[memberId] = 0;
      }

      final group = GroupModel(
        groupPhotoURL: groupPhotoURL,
        groupId: groupId,
        groupName: groupName,
        members: allMembers,
        admins: [currentUserId],
        createdBy: currentUserId,
        createdAt: DateTime.now(),
        unreadCount: unreadCount,
      );

      final groupMap = group.toMap();
      groupMap['lastMessageTime'] = FieldValue.serverTimestamp();
      groupMap['lastMessage'] =
          '${currentUser.displayName ?? "SomeOne"} created the group';

      await _firestore.collection("groups").doc(groupId).set(groupMap);

      //add system message
      final messageId = _firestore.collection("groupMessages").doc().id;
      await _firestore.collection("groupMessages").doc(messageId).set({
        "messageId": messageId,
        "groupId": groupId,
        "senderId": "system",
        "senderName": "System",
        "timestamp": FieldValue.serverTimestamp(),
        "message": '${currentUser.displayName ?? "SomeOne"} created the group',
      });

      return "success";
    } catch (e) {
      print("Error creating group $e");
      return e.toString();
    }
  }

  //---------- GET USER GROUP----------------//
  Stream<List<GroupModel>> getUserGroup() {
    if (currentUserId.isEmpty) return Stream.value([]);

    return _firestore
        .collection("groups")
        .where("members", arrayContains: currentUserId)
        .orderBy("lastMessageTime", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GroupModel.fromMap(doc.data()))
              .toList(),
        );
  }
  //----------Send group messages--------------//

  Future<String> sendGroupMessage({
    required String groupId,
    required String message,
  }) async {
    try {
      final currentUser = _auth.currentUser!;
      final messageId = _firestore.collection("groupMessages").doc().id;

      // get sender photo[cite: 25]
      final userDoc = await _firestore
          .collection("users")
          .doc(currentUserId)
          .get();

      String? photoURL;
      if (userDoc.exists) {
        photoURL = userDoc.data()?['photoURL'];
      }

      // get group data to update unread counts
      final groupDoc = await _firestore.collection("groups").doc(groupId).get();
      if (!groupDoc.exists) {
        return "Group not found";
      }

      final groupData = groupDoc.data()!;
      final members = List<String>.from(groupData['members'] ?? []);

      if (!members.contains(currentUserId)) {
        return "You can't send messages. You are no longer a member of this group.";
      }

      final batch = _firestore.batch();

      batch.set(_firestore.collection("groupMessages").doc(messageId), {
        'messageId': messageId,
        "groupId": groupId,
        "senderId": currentUserId,
        "senderName": currentUser.displayName ?? "User",
        'senderPhotoURL': photoURL,
        "timestamp": FieldValue.serverTimestamp(),
        'message': message,
        'type': "text",
      });

      // update unread count for all members except sender
      final unreadUpdates = <String, dynamic>{
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      };
      for (String memberId in members) {
        if (memberId != currentUserId) {
          unreadUpdates['unreadCount.$memberId'] = FieldValue.increment(1);
        } else {
          unreadUpdates['unreadCount.$memberId'] = 0;
        }
      }

      batch.update(_firestore.collection("groups").doc(groupId), unreadUpdates);
      await batch.commit();

      await sendGroupMessageNotification(
        groupId: groupId,
        message: message,
        senderName: currentUser.displayName ?? 'User',
        members: members,
        groupName: groupData['groupName'] ?? 'Group',
      );
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  // ------------------------- SEND GROUP IMAGE MESSAGE -------------------------
  Future<String> sendGroupImageMessage({
    required String groupId,
    required String imageUrl,
    String? caption,
  }) async {
    try {
      final currentUser = _auth.currentUser!;
      final messageId = _firestore.collection("groupMessages").doc().id;

      // get sender photo
      final userDoc = await _firestore
          .collection("users")
          .doc(currentUserId)
          .get();

      String? photoURL;
      if (userDoc.exists) {
        photoURL = userDoc.data()?['photoURL'];
      }

      // get group data to update unread counts
      final groupDoc = await _firestore.collection("groups").doc(groupId).get();
      if (!groupDoc.exists) {
        return "Group not found";
      }

      final groupData = groupDoc.data()!;
      final members = List<String>.from(groupData['members'] ?? []);

      if (!members.contains(currentUserId)) {
        return "You can't send messages. You are no longer a member of this group.";
      }
      final batch = _firestore.batch();

      batch.set(_firestore.collection("groupMessages").doc(messageId), {
        'messageId': messageId,
        "groupId": groupId,
        "senderId": currentUserId,
        "senderName": currentUser.displayName ?? "User",
        'senderPhotoURL': photoURL,
        'message': caption ?? '',
        'imageUrl': imageUrl,
        "timestamp": FieldValue.serverTimestamp(),
        'type': "image",
      });

      // update unread count for all members except sender
      final unreadUpdates = <String, dynamic>{
        'lastMessage': caption?.isNotEmpty == true ? caption : '📷 Photo',
        'lastMessageTime': FieldValue.serverTimestamp(),
      };

      for (String memberId in members) {
        if (memberId != currentUserId) {
          unreadUpdates['unreadCount.$memberId'] = FieldValue.increment(1);
        } else {
          unreadUpdates['unreadCount.$memberId'] = 0;
        }
      }

      batch.update(_firestore.collection("groups").doc(groupId), unreadUpdates);
      await batch.commit();
      //SEND GROUP IMAGE NOTIFICATIONS
      await sendGroupMessageNotification(
        groupId: groupId,
        message: caption?.trim().isNotEmpty == true ? caption! : '📷 Photo',

        senderName: currentUser.displayName ?? 'User',
        members: members,
        groupName: groupData['groupName'] ?? 'Group',
      );
      return 'success';
    } catch (e) {
      print('Error sending group image: $e');
      return e.toString();
    }
  }

  // ------------------------- GET GROUP MESSAGES -------------------------
  Stream<List<GroupMessageModel>> getGroupMessages(
    String groupId, {
    int limit = 50,
  }) {
    return _firestore
        .collection("groupMessages")
        .where("groupId", isEqualTo: groupId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          // filter out messages with null data and map them
          final messages = <GroupMessageModel>[];
          for (var doc in snapshot.docs) {
            try {
              final message = GroupMessageModel.fromMap(doc.data());
              messages.add(message);
            } catch (e) {
              print("Error parsing message ${doc.id}: $e");
              // skip malformed messages
            }
          }
          return messages;
        });
  }

  //---------TYPING STATUS----------------//

  Future<void> setGroupTypingStatus(String groupId, bool isTyping) async {
    if (currentUserId.isEmpty) return;
    try {
      //Check if group exist
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) {
        print("Group $groupId not found, skipping typing status update");
        return;
      }
      await _firestore.collection('groups').doc(groupId).update({
        "typing.$currentUserId": isTyping,
        "typingTimestamp.$currentUserId": FieldValue.serverTimestamp(),
      });
      if (!isTyping) {
        Future.delayed(Duration(seconds: 1), () async {
          try {
            //check again before cleanup
            final doc = await _firestore
                .collection("groups")
                .doc(groupId)
                .get();
            if (!doc.exists) {
              await _firestore.collection("groups").doc(groupId).update({
                "typing.$currentUserId": false,
              });
            }
          } catch (e) {
            //ignore
          }
        });
      }
    } catch (e) {
      print("Error updating typing status $e");
    }
  }

  // Get group typing status
  Stream<Map<String, bool>> getGroupTypingStatus(String groupId) {
    return _firestore.collection("groups").doc(groupId).snapshots().map((doc) {
      if (!doc.exists) return <String, bool>{};

      final data = doc.data() as Map<String, dynamic>;
      final typing = data['typing'] as Map<String, dynamic>? ?? {};
      final typingTimestamp =
          data['typingTimestamp'] as Map<String, dynamic>? ?? {};

      final result = <String, bool>{};
      final now = DateTime.now();
      typing.forEach((userId, isTyping) {
        if (userId != currentUserId) {
          final timestamp = typingTimestamp[userId];
          if (timestamp != null && isTyping == true) {
            final typingTime = (timestamp as Timestamp).toDate();
            final isRecent = now.difference(typingTime).inSeconds < 5;
            result[userId] = isRecent;
          } else {
            result[userId] = false;
          }
        }
      });
      return result;
    });
  }

  //---------UNREAD MESSAGE COUNT------------//

  Future<String> markGroupMessagesAsRead(String groupId) async {
    if (currentUserId.isEmpty) return "No user";
    try {
      await _firestore.collection("groups").doc(groupId).update({
        "unreadCount.$currentUserId": 0,
      });
      return "success";
    } catch (e) {
      print("Error messages as read:$e");
      return e.toString();
    }
  }

  // -------------------- UPDATE GROUP INFO--------------------

  Future<String> updateGroupInfo({
    required String groupId,
    String? newName,
    String? newPhotoURL,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (newName != null) updates['groupName'] = newName;
      if (newPhotoURL != null) updates['groupPhotoURL'] = newPhotoURL;
      await _firestore.collection('groups').doc(groupId).update(updates);

      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  // ------------------- Toggle anyone can edit -------------------
  Future<String> toggleGroupEditPermission(String groupId, bool allow) async {
    try {
      await _firestore.collection("groups").doc(groupId).update({
        "anyoneCanEditInfo": allow,
      });
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // -------------------- MAKE ADMIN --------------------

  // make user as a admin
  Future<String> makeAdmin({
    required String groupId,
    required String userId,
    required String userName,
  }) async {
    try {
      final batch = _firestore.batch();
      final groupRef = _firestore.collection("groups").doc(groupId);

      batch.update(groupRef, {
        'admins': FieldValue.arrayUnion([userId]),
      });

      // system message
      final messageId = _firestore.collection('groupMessages').doc().id;
      batch.set(_firestore.collection('groupMessages').doc(messageId), {
        'messageId': messageId,
        "groupId": groupId,
        "senderId": 'system',
        'senderName': 'System',
        "message": '$userName is now an admin',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'system',
      });

      await batch.commit();
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  // -------------------- REMOVE ADMIN--------------------

  Future<String> removeAdmin({
    required String groupId,
    required String userId,
    required String userName,
  }) async {
    try {
      final batch = _firestore.batch();
      final groupRef = _firestore.collection("groups").doc(groupId);

      batch.update(groupRef, {
        'admins': FieldValue.arrayRemove([userId]),
      });

      // system message
      final messageId = _firestore.collection('groupMessages').doc().id;
      batch.set(_firestore.collection('groupMessages').doc(messageId), {
        'messageId': messageId,
        "groupId": groupId,
        "senderId": 'system',
        'senderName': 'System',
        "message": '$userName is no longer an admin',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'system',
      });

      await batch.commit();
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  // -------------------- REMOVE GROUP MEMBER--------------------

  Future<String> removeGroupMember({
    required String groupId,
    required String userId,
    required String userName,
  }) async {
    try {
      final batch = _firestore.batch();
      final groupRef = _firestore.collection("groups").doc(groupId);

      batch.update(groupRef, {
        'members': FieldValue.arrayRemove([userId]),
        'admins': FieldValue.arrayRemove([userId]),
      });

      // system message
      final messageId = _firestore.collection('groupMessages').doc().id;
      final currentUser = _auth.currentUser!;
      batch.set(_firestore.collection('groupMessages').doc(messageId), {
        'messageId': messageId,
        "groupId": groupId,
        "senderId": 'system',
        'senderName': 'System',
        "message": '${currentUser.displayName ?? "Someone"} removed $userName',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'system',
      });

      await batch.commit();
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  // -------------------- ADD GROUP MEMBER--------------------
  // add member to group (must be a a friends)
  Future<String> addGroupMember({
    required String groupId,
    required String userId,
    required String userName,
  }) async {
    try {
      // Check if they are friends
      bool areFriends = await areUserFriends(currentUserId, userId);
      if (!areFriends) {
        return 'Can only add friends to group';
      }

      final batch = _firestore.batch();
      final groupRef = _firestore.collection("groups").doc(groupId);

      batch.update(groupRef, {
        'members': FieldValue.arrayUnion([userId]),
        'unreadCount.$userId': 0,
      });

      // system message
      final messageId = _firestore.collection('groupMessages').doc().id;
      final currentUser = _auth.currentUser!;
      batch.set(_firestore.collection('groupMessages').doc(messageId), {
        'messageId': messageId,
        "groupId": groupId,
        "senderId": 'system',
        'senderName': 'System',
        "message": '${currentUser.displayName ?? "Someone"} added $userName',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'system',
      });

      await batch.commit();
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  // -------------------- LEAVE GROUP --------------------
  Future<String> leaveGroup(String groupId) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) return "Group not found";

      final members = List<String>.from(groupDoc.data()?['members'] ?? []);

      if (members.length == 1 && members.contains(currentUserId)) {
        return await deleteGroup(groupId);
      }

      final batch = _firestore.batch();
      final groupRef = _firestore.collection('groups').doc(groupId);
      final currentUser = _auth.currentUser!;

      batch.update(groupRef, {
        'members': FieldValue.arrayRemove([currentUserId]),
        'admins': FieldValue.arrayRemove([currentUserId]),
      });

      final messageId = _firestore.collection('groupMessages').doc().id;
      batch.set(_firestore.collection('groupMessages').doc(messageId), {
        'messageId': messageId,
        'groupId': groupId,
        'senderId': 'system',
        'senderName': 'System',
        'message': '${currentUser.displayName ?? "Someone"} left the group',
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'system',
      });

      await batch.commit();
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  // -------------------- DELETE GROUP --------------------
  // to delete a group (admin only)
  // Enhanced delete with storage cleanup

  Future<String> deleteGroup(String groupId) async {
    try {
      // FIX: Get group document BEFORE deleting it
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();

      // Save group profile picture URL
      final photoUrl = groupDoc.data()?['groupPhotoURL'] as String?;

      final batch = _firestore.batch();

      // Delete the group document
      batch.delete(_firestore.collection('groups').doc(groupId));

      // Get all group messages
      final messages = await _firestore
          .collection('groupMessages')
          .where('groupId', isEqualTo: groupId)
          .get();

      // Delete all messages and collect image URLs
      final imageUrls = <String>[];

      for (final doc in messages.docs) {
        final data = doc.data();

        if (data['imageUrl'] != null) {
          imageUrls.add(data['imageUrl'] as String);
        }

        batch.delete(doc.reference);
      }

      await batch.commit();

      try {
        final supabase = Supabase.instance.client;

        // Delete group profile image
        // group_pics/$groupId/$fileName
        if (photoUrl != null && photoUrl.isNotEmpty) {
          final fileName = photoUrl.split('/').last;
          final filePath = "group_pics/$groupId/$fileName";

          await supabase.storage.from('chat_files').remove([filePath]);
        }

        // Delete all message images
        for (final imageUrl in imageUrls) {
          try {
            final fileName = imageUrl.split('/').last;
            final filePath = "group_pics/$groupId/$fileName";

            await supabase.storage.from('chat_files').remove([filePath]);
          } catch (e) {
            print('Error deleting image: $e');
          }
        }
      } catch (e) {
        print('Error deleting storage files: $e');
      }

      return 'success';
    } catch (e) {
      print('Error deleting group: $e');
      return e.toString();
    }
  }

  // ------------------- Notification -------------------
  Future<void> sendGroupMessageNotification({
    required String groupId,
    required String message,
    required String senderName,
    required List<String> members,
    required String groupName,
  }) async {
    try {
      for (String memberId in members) {
        if (memberId != currentUserId) {
          final notificationId = _firestore.collection('users').doc().id;

          await _firestore
              .collection('users')
              .doc(memberId)
              .collection('notifications')
              .doc(notificationId)
              .set({
                'uid': currentUserId,
                'username': senderName,
                'description': message,
                'timestamp': FieldValue.serverTimestamp(),
                'type': 'group_message',
                'groupId': groupId,
                'groupName': groupName,
              });

          // Supabase Edge Function
          unawaited(
            PushNotificationEdgeService.sendNotification(
              recipientUid: memberId,
              notificationId: notificationId,
            ),
          );
        }
      }
    } catch (e) {
      print('Error sending group notification: $e');
    }
  }
}
