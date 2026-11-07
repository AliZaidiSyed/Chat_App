import 'package:chat_app/chat/screens/chat%20screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/chat/model/message_model.dart';

import 'package:chat_app/core/utils/time_format.dart';


import 'image_full_screen.dart';
import 'message_status_icon.dart';

class MessageAndImageDisplay extends StatelessWidget {
  final bool isMe;
  final ChatScreen widget;
  final MessageModel message;

  const MessageAndImageDisplay({
    super.key,
    required this.isMe,
    required this.widget,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final otherUser = widget.otherUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.imageUrl != null &&
                      message.imageUrl!.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () {
                        showFullScreenImage(context, message.imageUrl!);
                      },
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 250,
                          maxWidth: 250,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            message.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    if (message.message.isNotEmpty) const SizedBox(height: 6),
                  ],
                  if (message.message.isNotEmpty)
                    Text(
                      message.message,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTime(message.timestamp ?? DateTime.now()),
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        buildMessagesStatusIcon(message, widget.otherUser.uid),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}