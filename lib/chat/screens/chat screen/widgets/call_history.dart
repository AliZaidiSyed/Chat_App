import 'package:chat_app/chat/screens/chat%20screen/chat_screen.dart';
import 'package:chat_app/core/utils/time_format.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/chat/model/message_model.dart';



class CallHistory extends StatelessWidget {
  final bool isMe;
  final ChatScreen widget;
  final bool isMissed;
  final bool isVideo;
  final MessageModel message;

  const CallHistory({
    super.key,
    required this.isMe,
    required this.widget,
    required this.isMissed,
    required this.isVideo,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final otherUser = widget.otherUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: (otherUser.photoURL != null &&
                  otherUser.photoURL!.isNotEmpty)
                  ? NetworkImage(otherUser.photoURL!)
                  : null,
              child: (otherUser.photoURL == null ||
                  otherUser.photoURL!.isEmpty)
                  ? Text(
                otherUser.name.isNotEmpty
                    ? otherUser.name[0].toUpperCase()
                    : "U",
                style: const TextStyle(fontSize: 12),
              )
                  : null,
            ),
            const SizedBox(width: 8),
          ],


          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? (isMissed ? Colors.red[100] : Colors.green[100])
                  : Colors.grey[200],
              border: Border.all(
                color: isMissed ? Colors.red : Colors.green,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVideo ? Icons.videocam : Icons.phone,
                  color: isMissed ? Colors.red : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.message,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isMissed ? Colors.red[900] : Colors.green[900],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatTime(message.timestamp ?? DateTime.now()),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}