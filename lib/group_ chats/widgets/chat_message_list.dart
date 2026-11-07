import 'package:chat_app/core/helper/group_date_helper.dart';
import 'package:chat_app/group_%20chats/model/group_message_model.dart';
import 'package:chat_app/group_%20chats/provider/group_chat_provider.dart';
import 'package:chat_app/group_%20chats/widgets/chat_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessageList extends ConsumerWidget {
final String groupId;
final ScrollController scrollController;
const ChatMessageList({
super.key,
required this.groupId,
required this.scrollController,
});

@override
Widget build(BuildContext context, WidgetRef ref) {
final currentUserId = FirebaseAuth.instance.currentUser!.uid;
return StreamBuilder<List<GroupMessageModel>>(
    stream: ref.read(groupChatServiceProvider).getGroupMessages(groupId),

    builder: (context,snapshot){
      if(snapshot.hasError){
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 48,color: Colors.red,),
              SizedBox(height: 16,),
              Text("Error:${snapshot.error}"),
              SizedBox(height: 16,),
              ElevatedButton(onPressed: () {}, child: Text("Retry")),
            ],
          ),
        );
      }
      if(!snapshot.hasData){
        return Center(child: CircularProgressIndicator(),);
      }
      final messages=snapshot.data!;
      if(messages.isEmpty){
        return Center(
          child: Text("No messages yet, Start the conversation!"),

        );

      }

      return ListView.builder(
        controller:  scrollController,
          reverse: true,
          itemCount: messages.length,

          itemBuilder: (context,index) {
          final message=messages[index];
          final showDateSeparator=shouldShowDateSeparator(index, messages);
          return Column(
            children: [
              if(showDateSeparator)
                Padding(
                    padding:EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                          child: Divider(),),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6
                        ),
                        decoration: BoxDecoration(color:
                        Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),

                        ),
                        child: Text(
                          getDateLabel(message.timestamp??DateTime.now()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                ),

              if(message.type=="system")
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.message,
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                )
              else
                ChatMessage(
            message: message,
            isMe: message.senderId==currentUserId,
            ),

            ],
          );


          });

    },
);
}
}