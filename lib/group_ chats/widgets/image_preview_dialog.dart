import 'dart:io';

import 'package:chat_app/group_%20chats/provider/group_chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ImagePreviewDialog extends ConsumerStatefulWidget {
  final File imageFile;
  final String groupId;

  const ImagePreviewDialog({
    super.key,
    required this.imageFile,
    required this.groupId,
  });

  @override
  ConsumerState<ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends ConsumerState<ImagePreviewDialog> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUploading = ref.watch(isUploadingProvider(widget.groupId));

    return AlertDialog(
      title: const Text("Send Image?"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(widget.imageFile, height: 250, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: "Add a caption...",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(

          onPressed: isUploading ? null : () => Navigator.pop(context, null),
          child: const Text("Cancel"),
        ),
        TextButton(

          onPressed: isUploading
              ? null
              : () => Navigator.pop(context, _captionController.text.trim()),
          child: isUploading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text("Send"),
        ),
      ],
    );
  }
}