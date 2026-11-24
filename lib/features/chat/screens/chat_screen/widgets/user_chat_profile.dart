
import 'package:chat_app/features/chat/providers/proviider.dart';
import 'package:chat_app/features/chat/providers/user_status_provider.dart';
import 'package:chat_app/features/chat/screens/chat_screen/chat_screen.dart';
import 'package:chat_app/features/chat/screens/chat_screen/widgets/dot_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserChatProfile extends StatelessWidget {
  const UserChatProfile({
    super.key,
    required this.widget,
  });

  final ChatScreen widget;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final statusAsync = ref.watch(
          userStatusProvider(widget.otherUser.uid),
        );

        final typingStatus = ref.watch(
          typingProvider(widget.chatId),
        );

        final isOtherUserTyping =
            typingStatus[widget.otherUser.uid] ?? false;

        // Profile picture and fallback letter
        final photoUrl = widget.otherUser.photoURL?.trim() ?? '';
        final hasPhoto = photoUrl.isNotEmpty;

        final name = widget.otherUser.name.trim();
        final firstLetter = name.isNotEmpty
            ? name[0].toUpperCase()
            : 'U';

        return statusAsync.when(
          data: (isOnline) => Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFDBEAFE),

                child: ClipOval(
                  child: hasPhoto
                      ? Image.network(
                    photoUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          firstLetter,
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  )
                      : Center(
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.otherUser.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (isOtherUserTyping)
                      Row(
                        children: [
                          Text(
                            "Typing",
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(width: 4),

                          const ThreeDots(),
                        ],
                      )
                    else if (isOnline)
                      const Text(
                        "Online",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          error: (_, _) => Text(widget.otherUser.name),

          loading: () => Text(widget.otherUser.name),
        );
      },
    );
  }
}
