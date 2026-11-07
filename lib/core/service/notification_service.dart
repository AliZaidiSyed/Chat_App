import 'dart:io';

import 'package:chat_app/services/retry_token_update.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
  // Background messages are automatically shown by FCM
}

class NotificationService {

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'chat_messages_channel',
    'Chat Messages',
    description: 'This channel is used for chat message notifications',
    importance: Importance.high,
    playSound: true,
  );

  // initialization method
  Future<void> initialize() async {
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
     settings: initSettings,
     onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      _channel,
    );

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check if app was opened from a terminated state notification
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }


  // Handle when notification is tapped
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped with payload: ${response.payload}');
    // You can navigate to chat screen here using the payload (chatId)
    // We'll handle this in main.dart using a StreamController
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.notification?.title}');
    final notification = message.notification;
    if (notification != null) {
      await _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            // icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            icon: 'ic_notification',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['chatId'],
      );
    }
  }

  // Handle when app is opened from background notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.data}');
  }

  Future<String?> getToken() async {
    try {

      if (Platform.isIOS) {

        String? apnsToken;
        try {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken().timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              print('APNs token timeout - will retry later');
              return null;
            },
          );
        } catch (e) {
          print('Error getting APNs token: $e');

        }

        if (apnsToken == null) {
          print('APNs token not available yet, getting FCM token anyway');
        }
      }


      final token = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }


  void initTokenListener() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('FCM token refreshed: $newToken');

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'token': newToken});
      }
    });
  }


  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }


  Future<void> updateUserToken(String uid) async {
    final token = await getToken();
    if (token == null) {
      print('FCM token null, retrying later');
     retryTokenUpdate(uid);
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'token': token,
      'lastSeen': FieldValue.serverTimestamp(),
      'isOnline': true,
    });
  }
}