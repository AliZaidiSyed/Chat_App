import 'package:chat_app/chat/model/user_model.dart';
import 'package:chat_app/chat/provider/proviider.dart';
import 'package:chat_app/chat/provider/user_status_provider.dart';
import 'package:chat_app/chat/screens/chat%20screen/chat_screen.dart';
import 'package:chat_app/chat/screens/request_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/time_format.dart';


class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      ref.invalidate(requestProvider);
      ref.invalidate(chatsProvider);
    });
    super.initState();
  }

  //manual refresh (pull to refresh action)
  Future<void> _onRefresh() async{
    ref.invalidate(requestProvider);
    ref.invalidate(chatsProvider);
    await Future.delayed(Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final pendingRequests = ref.watch(requestProvider);
    final chats = ref.watch(chatsProvider);

    //count pending requests
    final requestCount = pendingRequests.when(
        data: (requests) => requests.length,
        loading: () => 0,
        error: (error, stackTrace){
          print("Firebase console error fetching requests $error");
          return 0;
        }
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text("Chats", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          //Notification icon only if there are pending requests
          if(requestCount > 0)
            IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RequestScreen())),
                icon: Stack(
                  children: [
                    Icon(Icons.notifications, color: Colors.black),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "$requestCount",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    )
                  ],
                )
            )
        ],
      ),
      // pull-to-refresh + chat list display
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: chats.when(
          // case 1: chats loaded successfully
          data: (chatsList) {
            if (chatsList.isEmpty) {
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 200),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text("No Chats yet",
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey),),
                        SizedBox(height: 8),
                        Text(
                          "Go to Users tab to send message requests",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              );
            }

            return ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: chatsList.length,
              itemBuilder: (context, index) {
                final chat = chatsList[index];
                //fetch other user details
                return FutureBuilder<UserModel?>(
                    future: _getOtherUser(chat.participants),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return SizedBox();
                      final otherUser=snapshot.data!;
                      final currentUserId=FirebaseAuth.instance.currentUser?.uid;
                      if(currentUserId==null) return SizedBox();
                      //count unread msgs
                      final unreadCount=chat.unreadCount[currentUserId] ?? 0;


                      //show unread highlight if other user sent msg
                      final shouldShowUnread=unreadCount>0 &&
                          chat.lastSenderId != currentUserId;
                      final isVideoCall = chat.lastMessage.toLowerCase().contains('video call');
                      final isAudioCall = chat.lastMessage.toLowerCase().contains('audio call');
                      final isCallMessage = isVideoCall || isAudioCall;

                      return ListTile(
                        //user profile + online atatus
                        //if frnd request is acepted then we will display user profile on chat screen
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: (otherUser.photoURL != null && otherUser.photoURL!.isNotEmpty)
                                  ? NetworkImage(otherUser.photoURL!) : null,
                              child: (otherUser.photoURL == null || otherUser.photoURL!.isEmpty)
                                  ? Text(otherUser.name.isNotEmpty ? otherUser.name[0].toLowerCase() : "U")
                                  : null,
                            ),
                            //online/offline status
                            Positioned(
                                right: 2,
                                bottom: 0,
                                child: Consumer(
                                    builder: (context,ref,_){
                                      final statusAsync=ref.watch(userStatusProvider(otherUser.uid),
                                      );

                                      return statusAsync.when(
                                        data: (isOnline)=>CircleAvatar(
                                            radius: 3,
                                            backgroundColor: isOnline
                                                ?Colors.green
                                                :Colors.grey
                                        ),

                                        error:(_,_)=> Text(otherUser.email),
                                        loading:()=>Text(otherUser.email),
                                      );
                                    }


                                )

                            )
                          ],
                        ),
                        title: Text(otherUser.name,
                          style: TextStyle(
                              fontWeight: shouldShowUnread?
                              FontWeight.bold
                                  :FontWeight.normal
                          ),

                        ),
                        subtitle: isCallMessage
                            ? Row(
                          children: [
                            Icon(
                              isVideoCall ? Icons.videocam : Icons.call,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                chat.lastMessage,
                                style: TextStyle(
                                  fontWeight: shouldShowUnread
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                            : Text(
                          chat.lastMessage.isNotEmpty
                              ? chat.lastMessage
                              : "You can now start to chat",
                          style: TextStyle(
                            fontWeight: shouldShowUnread
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              formatTime(chat.lastMessageTime),
                              style: TextStyle(
                                fontSize: 12,
                                color: shouldShowUnread
                                    ? Colors.blue
                                    :Colors.grey,
                              ),
                            ),
                            if(shouldShowUnread)
                              Container(
                                margin: EdgeInsets.only(top:4),
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "$unreadCount",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                          ],
                        ),
                        onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>
                            ChatScreen(chatId: chat.chatId, otherUser:otherUser))


                        ),
                      );
                    }
                );
              },
            );
          },
          // case 2: loading state
          loading: () => const Center(child: CircularProgressIndicator()),
          // case 3: error state
          error: (error, _) => ListView(
            children: [
              SizedBox(height: 200),
              Center(
                child: Column(
                  children: [
                    Text("Error: $error"),
                    SizedBox(height: 16),
                    ElevatedButton(onPressed: _onRefresh, child: Text("Retry")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<UserModel?> _getOtherUser(List<String> participants) async{
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if(currentUserId == null) return null;
    final otherUserId = participants.firstWhere((id) => id != currentUserId);
    try{
      final docs = await FirebaseFirestore.instance.collection("users").doc(otherUserId).get();
      return docs.exists ? UserModel.fromMap(docs.data()!) : null;
    }catch(e){
      print("Error getting other user $e");
      return null;
    }
  }
}