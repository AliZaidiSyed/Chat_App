
import 'package:chat_app/core/helper/current_time.dart';
import 'package:chat_app/group_%20chats/model/group_message_model.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final GroupMessageModel message;
  final bool isMe;

  const ChatMessage({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = message.imageUrl != null &&
        message.imageUrl!.isNotEmpty;

    final hasPhoto = message.senderPhotoURL != null &&
        message.senderPhotoURL!.isNotEmpty;

    final senderName = message.senderName.isNotEmpty
        ? message.senderName
        : 'User';

    return Align(
      alignment:
      isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [

            // Other user's profile picture
            if (!isMe)
              CircleAvatar(
                radius: 16,
                backgroundImage: hasPhoto
                    ? NetworkImage(message.senderPhotoURL!)
                    : null,
                child: !hasPhoto
                    ? Text(senderName[0].toUpperCase())
                    : null,
              ),

            if (!isMe)
              const SizedBox(width: 8),

            // Message bubble
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth:
                  MediaQuery.of(context).size.width * 0.70,
                ),
                padding: EdgeInsets.all(hasImage ? 5 : 10),
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.green.shade100
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: Radius.circular(isMe ? 12 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 12),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Other member name at top
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          senderName,
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    // Image message
                    if (hasImage)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.network(
                          message.imageUrl!,
                          width: MediaQuery.of(context).size.width * 0.62,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Padding(
                              padding: EdgeInsets.all(15),
                              child: Icon(
                                Icons.broken_image,
                                size: 35,
                              ),
                            );
                          },
                        ),
                      ),

                    // Text message or image caption
                    if (message.message.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          top: hasImage ? 6 : 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                message.message,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            currentTime(
                              message.timestamp,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Image without caption
                    if (hasImage && message.message.isEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: currentTime(
                          message.timestamp,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
