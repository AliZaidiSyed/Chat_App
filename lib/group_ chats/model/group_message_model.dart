import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessageModel {
  final String messageId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime? timestamp;
  final String type; // 'text', 'image', 'system'
  final String? imageUrl;
  final String? senderPhotoURL;

  GroupMessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.message,
    this.timestamp,
    this.type = 'text',
    this.imageUrl,
    this.senderPhotoURL,
  });

  factory GroupMessageModel.fromMap(Map<String, dynamic> map) {
    // Handle timestamp more gracefully
    DateTime? timestamp;
    if (map['timestamp'] != null) {
      if (map['timestamp'] is Timestamp) {
        timestamp = (map['timestamp'] as Timestamp).toDate();
      } else if (map['timestamp'] is DateTime) {
        timestamp = map['timestamp'] as DateTime;
      }
    }

    return GroupMessageModel(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      timestamp: timestamp ?? DateTime.now(),
      type: map['type'] ?? 'text',
      imageUrl: map['imageUrl'],
      senderPhotoURL: map['senderPhotoURL'],
    ); // GroupMessageModel
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp != null
          ? Timestamp.fromDate(timestamp!)
          : FieldValue.serverTimestamp(),
      'type': type,
      'imageUrl': imageUrl,
      'senderPhotoURL': senderPhotoURL,
    };
  }
}