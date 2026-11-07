import 'package:chat_app/chat/model/user_list_model.dart';
import 'package:chat_app/chat/model/user_model.dart';
import 'package:chat_app/chat/provider/proviider.dart';
import 'package:chat_app/chat/service/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class UserListNotifier extends StateNotifier<UserListTileState> {

  final Ref ref;
  final UserModel user;

  UserListNotifier(this.ref, this.user) :super(UserListTileState()) {
    _checkRelationship();
  }
// Check the status
  Future<void> _checkRelationship() async {
    final chatService = ref.read(chatServiceProvider);

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) return;

    final friends = await chatService.areUserFriends(
      currentUserId,
      user.uid,
    );

    if (friends) {
      state = state.copyWith(
        areFriends: true,
        requestStatus: null,
        isRequestSender: false,
        pendingRequestId: null,
      );
      return;
    }

    final senderRequestId = '${currentUserId}_${user.uid}';
    final receiverRequestId = '${user.uid}_$currentUserId';

    final senderRequestDoc = await FirebaseFirestore.instance
        .collection('messageRequests')
        .doc(senderRequestId)
        .get();

    final receiverRequestDoc = await FirebaseFirestore.instance
        .collection('messageRequests')
        .doc(receiverRequestId)
        .get();

    String? finalStatus;
    bool isSender = false;
    String? requestId;

    // Check sent request
    if (senderRequestDoc.exists) {
      final sentStatus = senderRequestDoc.data()?['status'];

      if (sentStatus == 'pending') {
        finalStatus = 'pending';
        isSender = true;
        requestId = senderRequestId;
      }
    }

    // Check received request
    if (receiverRequestDoc.exists && finalStatus == null) {
      final receivedStatus = receiverRequestDoc.data()?['status'];

      if (receivedStatus == 'pending') {
        finalStatus = 'pending';
        isSender = false;
        requestId = receiverRequestId;
      }
    }

    // Update state outside both if blocks
    state = state.copyWith(
      areFriends: false,
      requestStatus: finalStatus,
      isRequestSender: isSender,
      pendingRequestId: requestId,
    );
  } // _checkRelationship ends here


// Send request — separate method
  Future<String> sendRequest() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    //if (currentUserId == null) {
      //return 'User not logged in';
   // }

    state = state.copyWith(isLoading: true);

    final chatservice = ref.read(chatServiceProvider);

    final result = await chatservice.sendMessageRequest(
      receiverId: user.uid,
      receiverName: user.name,
      receiverEmail: user.email,
    );

    if (result == 'success') {
      state = state.copyWith(
        isLoading: false,
        requestStatus: 'pending',
        isRequestSender: true,
        pendingRequestId: '${currentUserId}_${user.uid}',
      );
    } else {
      state = state.copyWith(isLoading: false);
    }

    return result;
  }

Future<String> acceptRequest() async{
    if(state.pendingRequestId==null) return "no-result";
    final chatService=ref.read(chatServiceProvider);
    final result=await chatService.acceptMessageRequest(
        state.pendingRequestId!,
      user.uid,
    );
    if(result=="success"){
      state=state.copyWith(
        isLoading: false,
        areFriends: true,
        requestStatus: null,
        isRequestSender: false,
        pendingRequestId: null,
      );
      //refresh providers
      ref.invalidate(requestProvider);
       ref.invalidate(chatsProvider);
    }else{
      state=state.copyWith(isLoading: false);
    }
    return result;
}


}

final userListProvider=
    StateNotifierProvider.family<
UserListNotifier,
    UserListTileState,
    UserModel
    >((ref,user)=> UserListNotifier(ref,user));