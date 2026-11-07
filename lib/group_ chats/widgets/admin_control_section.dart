import 'package:chat_app/group_%20chats/model/group_chat_model.dart';
import 'package:chat_app/group_%20chats/provider/group_chat_provider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminControlsSection extends ConsumerWidget {
  final GroupModel group;
  final String groupId;

  const AdminControlsSection({
    super.key,
    required this.group,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Divider(),
        SwitchListTile.adaptive(
          title: Text("Anyone can edit group info"),
          subtitle: Text("Allow all members to edit name and photo"),
          value: group.anyoneCanEditInfo,
          onChanged: (value) => _toggleEditPermission(ref, value),
        ), // SwitchListTile.adaptive
        Divider(),
      ],
    ); // Column
  }

  Future<void> _toggleEditPermission(WidgetRef ref, bool value) async {
    await ref.read(groupChatServiceProvider).toggleGroupEditPermission(
        groupId, value);

    //add invalidations
    ref.invalidate(groupStreamProvider(groupId));


  }
}