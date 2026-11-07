import 'package:chat_app/chat/provider/user_status_provider.dart';
import 'package:chat_app/core/utils/utils.dart';
import 'package:chat_app/group_%20chats/model/group_chat_model.dart';
import 'package:chat_app/group_%20chats/provider/group_chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemberListSection extends ConsumerWidget {
  final GroupModel group;
  final String currentUserId;
  final bool isAdmin;
  final String groupId;

  const MemberListSection({
    super.key,
    required this.group,
    required this.currentUserId,
    required this.isAdmin,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: group.members.length,
      itemBuilder: (context, index) {
        final memberId = group.members[index];
        final memberAsync = ref.watch(memberInfoProvider(memberId));

        return memberAsync.when(
          data: (user) {
            if (user == null) {
              return const SizedBox.shrink();
            }
            final isCurrentUser = memberId == currentUserId;
            final isMemberAdmin = group.admins.contains(memberId);

            return Stack(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Text(user.name[0].toUpperCase())
                        : null,
                  ),
                  title: Text(user.name + (isCurrentUser ? ' (You)' : '')),
                  subtitle: Text(isMemberAdmin ? 'Admin' : 'Member'),
                  trailing: (isAdmin && !isCurrentUser)
                      ? PopupMenuButton<String>(
                    onSelected: (value) => _handleMemberAction(
                      context,
                      ref,
                      value.toString(),
                      memberId,
                      user.name,
                    ),
                    itemBuilder: (context) => [
                      if (!isMemberAdmin)
                        const PopupMenuItem(
                          value: "make_admin",
                          child: Text("Make Admin"),
                        ),
                      if (isMemberAdmin && group.admins.length > 1)
                        const PopupMenuItem(
                          value: 'remove_admin',
                          child: Text("Remove Admin"),
                        ),
                      const PopupMenuItem(
                        value: "remove",
                        child: Text(
                          "Remove from Group",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    ],

                  )
                      : null,
                ),
                Positioned(
                  bottom: 15,
                  left: 43,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final statusAsync = ref.watch(
                        userStatusProvider(user.uid),
                      );
                      return statusAsync.when(
                        data: (isOnline) => CircleAvatar(
                          radius: 5,
                          backgroundColor:
                          isOnline ? Colors.green : Colors.grey,
                        ),
                        loading: () => const CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.grey,
                        ),
                        error: (_, __) => const CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          error: (_, __) => const SizedBox.shrink(),
          loading: () => const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("Loading..."),
          ),
        );
      },
    );
  }

  Future<void> _handleMemberAction(
      BuildContext context,
      WidgetRef ref,
      String actions,
      String memberId,
      String userName,

      ) async {
    final chatService = ref.read(groupChatServiceProvider);

    if (actions == "make_admin") {
      await chatService.makeAdmin(
        groupId: groupId,
        userId: memberId,
        userName: userName,
      );
      ref.invalidate(groupStreamProvider(groupId));
      if (context.mounted) {
        showAppSnackbar(
          context: context,
          type: SnackbarType.success,
          description: "$userName is now an admin",
        );
      }
    } else if (actions == "remove_admin") {
      await chatService.removeAdmin(
        groupId: groupId,
        userId: memberId,
        userName: userName,
      );

      ref.invalidate(groupStreamProvider(groupId));
      if (context.mounted) {
        showAppSnackbar(
          context: context,
          type: SnackbarType.success,
          description: "$userName is no longer an admin",
        );
      }
    } else if (actions == "remove") {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Remove Member"),
          content: Text("Remove $userName from group?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Remove", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await chatService.removeGroupMember(
          groupId: groupId,
          userId: memberId,
          userName: userName,
        );
        ref.invalidate(groupStreamProvider(groupId));
        if (context.mounted) {
          showAppSnackbar(
            context: context,
            type: SnackbarType.success,
            description: "$userName removed from group",
          );
        }
      }
    }
  }
}