import 'package:chat_app/chat/provider/proviider.dart';
import 'package:chat_app/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestScreen extends ConsumerStatefulWidget {
  const RequestScreen({super.key});

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen> {

  @override
  void initState() {
    // Returns request list as soon as screen opens
    WidgetsBinding.instance.addPostFrameCallback((_){
      ref.invalidate(requestProvider);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final requests=ref.watch(requestProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Message Requests"),
        actions: [
          IconButton(onPressed: ()=>ref.invalidate(requestProvider),
              icon: Icon(Icons.refresh)
          )
        ],
      ),
      //handle provider status (data,loading,error)
      body: requests.when(
        //case 1   successful loading requests
          data: (requestsList){
            if(requestsList.isEmpty){
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey,),
                    SizedBox(height: 15,),
                    Text("No Pending Requests",style: TextStyle(fontSize: 18,color: Colors.grey),),

                  ],
                ),
              );
            }
            //if request exists show lists of requests
            return ListView.builder(
              itemCount: requestsList.length,
                itemBuilder: (context,index){
                final request=requestsList[index];
                return Card(
                  elevation: 0,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                   //   radius: 20,
                      backgroundImage: request.photoURL!=null?
                      NetworkImage(request.photoURL!)
                          : null,
                      child: request.photoURL==null?Icon(Icons.person,size: 30,)
                          :null
                    ),
                    title: Text(request.senderName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //accept request
                        GestureDetector(
                          onTap: () async{
                            await ref.read(requestProvider.notifier).
                            acceptRequest(request.id, request.senderId);
                            if(context.mounted){
                              showAppSnackbar(
                                  context: context,
                                  type: SnackbarType.success,
                                  description: "Request Accepted",
                              );
                              //Refresh all providers while accepting
                              ref.invalidate(usersProvider);
                              //ref.invalidate()
                            }

                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.check,color: Colors.white,),
                          ),
                        ),
                        SizedBox(width: 10,),
                        //reject request
                        GestureDetector(
                          onTap: () async {
                            await ref.read(requestProvider.notifier).
                            rejectRequest(request.id);
                            if (context.mounted) {
                              showAppSnackbar(
                                context: context,
                                type: SnackbarType.success,
                                description: "Request Rejected",
                              );
                              //Refresh all providers while accepting
                            //  ref.invalidate(usersProvider);
                              //ref.invalidate()

                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close,color: Colors.white,),
                          ),
                        )
                      ],
                    ),
                  ),

                );

                }
            );

          },
          //case 2
          error: (error,_)=>
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error:$error"),
                    SizedBox(height: 10,),
                    ElevatedButton(onPressed: ()=>
                        ref.invalidate(requestProvider),
                        child: Text("Retry"),
                    ),
                    
                  ],
                ),
    ),
         //case 3 loading
          loading:()=>Center(
            child: CircularProgressIndicator(),),
      ),
    );
  }
}
