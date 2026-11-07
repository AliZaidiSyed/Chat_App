import 'package:chat_app/chat/model/user_list_model.dart';
import 'package:chat_app/chat/model/user_model.dart';
import 'package:chat_app/chat/provider/user_list_provider.dart';
import 'package:chat_app/chat/provider/user_status_provider.dart';
import 'package:chat_app/chat/screens/chat%20screen/chat_screen.dart';
import 'package:chat_app/core/utils/chat_id.dart';
import 'package:chat_app/core/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserListTile extends ConsumerWidget {
  final UserModel user;

  const UserListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userListProvider(user));
    final notifier = ref.read(userListProvider(user).notifier);

    //all users will be displayed expect itself
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (user.photoURL != null && user.photoURL!.isNotEmpty)
          ? NetworkImage(user.photoURL!) : null,
        child: (user.photoURL == null || user.photoURL!.isEmpty)
            ? Text(user.name.isNotEmpty ? user.name[0].toLowerCase() : "U")
            : null,
      ),
      title: Text(
        user.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
// show online offline status
subtitle: Consumer(
    builder:(context,ref,_){
      final statusAsync=ref.watch(userStatusProvider(user.uid));
      return statusAsync.when(
          data: (isOnline)=>Text(
            isOnline?"Online":
            "Offline",
            style: TextStyle(
                color: isOnline?Colors.green:Colors.grey
            ),),
          error:(_,_)=>Text(user.email),
          loading: ()=>Text(user.email),
      );
    }
    ),
// Right side action button (chat,add friends, Accept friends etc)
      trailing: _buildTrailingWidget(context, ref, state, notifier),
    );
  }

  Widget _buildTrailingWidget(
      BuildContext context,
      WidgetRef ref,
      UserListTileState state,
      UserListNotifier notifier,
      ) {
    if (state.isLoading) {
      //show loading spinner while checking status
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    // already friends--> show chat button
    if (state.areFriends) {
      return MaterialButton(
        color: Colors.green,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: () => _navigateToChat(context),
        child: buttonName(Icons.chat, "Chat"),
      );
    }
//current user sent the request show pending
    if (state.requestStatus == "pending") {
      if (state.isRequestSender) {
        return ElevatedButton(
          onPressed: null,
          child: SizedBox(
            height: 32,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.pending_actions, color: Colors.black, size: 20),
                SizedBox(width: 3),
                Text(
                  "Pending",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
        );
      } else {
        //current user received the request show accept button
        return MaterialButton(
          color: Colors.orange,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onPressed: () async {
            final result = await notifier.acceptRequest();
            if (result == "success" && context.mounted) {
              showAppSnackbar(
                context: context,
                type: SnackbarType.success,
                description: "Request Accepted",
              );
            } else {
              if (context.mounted) {
                showAppSnackbar(
                  context: context,
                  type: SnackbarType.error,
                  description: "Failed:$result",
                );
              }
            }
          },
          child: buttonName(Icons.done, "Accept"),
        );
      }
    }
    //default --- not friends show add friends button
    return MaterialButton(
      elevation: 0,
      color: Colors.blueAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () async {
        final result = await notifier.sendRequest();
        if (result == "success" && context.mounted) {
          showAppSnackbar(
            context: context,
            type: SnackbarType.success,
            description: "Request Send Successfully",
          );
        } else {
          if (context.mounted) {
            showAppSnackbar(
              context: context,
              type: SnackbarType.error,
              description: result,
            );
          }
        }
      },
      child: buttonName(Icons.person, "Add Friends"),
    );
  }

  SizedBox buttonName(IconData icon, String name) {
    return SizedBox(
      height: 32,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

//Navigate to chat screen when Chat button clicked
  Future<void> _navigateToChat(BuildContext context) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final chatId = generateChatId(currentUserId, user.uid);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatId: chatId, otherUser: user),
      ),
    );
  }
//Generate unique chatId between Users
}