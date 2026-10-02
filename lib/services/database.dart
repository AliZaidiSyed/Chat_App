

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecto/services/shared_pref.dart';

class DatabaseMethods{
  Future addUser(Map<String,dynamic>userInfoMap , String id) async{
   await FirebaseFirestore.instance.
    collection('users').
       doc(id).
      set(userInfoMap);
  }


  Future addMessage(String chatRoomId,String messageId,
      Map<String,dynamic> messageInfoMap ) async{
    return await FirebaseFirestore.instance.
    collection("ChatRooms").
    doc(chatRoomId).
    collection('chats').
    doc(messageId).
    set(messageInfoMap);
  }


 Future updateLastMessageSend(String chatRoomId,
      Map<String,dynamic> lastMessageInfoMap) async{
    return await FirebaseFirestore.instance.
    collection("ChatRooms").
    doc(chatRoomId).
    update(lastMessageInfoMap);

  }


 static Future<QuerySnapshot> searchQuery(String username) async{
    return await FirebaseFirestore.instance.
    collection('users').
    where("SearchKey", isEqualTo: username.substring(0,1).
    toUpperCase()).
    get();

  }

  createChatRoom(
      String chatRoomId,Map<String,dynamic> chatRoomInfoMap) async {
    final snapshot = await FirebaseFirestore.instance.
    collection('ChatRooms').
    doc(chatRoomId).
    get();
    if(snapshot.exists){
      return true;
    }
    else{
      return FirebaseFirestore.instance.
      collection("ChatRooms").
      doc(chatRoomId).
      set(chatRoomInfoMap);
    }
  }
  Future<Stream<QuerySnapshot>> getChatRoomMessage(chatRoomId) async{
    return await FirebaseFirestore.instance.
    collection('ChatRooms').
    doc(chatRoomId).
    collection('chats').
    orderBy('time',descending: true).
    snapshots();


  }


  Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance.
    collection('users').
        where("username", isEqualTo: username.trim().toUpperCase()).
    get();
  }

  Future <Stream<QuerySnapshot>> getChatRooms() async{
    String? myUsername=await SharedpreferenceHelper.getuserUsername();
    return await FirebaseFirestore.instance.
    collection("ChatRooms").

    where("users", arrayContains: myUsername!).
    snapshots();
  }


  }







