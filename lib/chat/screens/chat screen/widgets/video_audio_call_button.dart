import 'package:chat_app/chat/provider/proviider.dart';
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

    ) => ZegoSendCallInvitationButton(
  iconSize: Size(30, 30),
  buttonSize: Size(40, 40),
  resourceID: "zego_call",
  invitees: [ZegoUIKitUser(id: receiverId, name: receiverName)],
  isVideoCall: isVideo,
  onPressed: (code, message, errorInvitees) {
    final chatService=ref.read(chatServiceProvider);
    chatService.addCallHistory(
      chatId:chatId,
      isVideoCall:isVideo,
      callStatus:"_",
    );
  },

);