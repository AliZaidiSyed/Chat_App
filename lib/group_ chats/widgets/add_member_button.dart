import "package:chat_app/chat/model/user_model.dart";

import "package:chat_app/core/utils/utils.dart";
import "package:chat_app/group_%20chats/model/group_chat_model.dart";
import "package:chat_app/group_%20chats/provider/group_chat_provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class AddMemberButton extends ConsumerWidget {
  final GroupModel group;
  final String groupId;

  const AddMemberButton({
    super.key,
    required this.group,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: ElevatedButton.icon(
        onPressed: () => _showAddMemberDialog(context, ref),
        label: const Text("Add Member"),
        icon: const Icon(Icons.person_add),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  Future<void> _showAddMemberDialog(BuildContext context, WidgetRef ref) async {
    // Show loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    try {
      // Fetch available users
      final availableUsers = await ref.read(
        availableMembersProvider(groupId).future,
      );

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (availableUsers.isEmpty) {
        showAppSnackbar(
          context: context,
          type: SnackbarType.error,
          description: "No friends available to add first make a friend",
        );
        return;
      }

      if (!context.mounted) return;
      _showMembersListDialog(context, ref, availableUsers);
    } catch (e) {
      print('Error fetching available members: $e'); // Added print for debugging
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog on error

      showAppSnackbar(
        context: context,
        type: SnackbarType.error,
        description: "Unable to complete process",
      );
    }
  }

  Future<void> _showMembersListDialog(
      BuildContext context,
      WidgetRef ref,
      List<UserModel> availableUsers,
      ) async {
    final chatService = ref.read(groupChatServiceProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add members"),
        content: SizedBox(
          width: double.maxFinite, // Fix for width constraint inside AlertDialog
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableUsers.length,
            itemBuilder: (context, index) {
              final user = availableUsers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? Text(user.name[0].toUpperCase())
                      : null,
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                onTap: () async {
                  Navigator.pop(context); // Close member list dialog

                  final result = await chatService.addGroupMember(
                    groupId: groupId,
                    userId: user.uid,
                    userName: user.name,
                  );

                  if (context.mounted) {
                    final isSuccess = result == "success";
                    final message = isSuccess
                        ? '${user.name} added to group'
                        : result;

                    showAppSnackbar(
                      context: context,
                      type: isSuccess
                          ? SnackbarType.success
                          : SnackbarType.error,
                      description: message,
                    );

                    // Refresh the group stream if successful
                    if (isSuccess) {
                      ref.invalidate(groupStreamProvider(groupId));
                    }
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}