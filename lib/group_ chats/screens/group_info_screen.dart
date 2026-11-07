import 'package:chat_app/group_%20chats/provider/group_chat_provider.dart' ;
import 'package:chat_app/group_%20chats/widgets/add_member_button.dart';
import 'package:chat_app/group_%20chats/widgets/admin_control_section.dart';
import 'package:chat_app/group_%20chats/widgets/group_identity.dart';
import 'package:chat_app/group_%20chats/widgets/group_member_count.dart';
import 'package:chat_app/group_%20chats/widgets/leave_and_delete_button.dart';
import 'package:chat_app/group_%20chats/widgets/member_list_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupInfoScreen extends ConsumerWidget {
  final String groupId;
  const GroupInfoScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final groupAsync = ref.watch(groupStreamProvider(groupId));
    return Scaffold(
      appBar: AppBar(title: Text("Group Info"),centerTitle: true,),
      body: groupAsync.when(
        data: (group) {
          if (group == null) {
            return Center(child: Text("Group  not found or has beed deleted"));
          }

          final isAdmin=group.isAdmin(currentUserId);
          final canEdit=isAdmin || group.anyoneCanEditInfo;
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20,),
                //Group name image member
                GroupIdentity(group: group, canEdit: canEdit, groupId: groupId),

                SizedBox(height: 5),
               // group member count
                GroupMemberCount(
                  groupId: groupId,
                  style: TextStyle(color: Colors.grey),
                ), // GroupMemberCount
                SizedBox(height: 20),
                  // admin controls
                if(isAdmin)
                  AdminControlsSection(group: group, groupId: groupId),


                // group member list
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Members",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ), // TextStyle
                    ), // Text
                  ), // Align
                ), // Padding


                MemberListSection(
                    group: group,
                    currentUserId: currentUserId,
                    isAdmin: isAdmin,
                    groupId: groupId),
                  // add member button
                  if(isAdmin || group.anyoneCanEditInfo)
                    AddMemberButton(group: group, groupId: groupId),
                SizedBox(height: 12,),

                //leave or delete button
                LeaveAndDeleteButton(isAdmin: isAdmin, group: group, groupId: groupId),


                
          ],
            ),

          ); // SingleChildScrollView
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text("Error: $error"),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(groupStreamProvider(groupId));
                },
                child: Text("Retry"),
              ), // ElevatedButton
            ],
          ), // Column
        ),
      ),
    ); // Scaffold
  }
}