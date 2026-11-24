import 'package:chat_app/features/groups/providers/group_chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatInputBar extends ConsumerWidget {
final String groupId;
final TextEditingController messageController;
final Function(String) onTextChange;
final VoidCallback onSendMessage;
final VoidCallback onSendImage;
const ChatInputBar({
super.key,
required this.groupId,
required this.messageController,
required this.onTextChange,
required this.onSendMessage,
required this.onSendImage,
});

@override
Widget build(BuildContext context, WidgetRef ref) {
final isUploading=ref.watch(isUploadingProvider(groupId));

  return Container(
  padding: EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: AppColors.surface,
    boxShadow: [
      BoxShadow(
        color: AppColors.border,
        blurRadius: 4,
        offset: Offset(0,-2),
      )
    ]
  ),
    child: Row(
      children: [
        IconButton(onPressed: isUploading?
        null:onSendImage,
            icon: Icon(
              Icons.image, color:
            isUploading?Colors.grey
                :AppColors.primary
            )
        ),
        Expanded(
            child: TextField(
              controller: messageController,
              onChanged: onTextChange,
              enabled: !isUploading,
              decoration: InputDecoration(
                hintText: "Message...",
                 filled: true,
                 fillColor: AppColors.primarySoft,
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            )
        ),
        FloatingActionButton(
            onPressed: isUploading?null :onSendMessage,
          mini: true,
          elevation: 0,
          backgroundColor: AppColors.primary,
          child: isUploading
          ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2,),


          )
          :Icon(
            Icons.send,
            color: Colors.white,
            size: 30,
          )
        )

      ],
    ),
);
}
}