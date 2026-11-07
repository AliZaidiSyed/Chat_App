import 'package:chat_app/chat/provider/proviider.dart';
import 'package:chat_app/chat/widgets/user_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
 ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
@override
  void initState() {

    super.initState();


  WidgetsBinding.instance.addPostFrameCallback((_){
    ref.invalidate(usersProvider);
    });
  }
 Future<void> onRefresh() async{
   // clear friendship cache before refreshing
   ref.invalidate(usersProvider);
   ref.invalidate(requestProvider);
   await Future.delayed(Duration(milliseconds: 500));
 }
  @override
  Widget build(BuildContext context) {
   // watch the auto refresh provider to trigger refreshes
    ref.watch(autoRefreshProvider);
    final users=ref.watch(filteredUsersProvider);
    final searchQuery=ref.watch(searchQueryProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("All users"),
        backgroundColor: Colors.white,
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(56), 
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10
            ),
            child: TextField(
              onChanged: (value)=>ref.read(searchQueryProvider.notifier).state=value,
              decoration: InputDecoration(
                hintText: 'Search user by name or email...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                  ?IconButton(
                    onPressed:()=> ref.read(searchQueryProvider.notifier).state="",
                    icon: Icon(Icons.clear)
                )
                    :null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25)),

              ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              ),

            ),
            ),

        ),

      ),
      body: RefreshIndicator(
          onRefresh: onRefresh,
          backgroundColor: Colors.white,
          child:users.when(
              data: (userList){
            if(userList.isEmpty && searchQuery.isNotEmpty) {
              return ListView(
                children: [
                  SizedBox(height: 200,),
                  Center(child: Text("No Users found matching your search"),),
                ],
              );
            }

              if(userList.isEmpty){
                return ListView(
                  children: [
                    SizedBox(height: 200,),
                    Center(child: Text("No other users found"),),
                  ],
                );
              }
              return ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                  itemCount: userList.length,
                  itemBuilder: (context,index){
                    final user=userList[index];
                    return UserListTile(user:user);
                  }
              );
            },
          error:(error,_)=>ListView(
            children: [
              SizedBox(height: 200,),
              Center(
                child: Column(
                  children: [
                    Text("Error, $error"),
                    SizedBox(height: 16,),
                    ElevatedButton(
                        onPressed: ()=> ref.invalidate(usersProvider),
                      child: Text("Retry"),
                    ),



                  ],
                ),
              )
            ],

          ),

          loading:()=> Center(child: CircularProgressIndicator(),))

      ),
      );


  }
}
