import 'package:chat_app/chat/screens/chat_list_screen.dart';
import 'package:chat_app/chat/screens/profile_screen.dart';
import 'package:chat_app/chat/screens/user_list_screen.dart';
import 'package:chat_app/group_%20chats/screens/group_screen.dart';
import 'package:flutter/material.dart';


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
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: Colors.grey.shade50,
          elevation: 0,
          unselectedFontSize: 14,
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
