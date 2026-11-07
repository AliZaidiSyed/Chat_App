
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/chat/model/user_profile_model.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'hide User;


class ProfileNotifier extends StateNotifier<ProfileState> {
  late final StreamSubscription<User?> _authSubscription;


  ProfileNotifier() : super(ProfileState(isLoading: true)) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {

    _authSubscription = FirebaseAuth.instance.
    authStateChanges().listen((user) {
      if (user != null) {
        if (state.userId != user.uid) {
          //only reload if it is different user
          // user logged in to load data
          loadUserData(user);
        } else {
          //user logged out clear data
          state = ProfileState(isLoading: false);
        }
      }
    });
  }

  //LOAD User data from firestore
  Future<void> loadUserData([User? user]) async {
    final currentUser = user ?? FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      state = ProfileState(isLoading: false);
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final doc = await FirebaseFirestore.instance.
      collection("users").
      doc(currentUser.uid).get();

      if (doc.exists) {
        state = ProfileState(
          photoUrl: doc.data()?['photoURL'] as String?,
          name: doc['name'],
          email: doc['email'],
          createdAt: (doc['createdAt'] as Timestamp?)?.toDate(),
          userId: currentUser.uid,
          isLoading: false,

        );
      } else {
        state = ProfileState(
          userId: currentUser.uid,
          isLoading: false,
        );
      }
    } catch (e) {
      state = ProfileState(
        userId: currentUser.uid,
        isLoading: false,
      );
    }
  }

    //force refresh user data
    void refresh() {
      loadUserData();
    }
// pick and upload new profile image
    Future<bool> updateProfilePicture() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      final picker = ImagePicker();
      final pickerFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickerFile == null) return false;
      state = state.copyWith(isUpLoading: true);
      File file = File(pickerFile.path);
      try {
        //update to Supabase storage
     final storageRef=Supabase.
     instance.client.storage.
     from("chat_files");
    final filePath="profile_pictures/${user.uid}_${DateTime.now().
    millisecondsSinceEpoch}.jpg";
    await storageRef.upload(
       filePath,
       file,
       fileOptions: const FileOptions(
         upsert: true,
         contentType: "image/jpeg",
       ),

     );
     final newUrl=storageRef.getPublicUrl(
       filePath,
     );

     // update firestore
     await FirebaseFirestore.instance.
     collection("users").
     doc(user.uid).
     update({"photoURL":newUrl});

        //  update state
        state = state.copyWith(
            photoUrl: newUrl,
            isUpLoading: false);
        return true;
      } catch (e, stackTrace) {
        print("PROFILE UPDATE ERROR: $e");
        print("STACK TRACE: $stackTrace");
        state = state.copyWith(isUpLoading: false);
        return false;
      }
    }


    @override
    void dispose() {
      _authSubscription.cancel();
      super.dispose();
    }
  }

  final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
      ref) {
    return ProfileNotifier();
  });

