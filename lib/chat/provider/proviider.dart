import 'dart:async';

import 'package:chat_app/chat/model/chat_model.dart';
import 'package:chat_app/chat/model/message_request_model.dart';
import 'package:chat_app/chat/model/user_model.dart';
import 'package:chat_app/chat/service/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Auth State to keep user logged in until he logouts
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

//------Chat Service------------------////
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

//----------------USER---------------
class UserNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final ChatService _chatService;
  StreamSubscription<List<UserModel>>? _subscription;

  UserNotifier(this._chatService) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _subscription?.cancel();
    _subscription = _chatService.getAllUsers().listen(
          (users) => state = AsyncValue.data(users),
      onError: (error, stackTrace) =>
      state = AsyncValue.error(error, stackTrace),
    );
  }

  void refresh() => _init();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final usersProvider =
StateNotifierProvider<UserNotifier, AsyncValue<List<UserModel>>>((ref) {
  final service = ref.watch(chatServiceProvider);
  return UserNotifier(service);
});

//-------------Request---------------
class RequestNotifier
    extends StateNotifier<AsyncValue<List<MessageRequestModel>>> {
  final ChatService _chatService;
  StreamSubscription<List<MessageRequestModel>>? _subscription;

  RequestNotifier(this._chatService) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _subscription?.cancel();
    _subscription = _chatService.getPendingRequest().listen(
          (requests) => state = AsyncValue.data(requests),
      onError: (error, stackTrace) =>
      state = AsyncValue.error(error, stackTrace),
    );
  }

  Future<void> acceptRequest(String requestId, String senderId) async {
    await _chatService.acceptMessageRequest(requestId, senderId);
    _init();
  }

  Future<void> rejectRequest(String requestId) async {
    await _chatService.rejectMessageRequest(requestId);
    _init();
  }

  void refresh() => _init();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final requestProvider = StateNotifierProvider<
    RequestNotifier,
    AsyncValue<List<MessageRequestModel>>>((ref) {
  final service = ref.watch(chatServiceProvider);
  return RequestNotifier(service);
});

//--------------Auto refresh of auth changes------------

final autoRefreshProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<User?>>(authStateProvider, (prev, next) {
    next.whenData((user) {
      if (user != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          ref.invalidate(usersProvider);
          ref.invalidate(requestProvider);
        });
      }
    });
  });
});

//----------------CHATS-------------------
class ChatNotifier extends StateNotifier<AsyncValue<List<ChatModel>>> {
  final ChatService _chatService;
  StreamSubscription<List<ChatModel>>? _subscription;

  ChatNotifier(this._chatService) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _subscription?.cancel();
    _subscription = _chatService.getUserChats().listen(
          (chats) => state = AsyncValue.data(chats),
      onError: (error, stackTrace) =>
      state = AsyncValue.error(error, stackTrace),
    );
  }

  void refresh() => _init();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final chatsProvider =
StateNotifierProvider<ChatNotifier, AsyncValue<List<ChatModel>>>((ref) {
  final service = ref.watch(chatServiceProvider);
  return ChatNotifier(service);
});

//----------------SEARCH-------------------

final searchQueryProvider = StateProvider<String>((ref) => "");

final filteredUsersProvider = Provider<AsyncValue<List<UserModel>>>((ref) {
  final users = ref.watch(usersProvider);
  final query = ref.watch(searchQueryProvider);
  return users.when(
    data: (list) {
      if (query.isEmpty) return AsyncValue.data(list);
      return AsyncValue.data(
        list
            .where(
              (u) =>
          u.name.toLowerCase().contains(query.toLowerCase()) ||
              u.email.toLowerCase().contains(query.toLowerCase()),
        )
            .toList(),
      );
    },
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    loading: () => const AsyncValue.loading(),
  );
});

// ----------------- Typing Indicator -----------------

class TypingNotifier extends StateNotifier<Map<String, bool>> {
  final ChatService _chatService;
  StreamSubscription<Map<String, bool>>? _subscription;
  final String chatId;

  TypingNotifier(this._chatService, this.chatId) : super({}) {
    _listenToTypingStatus();
  }

  void _listenToTypingStatus() {
    _subscription?.cancel();
    _subscription = _chatService.getTypingStatus(chatId).listen(
          (typingData) => state = Map<String, bool>.from(typingData),
      onError: (error) => state = {},
    );
  }

  Future<void> setTyping(bool isTyping) async {
    await _chatService.setTypingStatus(chatId, isTyping);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final typingProvider =
StateNotifierProvider.family<TypingNotifier, Map<String, bool>, String>((
    ref,
    chatId,
    ) {
  final service = ref.watch(chatServiceProvider);
  return TypingNotifier(service, chatId);
});