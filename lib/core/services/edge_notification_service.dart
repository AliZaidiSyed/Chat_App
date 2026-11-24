
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationEdgeService {

  static Future<void> sendNotification({
    required String recipientUid,
    required String notificationId,
  }) async {

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint("Firebase user not logged in");
        return;
      }

      // Get Firebase ID token
      final idToken = await user.getIdToken();

      if (idToken == null || idToken.isEmpty) {
        debugPrint("Firebase ID token missing");
        return;
      }

      // Invoke Supabase Edge Function
      final response =
      await Supabase.instance.client.functions.invoke(
        'send-user-notification',
        headers: {
          'Authorization': 'Bearer $idToken',
        },
        body: {
          'recipientUid': recipientUid,
          'notificationId': notificationId,
        },
      );

      debugPrint(
        "Supabase notification response: ${response.data}",
      );

      if (response.status < 200 || response.status >= 300) {
        debugPrint("Notification request failed");
      }

    } catch (e) {
      // Do not break existing chat logic
      debugPrint("Edge Function error: $e");
    }
  }
}
