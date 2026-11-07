import 'dart:async';
import 'dart:io';

import 'package:chat_app/chat/model/user_model.dart';
import 'package:chat_app/chat/provider/proviider.dart';
import 'package:chat_app/chat/screens/chat%20screen/widgets/call_history.dart';
import 'package:chat_app/chat/screens/chat%20screen/widgets/message_and_image_display.dart';
import 'package:chat_app/chat/screens/chat%20screen/widgets/user_chat_profile.dart';
import 'package:chat_app/chat/screens/chat%20screen/widgets/video_audio_call_button.dart';

import 'package:chat_app/core/helper/date_time_helper.dart';
import 'package:chat_app/core/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final UserModel otherUser;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUser,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  var _isUploadingImage = false;
  Timer? _readStatusTimer;

  List<String> unreadMessageIds = [];

  final FocusNode _textFieldFocusNode = FocusNode();
  Timer? _typingTimer;
  bool _isCurrentlyTyping = false;
  bool _isTextFieldFocused = false;
  Timer? _typingDebounceTimer;

  late final Stream _chatStream;

  @override
  void initState() {
    _textFieldFocusNode.addListener(() {
      if (_textFieldFocusNode.hasFocus) {
        _handleTextFieldFocus();
      } else {
        _handleTextFieldUnfocus();
      }
    });
    super.initState();
    _chatStream = ref.read(chatServiceProvider).getChatMessages(widget.chatId);
  }

  // Typing indicator handler
  void _handleTextChange(String text) {
    _typingDebounceTimer?.cancel();
    if (text.trim().isNotEmpty && _isTextFieldFocused) {
      if (!_isCurrentlyTyping) {
        _isCurrentlyTyping = true;
        ref.read(typingProvider(widget.chatId).notifier).setTyping(true);
      }
      _typingDebounceTimer = Timer(const Duration(seconds: 2), () {
        _handleTypingStop();
      });
    } else {
      _handleTypingStop();
    }
  }

  void _handleTypingStart() {
    if (!_isCurrentlyTyping) {
      _isCurrentlyTyping = true;
      ref.read(typingProvider(widget.chatId).notifier).setTyping(true);
    }
    _typingTimer?.cancel();
  }

  void _handleTypingStop() {
    if (_isCurrentlyTyping) {
      _isCurrentlyTyping = false;
      ref.read(typingProvider(widget.chatId).notifier).setTyping(false);
    }
    _typingTimer?.cancel();
  }

  void _handleTextFieldFocus() {
    _isTextFieldFocused = true;
    if (_messageController.text.trim().isNotEmpty) {
      _handleTypingStart();
    }
  }

  void _handleTextFieldUnfocus() {
    _isTextFieldFocused = false;
    _handleTypingStop();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    _messageController.clear();

    _handleTypingStop();

    final chatService = ref.read(chatServiceProvider);
    final result = await chatService.sendMessage(
      chatId: widget.chatId,
      message: message,
    );

    if (result != "success" && mounted) {
      showAppSnackbar(
        context: context,
        type: SnackbarType.error,
        description: "Failed to send message: $result",
      );
    }

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _markAsRead() async {
    _readStatusTimer?.cancel();
    _readStatusTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      final chatService = ref.read(chatServiceProvider);
      await chatService.markMessagesAsRead(widget.chatId);
      if (mounted) {
        unreadMessageIds.clear();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _readStatusTimer?.cancel();
    _textFieldFocusNode.dispose();
    _typingTimer?.cancel();
    _typingDebounceTimer?.cancel();
    if (_isCurrentlyTyping) {
      ref.read(typingProvider(widget.chatId).notifier).setTyping(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.white,
        title: UserChatProfile(widget: widget),
        actions: [
          actionButton(
            false,
            widget.otherUser.uid,
            widget.otherUser.name,
            ref,
            widget.chatId,
          ),
          actionButton(
            true,
            widget.otherUser.uid,
            widget.otherUser.name,
            ref,
            widget.chatId,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == "unfriend") {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Unfriend User"),
                    content: Text(
                      "Are you sure you want to unfriend ${widget.otherUser.name}?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Unfriend",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (result == true && mounted) {
                  final unfriendResult = await ref
                      .read(chatServiceProvider)
                      .unfriendUser(widget.chatId, widget.otherUser.uid);

                  if (unfriendResult == "success" && mounted) {
                    showAppSnackbar(
                      context: context,
                      type: SnackbarType.success,
                      description: "Friendship disconnected",
                    );
                    Navigator.pop(context);
                  }
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: "unfriend",
                child: Text("Unfriend"),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _chatStream,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final messages = snapshot.data ?? [];

                if (snapshot.hasData && messages.isNotEmpty) {
                  final currentUserId =
                      FirebaseAuth.instance.currentUser?.uid ?? '';
                  final hasUnreadMessages = messages.any(
                        (msg) =>
                    msg.senderId != currentUserId &&
                        !(msg.readBy?.containsKey(currentUserId) ?? false),
                  );
                  if (hasUnreadMessages) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _markAsRead();
                    });
                  }
                }

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "No messages yet. Start the conversation!",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final currentUid =
                        FirebaseAuth.instance.currentUser?.uid ?? '';
                    final isMe = message.senderId == currentUid;
                    final isSystem = message.type == "system";
                    final isVideo = message.callType == "video";
                    final isMissed = message.callStatus == "missed";
                    final showDateHeader =
                    shouldShowDateHeader(messages, index);

                    return Column(
                      children: [
                        if (isSystem)
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              message.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        else if (message.type == "call")
                          CallHistory(
                            isMe: isMe,
                            widget: widget,
                            isMissed: isMissed,
                            isVideo: isVideo,
                            message: message,
                          )
                        else
                          MessageAndImageDisplay(
                            isMe: isMe,
                            widget: widget,
                            message: message,
                          ),
                        if (showDateHeader)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: [
                                const Expanded(child: Divider()),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    formatDateHeader(message.timestamp),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Message input bar
          Container(
            padding: const EdgeInsets.only(
              top: 5,
              right: 10,
              left: 10,
              bottom: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, -1),
                  color: Colors.grey.withAlpha(100),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed:
                  _isUploadingImage ? null : () => _showImageOption(),
                  icon: Icon(
                    Icons.image,
                    size: 30,
                    color: _isUploadingImage ? Colors.grey : Colors.blue,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _textFieldFocusNode,
                    decoration: InputDecoration(
                      hintText: "Text a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLength: null,
                    onSubmitted: (value) => _sendMessage(),
                    onChanged: _handleTextChange,
                    onTap: _handleTextFieldFocus,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isUploadingImage ? null : _sendMessage,
                  mini: true,
                  elevation: 0,
                  backgroundColor: Colors.grey.shade300,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: _isUploadingImage
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(
                      Icons.send,
                      color: Colors.blueAccent,
                      size: 27,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageOption() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text("Cancel"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickerFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (pickerFile != null && mounted) {
        final File imageFile = File(pickerFile.path);
        await _showImagePreview(imageFile);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackbar(
          context: context,
          type: SnackbarType.error,
          description: "Error picking image",
        );
      }
    }
  }

  Future<void> _showImagePreview(File imageFile) async {
    final TextEditingController captionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(16),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                  cacheHeight: 600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Add a caption...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Send"),
          ),
        ],
      ),
    );

    final caption = captionController.text.trim();

    Future.delayed(const Duration(milliseconds: 500), () {
      captionController.dispose();
    });

    if (result == true && mounted) {
      await _sendImageMessage(imageFile, caption);
    }
  }

  Future<void> _sendImageMessage(File imageFile, String caption) async {
    if (!mounted) return;
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final chatService = ref.read(chatServiceProvider);
      final result = await chatService.sendImageWithUpload(
        chatId: widget.chatId,
        imageFile: imageFile,
        caption: caption.isEmpty ? null : caption,
      );

      if (result == "success") {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scrollController.hasClients) {
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      } else {
        if (mounted) {
          showAppSnackbar(
            context: context,
            type: SnackbarType.error,
            description: "Failed to send image: $result",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showAppSnackbar(
          context: context,
          type: SnackbarType.error,
          description: "Failed to send image",
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }
}