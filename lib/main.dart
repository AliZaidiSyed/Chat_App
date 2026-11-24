import 'package:chat_app/app/app.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';


import 'package:chat_app/core/services/notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final user = FirebaseAuth.instance.currentUser;

  debugPrint(
    'APP START - Firebase UID: ${user?.uid ?? "NULL"}',
  );



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

