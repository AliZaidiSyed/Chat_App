import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/service/notification_service.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return "Please enter all fields";
      }
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update User Profile
      await cred.user!.updateDisplayName(name);

      // Get FCM token
      final token = await NotificationService().getToken();

      await _firestore.collection("users").doc(cred.user!.uid).set({
        "uid": cred.user!.uid,
        "name": name,
        "email": email,
        "isOnline": true,
        "provider": "email",
        "lastSeen": FieldValue.serverTimestamp(),
        "createdAt": FieldValue.serverTimestamp(),
        "token": token,
      });

      // Update user token & retry if needed
      await NotificationService().updateUserToken(cred.user!.uid);

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Please enter all fields";
      }
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (_auth.currentUser != null) {
        final token = await NotificationService().getToken();

        await _firestore.collection("users").doc(_auth.currentUser!.uid).update({
          "isOnline": true,
          "lastSeen": FieldValue.serverTimestamp(),
          "token": token,
        });

        // Update user token & retry if needed
        await NotificationService().updateUserToken(_auth.currentUser!.uid);
      }
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    if (_auth.currentUser != null) {
      await _firestore.collection("users").doc(_auth.currentUser!.uid).update({
        "isOnline": false,
        "lastSeen": FieldValue.serverTimestamp(),
      });
    }
    await _auth.signOut();
  }
}

final authMethodProvider = Provider<AuthMethod>((ref) {
  return AuthMethod();
});