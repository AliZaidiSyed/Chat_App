import 'package:chat_app/features/chat/providers/proviider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

ZegoSendCallInvitationButton actionButton(
  bool isVideo,
  String receiverId,
  String receiverName,
  WidgetRef ref,
  String chatId,
) {
  return ZegoSendCallInvitationButton(
    iconSize: const Size(30, 30),
    buttonSize: const Size(40, 40),
    resourceID: 'zego_call',
    invitees: [ZegoUIKitUser(id: receiverId, name: receiverName)],
    isVideoCall: isVideo,
    onPressed: (code, message, errorInvitees) async {
      if (code.isEmpty) {
        debugPrint('ZEGOCLOUD invitation sent to: $receiverId');
        try {
          await ref.read(chatServiceProvider).addCallHistory(
            chatId: chatId,
            isVideoCall: isVideo,
            callStatus: '_',
          );
        } catch (error) {
          debugPrint('Failed to save call history: $error');
        }
      } else {
        debugPrint('ZEGOCLOUD invitation failed: $code - $message');
        debugPrint('Receiver ID: $receiverId');
        debugPrint('Failed invitees: $errorInvitees');
      }
    },
  );
}
