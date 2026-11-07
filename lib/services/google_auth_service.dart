import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chat_app/core/service/notification_service.dart';

class FirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void>? _initialization;

  Future<void> _initializeGoogleSignIn() {
    return _initialization ??= _googleSignIn.initialize();
  }

  Future<String> signInWithGoogle() async {
    try {
      await _initializeGoogleSignIn();

      final GoogleSignInAccount googleUser =
      await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return "Google authentication failed";
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final UserCredential cred =
      await _auth.signInWithCredential(credential);

      final User? user = cred.user;

      if (user == null) {
        return "Google sign in failed";
      }

      final userRef = _firestore.collection("users").doc(user.uid);
      final userDoc = await userRef.get();

      // Get FCM token
      final token = await NotificationService().getToken();

      await userRef.set({
        "uid": user.uid,
        "name": user.displayName ?? "",
        "email": user.email ?? "",
        "photoURL": user.photoURL ?? "",
        "isOnline": true,
        "provider": "google",
        "lastSeen": FieldValue.serverTimestamp(),
        "token": token, // Token added to Firestore user document
        if (!userDoc.exists)
          "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update user token in background/retry handler
      await NotificationService().updateUserToken(user.uid);

      return "success";
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return "Google sign in cancelled";
      }

      return e.toString();
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      if (_auth.currentUser != null) {
        await _firestore
            .collection("users")
            .doc(_auth.currentUser!.uid)
            .update({
          "isOnline": false,
          "lastSeen": FieldValue.serverTimestamp(),
        });
      }
    } finally {
      try {
        await _initializeGoogleSignIn();
        await _googleSignIn.signOut();
      } finally {
        await _auth.signOut();
      }
    }
  }
}

final googleAuthMethodProvider = Provider<FirebaseServices>((ref) {
  return FirebaseServices();
});