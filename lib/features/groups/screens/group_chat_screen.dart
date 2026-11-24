import 'dart:async';
import 'dart:io';

import 'package:chat_app/features/chat/screens/chat_screen/widgets/dot_indicator.dart';
import 'package:chat_app/core/widgets/app_snackbar.dart';
import 'package:chat_app/features/groups/models/group_chat_model.dart';
import 'package:chat_app/features/groups/providers/group_chat_provider.dart';
import 'package:chat_app/features/groups/screens/group_info_screen.dart';
import 'package:chat_app/features/groups/services/group_chat_service.dart';
import 'package:chat_app/features/groups/widgets/chat_input_bar.dart';
import 'package:chat_app/features/groups/widgets/chat_message_list.dart';
import 'package:chat_app/features/groups/widgets/group_audio_video_call_button.dart';
import 'package:chat_app/features/groups/widgets/group_member_count.dart';
import 'package:chat_app/features/groups/widgets/image_preview_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class GroupChatScreen extends ConsumerStatefulWidget {
  final GroupModel group;
  const GroupChatScreen({super.key, required this.group});

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  Future<void> _markMessagesAsRead() async {
    await ref.read(groupChatServiceProvider).markGroupMessagesAsRead(widget.group.groupId);
  }

  void _onTextChange(String text) {
    if (!mounted) return;
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      ref.read(groupTypingProvider(widget.group.groupId).notifier).setTyping(true);
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_isTyping) {
        _isTyping = false;
        ref.read(groupTypingProvider(widget.group.groupId).notifier).setTyping(false);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    _isTyping = false;
    ref.read(groupTypingProvider(widget.group.groupId).notifier).setTyping(false);

    final result = await ref.read(groupChatServiceProvider).sendGroupMessage(
      groupId: widget.group.groupId,
      message: text,
    );
    if (result != 'success' && mounted) {
      showAppSnackbar(
        context: context,
        type: SnackbarType.error,
        description: "Unable to complete a process",
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final pickerFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickerFile != null && mounted) {
      _showImagePreviewDialog(File(pickerFile.path));
    }
  }

  void _showImagePreviewDialog(File imageFile) async {
    final String? caption = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => ImagePreviewDialog(
        imageFile: imageFile,
        groupId: widget.group.groupId,
      ),
    );
    if (caption != null && mounted) {
      await _uploadAndSendImage(imageFile, caption);
    }
  }

  Future<void> _uploadAndSendImage(File imageFile, String caption) async {
    if (!mounted) return;
    ref.read(isUploadingProvider(widget.group.groupId).notifier).state = true;
    try {
      final imageUrl = await ref
          .read(groupChatServiceProvider)
          .uploadImage(imageFile, widget.group.groupId);

      if (!mounted) return;
      if (imageUrl.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        await ref.read(groupChatServiceProvider).sendGroupImageMessage(
          groupId: widget.group.groupId,
          imageUrl: imageUrl,
          caption: caption,
        );
        if (!mounted) return;
        showAppSnackbar(
          context: context,
          type: SnackbarType.success,
          description: "Image send successfully",
        );
      } else {
        showAppSnackbar(
          context: context,
          type: SnackbarType.error,
          description: "Failed to send image",
        );
      }
    } catch (e) {
      if (mounted) {
        showAppSnackbar(
          context: context,
          type: SnackbarType.error,
          description: "Unable to complete process",
        );
      }
    } finally {
      if (mounted) {
        ref.read(isUploadingProvider(widget.group.groupId).notifier).state = false;
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _typingTimer?.cancel();
    try {
      GroupChatService().markGroupMessagesAsRead(widget.group.groupId);
      GroupChatService().setGroupTypingStatus(widget.group.groupId, false);
    } catch (e) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isMember = widget.group.members.contains(currentUserId);
    final typingUsers = ref.watch(groupTypingUsersProvider(widget.group.groupId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          GroupAudioVideoCallButton(group: widget.group, isVideoCall: false),
          GroupAudioVideoCallButton(group: widget.group, isVideoCall: true),
          const SizedBox(width: 8),
        ],
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupInfoScreen(groupId: widget.group.groupId),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: widget.group.groupPhotoURL != null
                    ? NetworkImage(widget.group.groupPhotoURL!)
                    : null,
                child: widget.group.groupPhotoURL == null ? const Icon(Icons.group) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.group.groupName,
                      style: const TextStyle(fontSize: 16),
                    ),
                    typingUsers.isNotEmpty
                        ? const Row(
                      children: [
                        Text(
                          "Typing",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                        ThreeDots(),
                      ],
                    )
                        : GroupMemberCount(
                      groupId: widget.group.groupId,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      suffix: "members",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessageList(
              groupId: widget.group.groupId,
              scrollController: _scrollController,
            ),
          ),
          isMember
              ? ChatInputBar(
            groupId: widget.group.groupId,
            messageController: _messageController,
            onTextChange: _onTextChange,
            onSendMessage: _sendMessage,
            onSendImage: _sendImage,
          )
              : Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            color: Colors.grey[200],
            child: const Text(
              "You can't send messages to this group because you're no longer a participant.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}