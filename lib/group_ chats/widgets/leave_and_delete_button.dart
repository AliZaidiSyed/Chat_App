import 'package:chat_app/core/utils/utils.dart';
import 'package:chat_app/group_%20chats/model/group_chat_model.dart';
import 'package:chat_app/group_%20chats/provider/group_chat_provider.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaveAndDeleteButton extends ConsumerWidget {
  final bool isAdmin;
  final GroupModel group;
  final String groupId;

  const LeaveAndDeleteButton({
    super.key,
    required this.isAdmin,
    required this.group,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        if (!isAdmin)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => _leaveGroup(context, ref),
              label: const Text("Leave Group"),
              icon: const Icon(Icons.exit_to_app),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        if (isAdmin)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _deleteGroup(context, ref, group),
              label: const Text("Delete Group"),
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 2),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _leaveGroup(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Leave Group"),
        content: const Text("Are you sure you want to leave the group?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Leave", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    ref.read(groupUpdateLoadingProvider(groupId).notifier).state = true;

    try {
      final result = await ref.read(groupChatServiceProvider).leaveGroup(groupId);

      if (result == 'success' && context.mounted) {
        //ref.invalidate(groupProvider);

        Navigator.popUntil(context, (route) => route.isFirst);

        showAppSnackbar(
          context: context,
          type: SnackbarType.success,
          description: 'You left the group',
        );
      } else if (context.mounted) {
        showAppSnackbar(
          context: context,
          type: SnackbarType.error,
          description: result,
        );
      }
    } finally {
      if (context.mounted) {
        ref.read(groupUpdateLoadingProvider(groupId).notifier).state = false;
      }
    }
  }

  Future<void> _deleteGroup(
      BuildContext context,
      WidgetRef ref,
      GroupModel group,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Group"),
        content: const Text(
          "Are you sure you want to delete this group? This action cannot be undone. All messages will be permanently deleted.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final doubleConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: Text(
          'Delete "${group.groupName}"?\n\nThis will permanently delete:\n• All messages\n• All media\n• Group settings',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, Delete Forever',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (doubleConfirm != true) return;

    ref.read(groupUpdateLoadingProvider(groupId).notifier).state = true;
    try {
      await ref.read(groupChatServiceProvider).setGroupTypingStatus(groupId, false);

      final result = await ref.read(groupChatServiceProvider).deleteGroup(groupId);

      if (result == 'success' && context.mounted) {
        //ref.invalidate(groupProvider);

        Navigator.popUntil(context, (route) => route.isFirst);

        showAppSnackbar(
          context: context,
          type: SnackbarType.success,
          description: 'Group deleted successfully',
        );
      } else if (context.mounted) {
        showAppSnackbar(
          context: context,
          type: SnackbarType.error,
          description: result,
        );
      }
    } finally {
      if (context.mounted) {
        ref.read(groupUpdateLoadingProvider(groupId).notifier).state = false;
      }
    }
  }
}