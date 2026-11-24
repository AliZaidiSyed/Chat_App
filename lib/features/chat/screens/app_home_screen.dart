import 'package:chat_app/features/chat/screens/chat_list_screen.dart';
import 'package:chat_app/features/profile/screens/profile_screen.dart';
import 'package:chat_app/features/chat/screens/user_list_screen.dart';
import 'package:chat_app/features/groups/screens/group_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/theme/app_colors.dart';


class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {

   int _currentIndex=0;
  //bool _hasInitialized=false;


  //screen for each tab
    final List<Widget> _screens=[

      ChatListScreen(),
      GroupScreen(),
      UserListScreen(),
      ProfileScreen(),
    ];
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.muted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showUnselectedLabels: true,
          elevation: 8,
          onTap: (index){
          setState(() {
            _currentIndex=index;
          });

          },
          items: [

            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
            BottomNavigationBarItem(icon: Icon(Icons.wechat), label: "Groups"),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),

          ],

      ),

    );





  }
}
