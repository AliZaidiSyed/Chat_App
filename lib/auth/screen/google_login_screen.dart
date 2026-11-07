import 'package:flutter/material.dart';
import 'package:chat_app/services/google_auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/utils/utils.dart';

class GoogleLoginScreen extends ConsumerWidget{
  const GoogleLoginScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState=ref.watch(googleAuthProvider);
    final authNotifier=ref.read(googleAuthProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_){
      if(authState.error!=null){
        showAppSnackbar(description:authState.error?? "Something went wrong", context: context,type: SnackbarType.error);
        Future.delayed(Duration(milliseconds: 100), (){
          ref.read(googleAuthProvider.notifier).clearError;

        });
      }

  });
    return Column(
      children: [
        MaterialButton(
          elevation: 0,
          color: Colors.lightBlueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed:authState.isLoading
            ?null
                :(){
            authNotifier.clearError();
            authNotifier.signInWithGoogle();
            },
            child:Padding(
            padding:EdgeInsets.all(7.0),
            child:Row(
            children:[
              Image.asset(
                "assets/images/search.png",
                height: 40,
                width: 40,
                fit: BoxFit.cover,),

            SizedBox(width:15),
              Text(
            authState.isLoading?
            "Signing In"
            :"Continue with Google",
            style:TextStyle(
            fontSize:20,
            fontWeight:FontWeight.bold,
            color:Colors.black,
            letterSpacing:-0.5
            ),
            ),
            ],

            ),
            ),
            ),


          if(authState.isLoading)
            CircularProgressIndicator(color:Colors.black),

      ],

    );
}}
