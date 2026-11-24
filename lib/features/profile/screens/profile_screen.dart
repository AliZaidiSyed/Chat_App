import 'package:chat_app/features/chat/providers/proviider.dart';
import 'package:chat_app/features/chat/providers/user_list_provider.dart';
import 'package:chat_app/features/profile/providers/user_profile_provider.dart';
import 'package:chat_app/core/widgets/app_snackbar.dart';
import 'package:chat_app/features/auth/services/google_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/theme/app_colors.dart';
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

      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
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
                          backgroundColor: AppColors.primary,
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
                    color: AppColors.muted),
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
                color: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  onPressed: () async {
                  //show confirmation dialog before logging out
                    bool? shouldLogOut=await showDialog<bool>(
                      context:context,
                      builder:(context)=> AlertDialog(
                        backgroundColor: AppColors.background,
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
                    if (shouldLogOut == true) {
                      // Capture these before signOut: auth updates may unmount
                      // ProfileScreen while the Future is in progress.
                      final navigator = Navigator.of(context);
                      final container = ProviderScope.containerOf(
                        context,
                        listen: false,
                      );

                      try {
                        await FirebaseServices().signOut();

                        // Clear all data associated with the previous user.
                        container.invalidate(profileProvider);
                        container.invalidate(userListProvider);
                        container.invalidate(requestProvider);
                        container.invalidate(usersProvider);
                        container.invalidate(chatsProvider);
                        container.invalidate(filteredUsersProvider);
                        container.invalidate(searchQueryProvider);

                        // app.dart's AuthGate automatically shows the login
                        // screen. Pop any routes on top of the auth gate.
                        if (navigator.mounted) {
                          navigator.popUntil((route) => route.isFirst);
                        }
                      } catch (error) {
                        debugPrint('Logout failed: $error');
                        if (context.mounted) {
                          showAppSnackbar(
                            context: context,
                            type: SnackbarType.error,
                            description: 'Logout failed. Please try again.',
                          );
                        }
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
