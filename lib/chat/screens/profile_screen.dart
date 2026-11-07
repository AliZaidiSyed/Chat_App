import 'package:chat_app/auth/screen/user_login_screen.dart';
import 'package:chat_app/chat/provider/proviider.dart';
import 'package:chat_app/chat/provider/user_list_provider.dart';
import 'package:chat_app/chat/provider/user_profile_provider.dart';
import 'package:chat_app/core/utils/utils.dart';
import 'package:chat_app/services/google_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';



class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

 String? lastUserId;
  @override
  Widget build(BuildContext context) {
    final profile=ref.watch(profileProvider);
    final notifier=ref.read(profileProvider.notifier);
    final currentUser=FirebaseAuth.instance.currentUser;

    if(currentUser?.uid!=lastUserId){
      lastUserId=currentUser?.uid;
      WidgetsBinding.instance.addPostFrameCallback((_){
        if (mounted) {
          notifier.refresh();
        }
      });


    }
    if(profile.isLoading){
      return Scaffold(body: Center(child: CircularProgressIndicator(),),);

    }


    return Scaffold(

      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Profile", style:
        TextStyle(
            fontWeight: FontWeight.w500),),
        actions: [
          IconButton(onPressed: ()=>notifier.refresh(),
              tooltip: "Refresh Profile",
              icon: Icon(Icons.refresh)
          ),
        ],
      ),
      body:SafeArea(child:
      Padding(
          padding:EdgeInsets.all(20),
        child: Center(
          child: Column(

            children: [
              SizedBox(height: 20,),
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: profile.photoUrl!=null?
                        NetworkImage(profile.photoUrl!)
                        :null,
                    child: profile.photoUrl==null
                    ? Icon(Icons.person,size: 30,)
                        :null
                  ),
                  Positioned(
                    bottom: 5,right: 5,
                      child: GestureDetector(
                        onTap: () async {
                          bool success=await notifier.updateProfilePicture();
                          if(success && context.mounted){
                            showAppSnackbar(
                                context: context,
                                type: SnackbarType.success,
                                description: "Profile Picture changed successfully");
                          } else if(context.mounted){
                            showAppSnackbar(
                                context: context,
                                type: SnackbarType.error,
                                description: "Failed to update profile picture");
                          }
                        },
                        child: CircleAvatar(
                          radius: 13,
                          backgroundColor: Colors.black,
                          child: Icon(Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                        ),
                      ),
                  ),
                  ),
                  if(profile.isUpLoading)
                    Positioned.fill(
                        child: Center(child: CircularProgressIndicator(),),
                    ),
                ],
              ),
              SizedBox(height: 5,),
              Text(profile.name?? "No Name",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold),),

              Text(profile.email?? "No Email",
                style: TextStyle(fontSize: 16,
                    color: Colors.black54),
              ),
              Text(
                "Joined ${profile.createdAt!=null ?
                DateFormat("MMM d, y").
                format(profile.createdAt!)
                : "Not Joined" }",
                style:TextStyle(fontSize:16,
                    color:Colors.black54),
                ),

              SizedBox(height: 20,),
              MaterialButton(
                color: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  onPressed: () async {
                  //show confirmation dialog before logging out
                    bool? shouldLogOut=await showDialog<bool>(
                      context:context,
                      builder:(context)=> AlertDialog(
                        backgroundColor: Colors.white,
                        title:Text("Logout"),
                        content:Text("Are you sure you want to logout"),
                        actions: [
                          TextButton(onPressed: ()=>Navigator.pop(context,false),
                            child: Text("Cancel"),
                          ),
                          TextButton(onPressed: ()=>Navigator.pop(context,true),
                              child: Text("Logout"),
                          ),
                        ],
                      ),
                    );
                    if(shouldLogOut==true){
                      //perform logout
                      await FirebaseServices().signOut();
                      // invalidate all providers
                      ref.invalidate(profileProvider);
                      ref.invalidate(userListProvider);
                      ref.invalidate(requestProvider);
                      ref.invalidate(usersProvider);
                      ref.invalidate(chatsProvider);
                      ref.invalidate(filteredUsersProvider);
                      ref.invalidate(searchQueryProvider);
                      if(context.mounted){
                        Navigator.pushReplacement(
                            context,
                          MaterialPageRoute(builder: (context)=>UserLoginScreen()
                          ),
                        );
                      }

                    }


                  },

                child: Padding(
                    padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.exit_to_app,
                        color: Colors.white,

                      ),
                      SizedBox(width: 5,),
                      Text(
                        "LogOut",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),


            ],
          ),
        ),
      ),

      ),
    );
  }
}
