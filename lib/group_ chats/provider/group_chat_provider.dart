//--------------GROUP CHAT SERVICE----------------//

import 'dart:async';

import 'package:chat_app/chat/model/user_model.dart';
import 'package:chat_app/group_%20chats/model/group_chat_model.dart';
import 'package:chat_app/group_%20chats/service/group_chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final groupChatServiceProvider=Provider<GroupChatService>(
        (ref) => GroupChatService()
);

//------------GROUP CHAT PROVIDERS-------------//

class GroupNotifier extends StateNotifier<AsyncValue<List<GroupModel>>>{
  final GroupChatService _chatService;
  StreamSubscription<List<GroupModel>> ? _subscription;
  GroupNotifier(this._chatService):super(AsyncValue.loading()){
    _init();
  }
  void  _init(){
    _subscription?.cancel();
    _subscription=_chatService.getUserGroup().listen(
        (groups)=>state=AsyncValue.data(groups),
      onError:  (e,st)=> state=AsyncValue.error(e,st),

    );
  }
  void refresh() => _init();
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();

  }
}
final groupProvider=StateNotifierProvider<GroupNotifier,AsyncValue<List<GroupModel>>> ((ref) {
  final service=ref.watch(groupChatServiceProvider);
  return GroupNotifier(service);
});

//-------------GROUP TYPING INDICATOR-----------------//

class GroupTypingNotifier extends StateNotifier<Map<String,bool>> {
  final GroupChatService _chatService;
  StreamSubscription<Map<String, bool>>? _subscription;
  final String groupId;

  GroupTypingNotifier(this._chatService, this.groupId) : super({}) {
    _listenToTypingStatus();
  }
  void _listenToTypingStatus() {
    _subscription?.cancel();
    _subscription = _chatService.getGroupTypingStatus(groupId).listen(
          (typingData) => state = Map<String, bool>.from(typingData),
      onError: (e) => state = <String, bool>{},
    );
  }

  Future<void> setTyping(bool isTyping) async{
    await _chatService.setGroupTypingStatus(groupId, isTyping);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
  final groupTypingProvider=
      StateNotifierProvider.family<
      GroupTypingNotifier,
      Map<String,bool>,
      String
     >((ref,groupId){
       final service=ref.watch(groupChatServiceProvider);
       return GroupTypingNotifier(service,groupId);
  });


// provider for typing users (coumputed from typing status),
final groupTypingUsersProvider = Provider.family<List<String>, String>((
    ref,
    groupId,
    ) {
  final typingStatus = ref.watch(groupTypingProvider(groupId));
  final typingUsers = <String>[];
  typingStatus.forEach((userId, isTyping) {
    if (isTyping) typingUsers.add(userId);
  });
  return typingUsers;
});

//real-time group updates

final groupStreamProvider=StreamProvider.family<GroupModel?,String>((
        ref,groupId,
){
  return FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .snapshots()
      .map((snapshot){
        if(!snapshot.exists) return null;
        return GroupModel.fromMap(snapshot.data()!);

  });

});

// provider for member info
final memberInfoProvider = FutureProvider.family<UserModel?, String>((
    ref,
    userId,
    ) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get();
    return doc.exists ? UserModel.fromMap(doc.data()!) : null;
  } catch (e) {
    return null;
  }
});

// create a provider that tracks loading per group
final groupUpdateLoadingProvider=StateProvider.family<bool,String>(
    (ref, groupId)=>false,
);


// Provider for available members to add (excludes current members and non-friends)
final availableMembersProvider = FutureProvider.family<List<UserModel>, String>(
      (ref, groupId) async {
    final groupDoc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .get();

    if (!groupDoc.exists) return [];

    final group = GroupModel.fromMap(groupDoc.data()!);
    final chatService = ref.read(groupChatServiceProvider);

    // Fetch all users
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    final allUsers = usersSnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();

    // Filter: only friends who are not already members
    final availableUsers = <UserModel>[];
    for (final user in allUsers) {
      if (!group.members.contains(user.uid)) {
        final areFriends = await chatService.areUserFriends(
          chatService.currentUserId,
          user.uid,
        );
        if (areFriends) {
          availableUsers.add(user);
        }
      }
    }

    return availableUsers;
  },
);



//provider for upload state only for progress tracking
final isUploadingProvider=StateProvider.family<bool, String> (
    (ref,groupId)=> false,
);