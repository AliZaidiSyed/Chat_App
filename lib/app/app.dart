import 'dart:async';

import 'package:chat_app/app/auth_wrapper.dart';
import 'package:chat_app/core/config/zego_config.dart';
import 'package:chat_app/core/theme/app_colors.dart';
import 'package:chat_app/features/auth/screens/user_login_screen.dart';
import 'package:chat_app/features/chat/providers/proviider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key, required GlobalKey<NavigatorState> navigatorKey});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<User?>? _authSubscription;
  Future<void> _zegoOperation = Future<void>.value();
  String? _initializedUserId;

  @override
  void initState() {
    super.initState();
    // Keep ZEGOCLOUD lifecycle separate from MaterialApp rebuilds.
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) => _queueZegoUpdate(user),
      onError: (Object error) {
        debugPrint('Firebase auth stream error: $error');
      },
    );
  }

  void _queueZegoUpdate(User? user) {
    _zegoOperation = _zegoOperation
        .then((_) => _syncZegoService(user))
        .catchError((Object error) {
      debugPrint('ZEGOCLOUD operation error: $error');
    });
  }

  Future<void> _syncZegoService(User? user) async {
    if (!mounted) return;

    final service = ZegoUIKitPrebuiltCallInvitationService();

    if (user == null) {
      if (_initializedUserId != null) {
        await service.uninit();
        _initializedUserId = null;
        debugPrint('ZEGOCLOUD uninitialized after logout');
      }
      return;
    }

    if (_initializedUserId == user.uid) return;

    if (_initializedUserId != null) {
      await service.uninit();
      _initializedUserId = null;
    }

    final displayName = user.displayName?.trim();
    final email = user.email?.trim();
    final userName = displayName != null && displayName.isNotEmpty
        ? displayName
        : (email != null && email.isNotEmpty ? email : 'User');

    try {
      await service.init(
        appID: ZegoConfig.appID,
        appSign: ZegoConfig.appSign,
        userID: user.uid,
        userName: userName,
        plugins: [ZegoUIKitSignalingPlugin()],
        invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(),
      );
      _initializedUserId = user.uid;
      debugPrint('ZEGOCLOUD initialized for user: ${user.uid}');
    } catch (error) {
      _initializedUserId = null;
      debugPrint('ZEGOCLOUD initialization failed: $error');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _zegoOperation.then((_) async {
      if (_initializedUserId != null) {
        await ZegoUIKitPrebuiltCallInvitationService().uninit();
        _initializedUserId = null;
      }
    }).catchError((Object error) {
      debugPrint('ZEGOCLOUD cleanup error: $error');
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      // Keep a permanent root route. Authentication decides its contents,
      // instead of swapping the MaterialApp.home route itself.
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) => user != null
          ? const AuthWrapper()
          : const UserLoginScreen(),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 60, color: Colors.red),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(authStateProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
