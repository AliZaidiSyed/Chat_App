import 'package:chat_app/core/helper/current_time.dart';
import 'package:chat_app/group_%20chats/provider/group_chat_provider.dart';
import 'package:chat_app/group_%20chats/screens/create_group_screen.dart';
import 'package:chat_app/group_%20chats/screens/group_chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupScreen extends ConsumerStatefulWidget {
  const GroupScreen({super.key});

  @override
  ConsumerState<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends ConsumerState<GroupScreen> {

  Future<void> _onRefresh() async{
    ref.invalidate(groupProvider);
    await Future.delayed(Duration(milliseconds: 500));
  }


  @override
  Widget build(BuildContext context) {
    final groups=ref.watch(groupProvider);
    final currentUserId=FirebaseAuth.instance.currentUser?.uid ?? "";
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        title: Text("Groups",style: TextStyle(fontWeight: FontWeight.w400),),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context)=>
                    CreateGroupScreen())
            );

          },
            icon: Icon(Icons.group_add),

          ),
        ],

      ),


      body: RefreshIndicator(
          onRefresh: _onRefresh,
          child:groups.when(
              data:(groupLists){
                if(groupLists.isEmpty){
                  return ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 200,),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.groups, size: 64, color: Colors.grey,),
                            SizedBox(height: 16,),
                            Text(
                              "No Groups yet",
                              style:  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8,),
                            Text(
                              "Create a group to get started",
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
                    itemCount: groupLists.length,
                    itemBuilder: (context,index){
                    final group=groupLists[index];
                    final unreadCount=group.getUnreadCount(currentUserId);
                    final hasUnread=unreadCount>0;

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: group.groupPhotoURL !=null
                          ?NetworkImage(group.groupPhotoURL!)
                            :null,
                        child: group.groupPhotoURL==null
                          ? Icon(Icons.group)
                            :null,
                      ),
                      title: Text(
                        group.groupName,
                        style: TextStyle(fontWeight: FontWeight.w400),


                      ),
                      subtitle: Text(
                        group.lastMessage.isNotEmpty? group.lastMessage:"${group.members.length} members",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color:hasUnread? Colors.black:Colors.grey,
                        fontWeight: hasUnread?FontWeight.w500:FontWeight.normal,

                        ),
                      ),
                      trailing:  Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if(group.lastMessageTime!=null)
                            Text(
                              formatTime(group.lastMessageTime!),
                              style: TextStyle(
                                fontSize: 12,
                                color: hasUnread? Colors.black :Colors.grey,
                              ),

                            ),
                          // Display unread count badge
                          if (hasUnread) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ), // EdgeInsets.symmetric
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ), // BoxDecoration
                              child: Text(
                                unreadCount > 99 ? "99+" : "$unreadCount",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ), // TextStyle
                              ), // Text
                            ), // Container
                          ],


                        ],),
                      onTap: ()=>
                          Navigator.push(context,
                              MaterialPageRoute(builder:(context)=>
                                  GroupChatScreen(group: group))),

                    );

                    }
                );
              },
            error: (error,_) =>ListView(
              children: [
                SizedBox(height: 200,),
                Center(
                  child: Column(
                    children: [
                      Text("Error: $error"),
                    ElevatedButton(onPressed: _onRefresh,
              child:Text("Retry"))

                    ],
                  ),
                ),

              ],
            ),

              loading: () =>Center(child: CircularProgressIndicator(),),
          ),
      ),
    );
  }
}
