import 'package:connecto/Pages/home.dart';
import 'package:connecto/services/database.dart';
import 'package:connecto/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethod {
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? getCurrentUser() {
    return auth.currentUser;
  }

  Future SignOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future deleteUser() async {
    User ? user= await FirebaseAuth.instance.currentUser;
    user?.delete();
  }



  Future<User?> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();

    final GoogleSignInAccount googleSignInAccount =
    await googleSignIn.authenticate();

    final GoogleSignInAuthentication googleSignInAuthentication =
        googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
    );

    UserCredential result =
    await auth.signInWithCredential(credential);

    User? userDetail = result.user;
    String username = userDetail!.email!
        .split("@").first.trim().toUpperCase();
    String firstletter=username.substring(0,1).toUpperCase();
     await SharedpreferenceHelper.saveUserDisplayName(userDetail.displayName!);
     await SharedpreferenceHelper.saveUserEmail(userDetail.email!);
     await SharedpreferenceHelper.saveUserId(userDetail.uid);
     await SharedpreferenceHelper.saveuserUsername(username);
     await SharedpreferenceHelper.saveUserImage(userDetail.photoURL!);

    if (result!=null) {
      Map<String, dynamic> userInfoMap = {
        "Name": userDetail!.displayName,
        "Email": userDetail!.email,
        "Image": userDetail!.photoURL,
        "Id": userDetail!.uid,
        "username":username.toUpperCase(),
        "SearchKey":firstletter

      };

      await DatabaseMethods().
      addUser(userInfoMap, userDetail!.uid).
      then((value) {
       ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.green,
            content: Text("Registered Successfully",
           style: TextStyle(
                color: Colors.black,
             fontSize: 22.0,
             //fontWeight: FontWeight.bold,
          ),
            ),),
            );
        
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>Home()));

            //));


      });
    }
    return null;







  }}