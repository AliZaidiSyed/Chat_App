import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';



final appStateManagerProvider=ChangeNotifierProvider<AppStateManager>((ref){
  return AppStateManager();
});

class  AppStateManager extends ChangeNotifier with WidgetsBindingObserver{
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;


  bool _isInitialized=false;

  AppStateManager(){

    WidgetsBinding.instance.addObserver(this);
    // when class is created
    initializedUserSession();
  }
  @override
  void dispose(){
    super.dispose();
    WidgetsBinding.instance.addObserver(this);
    _setOnlineStatus(false);  //mark user offline on dispose
  }
//handle app lifecycle to update online offline  status
@override
void didChangeAppLifecycleState(AppLifecycleState state){
    switch(state){
      case AppLifecycleState.resumed:
      _setOnlineStatus(true);
      break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _setOnlineStatus(false);
         break;
        default:
          break;
    }
  }



  Future<void> initializedUserSession() async{
    if(_isInitialized) return;
    final user=_auth.currentUser;
    if(user==null) return;
    try{
      final userDoc=_firestore.collection('users').doc(user.uid);
      final snapshot=await userDoc.get();
      if(!snapshot.exists) {
        await userDoc.set(
            {
              'uid': user.uid,
              "name": user.displayName ?? "",
              "email": user.email ?? "",
              "photoURL": user.photoURL,
              "provider": _getProvider(user),
              "isOnline": true,
              "lastSeen": FieldValue.serverTimestamp(),
              "createdAt": FieldValue.serverTimestamp(),


            }
        );
      }else{
        await userDoc.update(
         {
           "isOnline":true,
           "lastSeen":FieldValue.serverTimestamp()
         }
        );
        _isInitialized=true;
        notifyListeners();

      }
    }catch(e) {
      print("Error Initializing session $e");
      _isInitialized=true;
    }
  }
  //see user online/offline
  Future<void> _setOnlineStatus(bool isOnline) async{
    final user=_auth.currentUser;
    if(user==null) return;
    try{
      await _firestore.collection("users").doc(user.uid).update({
      "isOnline":isOnline,
        "lastSeen":FieldValue.serverTimestamp(),

      });

    }catch(e){
      print("Error updating online status: $e");

    }
  }

  //public method to manually set online status
  Future<void> updateOnlineStatus(bool isOnline) async{
    await _setOnlineStatus(isOnline);
  }

  String _getProvider( User user){
    for(final info in user.providerData){
      if(info.providerId=="google.com") return "google";
      if(info.providerId=="password") return "email";
    }
    return "email";
  }
  bool get isInitialized => _isInitialized;
}