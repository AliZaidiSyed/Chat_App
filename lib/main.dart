import 'package:chat_app/auth/screen/user_login_screen.dart';
import 'package:chat_app/chat/provider/proviider.dart';
import 'package:chat_app/core/secrets/secret.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/wrapper_state/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';


import 'package:chat_app/core/service/notification_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


 await NotificationService().initialize();
  await NotificationService().requestPermission();
  NotificationService().initTokenListener();

  await Supabase.initialize(
    url: 'https://evtxbsiyknubexobzlif.supabase.co',
    publishableKey: 'sb_publishable_gX31YvqWS_zDwKU0xMFN0g_6QRvUqfM',
  );


  await requestPermission();


  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  runApp( ProviderScope(child: MyApp(navigatorKey: navigatorKey,)));
}

Future<void> requestPermission() async {
  await [
    Permission.camera,
    Permission.microphone,
    Permission.notification,
  ].request();
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key, required GlobalKey<NavigatorState> navigatorKey});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  void _initZegoService(user) {
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: ZegoConfig.appID,
      appSign: ZegoConfig.appSign,
      userID: user.uid,
      userName: user.displayName ?? user.email ?? "User_${user.uid.substring(0, 5)}",
      plugins: [ZegoUIKitSignalingPlugin()],
      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(),
    ).catchError((error) {
      debugPrint("Zego initialization error: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: authState.when(
        data: (user) {
          if (user != null) {

            _initZegoService(user);
            return const AuthWrapper();
          } else {
            // Uninitialize Zego service when logged out
            ZegoUIKitPrebuiltCallInvitationService().uninit();
            return const UserLoginScreen();
          }
        },
        error: (error, _) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 60, color: Colors.red),
                Text("Error: $error"),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(authStateProvider),
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}