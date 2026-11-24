
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chat_app/core/services/notification_service.dart';

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
      // Initialize Google Sign-In
      await _initializeGoogleSignIn();

      // Select Google account
      final GoogleSignInAccount googleUser =
      await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return "Google authentication failed";
      }

      // Create Firebase credential
      final OAuthCredential credential =
      GoogleAuthProvider.credential(
        idToken: idToken,
      );

      // Sign in to Firebase
      final UserCredential cred =
      await _auth.signInWithCredential(credential);

      final User? user = cred.user;

      if (user == null) {
        return "Google sign in failed";
      }

      debugPrint(
        "Google Sign-In successful: ${user.uid}",
      );


      try {
        final userRef =
        _firestore.collection("users").doc(user.uid);

        final userDoc = await userRef.get();

        // Get FCM token
        final token =
        await NotificationService().getToken();

        // Save or update user information
        await userRef.set({
          "uid": user.uid,
          "name": user.displayName ?? "",
          "email": user.email ?? "",
          "photoURL": user.photoURL ?? "",
          "isOnline": true,
          "provider": "google",
          "lastSeen": FieldValue.serverTimestamp(),
          "token": token,
          if (!userDoc.exists)
            "createdAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Update FCM token
        await NotificationService()
            .updateUserToken(user.uid);

        debugPrint(
          "Google user data updated successfully",
        );
      } catch (e, stackTrace) {
        debugPrint(
          "Post-login account setup failed: $e",
        );

        debugPrintStack(
          stackTrace: stackTrace,
        );
      }

      return "success";
    } on GoogleSignInException catch (e) {
      if (e.code ==
          GoogleSignInExceptionCode.canceled) {
        return "Google sign in cancelled";
      }

      debugPrint("Google Sign-In exception: $e");
      return e.toString();
    } on FirebaseAuthException catch (e) {
      debugPrint(
        "Firebase authentication error: ${e.code}",
      );

      return e.message ?? e.code;
    } catch (e) {
      debugPrint("Google Sign-In error: $e");
      return e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _firestore
            .collection("users")
            .doc(currentUser.uid)
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

// Riverpod provider
final googleAuthMethodProvider =
Provider<FirebaseServices>((ref) {
  return FirebaseServices();
});
