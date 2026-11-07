import 'package:chat_app/chat/provider/proviider.dart';
import 'package:chat_app/chat/provider/user_status_provider.dart';
import 'package:chat_app/chat/screens/chat%20screen/chat_screen.dart';
import 'package:chat_app/chat/screens/chat%20screen/widgets/dot_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserChatProfile extends StatelessWidget {
  const UserChatProfile({super.key, required this.widget});
final ChatScreen widget;


  @override
  Widget build(BuildContext context) {
    return Consumer(

      builder: (context, ref, _) {
        final statusAsync = ref.watch(
            userStatusProvider(widget.otherUser.uid));

        final typingStatus=ref.watch(typingProvider(widget.chatId));
        final isOtherUserTyping=typingStatus[widget.otherUser.uid] ?? false;
        return statusAsync.when(
          data: (isOnline) =>
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: widget.otherUser.photoURL != null
                        ? NetworkImage(widget.otherUser.photoURL!)
                        : null,
                    child: widget.otherUser.photoURL == null
                        ? Text(
                      widget.otherUser.name.isNotEmpty
                          ? widget.otherUser.name[0].toLowerCase() :
                      "U",
                    )
                        : null,
                  ),

                  SizedBox(width: 12,),
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.otherUser.name,
                            style: TextStyle(fontSize: 16),),




                          if(isOtherUserTyping)
                            Row(
                              children: [
                                Text(
                                  "Typing",
                                  style: TextStyle(
                                      color: Colors.blue[600],
                                    fontSize: 12,
                                  ),

                                ),
                                SizedBox(width: 4,),
                                ThreeDots(),

                              ],
                            )
                          else  if(isOnline)
                            Text(
                              "Online",
                              style:
                              TextStyle(
                                  fontSize: 12,
                                  color: Colors.green),
                            )



                        ],
                      )
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
