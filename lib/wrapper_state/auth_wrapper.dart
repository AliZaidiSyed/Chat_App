import 'dart:async';

import 'package:chat_app/chat/screens/app_home_screen.dart';
import 'package:chat_app/wrapper_state/app_state_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper>{
   bool _isInitialized=false;



  @override
  void initState(){
    _initializedSession();
    super.initState();
  }

  Future<void> _initializedSession() async{
    try{
      final appManager=ref.read(appStateManagerProvider);
      await Future.any({
        appManager.initializedUserSession(),
        Future.delayed(
          Duration (seconds: 10),
            ()=> throw TimeoutException("Session init timed out")

        ),
      });
      if(mounted){
        setState(() {
          _isInitialized=true;  //move to home screen after init
        });
      }
    }catch(e){
      print("Error initializing session $e");
      //still allow moving even if it fails
      if(mounted){
        setState(() {
          _isInitialized=true; // prevents infinite loading
        });
      }
    }

  }
  @override
  Widget build(BuildContext context) {
    if(!_isInitialized){
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10,),
              Text("Setting up your account...."),
            ],
          ),
        ),
      );
    }

    return MainHomeScreen();
  }
}
//now keep user function logged in is working it will kept logged until user logout