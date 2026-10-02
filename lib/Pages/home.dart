import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecto/Pages/chat_page.dart';
import 'package:connecto/Pages/profile.dart';
import 'package:connecto/services/database.dart';
import 'package:connecto/services/shared_pref.dart';
import 'package:flutter/material.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream? chatRoomStream;

  String? myUsername, myName, myEmail, picture;

  getthesharedpref() async {
    myUsername = await SharedpreferenceHelper.getuserUsername();
    myName = await SharedpreferenceHelper.getUserDisplayName();
    myEmail = await SharedpreferenceHelper.getUserEmail();
    picture = await SharedpreferenceHelper.getUserImage();
print(myUsername);

    setState(() {

    });
  }

  ontheload() async{
    await getthesharedpref();
    chatRoomStream=await DatabaseMethods().getChatRooms();
    setState(() {

    });
  }
  @override
  void initState(){
    ontheload();
    super.initState();

  }


  Widget chatRoomList(){
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (context, AsyncSnapshot snapshot){
        return snapshot!.hasData
            ?ListView.builder(
          padding: EdgeInsets.zero,
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            itemBuilder: (context,index){
            DocumentSnapshot ds=snapshot.data.docs[index];
            final data = ds.data() as Map<String, dynamic>? ?? {};


            return ChatRoomListTile(
                myUsername: myUsername!,
                chatRoomId: ds.id,
              lastMessage: data["LastMessage"] ?? "",
              time: data["LastMessageSendTs"] ?? "",
            );



        }
        ):Container();
      }
    );
  }

  TextEditingController searchcontroller = TextEditingController();
  bool search = false;
  var queryResultSet = [];
  var tempSearchStore = [];

  intialSearch(String value) {
    if (value.length == 0) {
      setState(() {
        search=false;
        queryResultSet = [];
        tempSearchStore = [];
      });
      return;
    }
    setState(() {
      search = true;
    });

    var capitalizedValue = value.substring(0, 1).toUpperCase() +
        value.substring(1);
    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethods.searchQuery(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {

          var data = docs.docs[i].data() as Map<String, dynamic>;

          if (data['username'] != myUsername) {
            queryResultSet.add(data);
          }
        }
      });

    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['username'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\ $a";
    }
    else {
      return "$a\ $b";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xff703eff),
      body: SafeArea(

        child: Container(
          margin: EdgeInsets.only(top: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(

                  children: [
                    Image.asset(
                      "assets/images/wave.png",
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,),
                    SizedBox(width: 10.0,),
                    Text("Hello, ",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold)),

                    //   SizedBox(width: 10,),


                 Spacer(),

                    GestureDetector(
                      onTap: (){
                        Navigator.push(context,MaterialPageRoute(builder: (context)=>Profile()));
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.only(right: 20.0),
                        decoration: BoxDecoration(color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(
                          Icons.person, color: Color(0xff703eff), size: 30.0,),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10.0,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  myName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),



              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text("Welcome To",

                    style: TextStyle(color: Color.fromARGB(197, 255, 255, 255),
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold)),
              ),

              SizedBox(height: 5.0,),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text("ChatUp",
                    textAlign: TextAlign.center,

                    style: TextStyle(color: Color.fromARGB(197, 255, 255, 255),
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold)),
              ),


              SizedBox(height: 30.0,),

              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))


                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 30.0,),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFececf8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: searchcontroller,
                          onChanged: (value) {
                            intialSearch(value);
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.search),
                              hintText: "Search Username"

                          ),

                        ),
                      ),
                      SizedBox(height: 20.0,),

                      Expanded(
                        child: search ?
                        ListView(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            primary: false,
                       //     shrinkWrap: true,
                            children: tempSearchStore.map((element) {
                              return buildResultCard(element);
                            }).toList(),
                                        )
                            :chatRoomList(),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () async {
        search = false;
        var chatRoomId = getChatRoomIdbyUsername(myUsername!, data['username']);
        Map<String, dynamic> chatInfoMap = {
          "users": [myUsername, data['username']],
        "LastMessage": "",
         "LastMessageSendTs": "",
         "time": FieldValue.serverTimestamp(),
        };
        await DatabaseMethods().createChatRoom(chatRoomId, chatInfoMap);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatPage(name:
        data['Name'],
            profileurl:data['Image'],
            username:data['username'])));
      },

      child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Material(
            elevation: 3.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      data['Image'],
                      height: 70,
                        width: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 20.0,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                          Text(data['Name'],
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            ),
                          ),


                        SizedBox(height: 8.0,),
                        Text(data['username'],
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                          ),
                        ),

                      ],
                    ),
                  )
                ],
              ),
            ),


          )
      ),

    );
  }
}

class ChatRoomListTile extends StatefulWidget {

  String lastMessage,chatRoomId,myUsername,time;
  ChatRoomListTile( {required this.myUsername,
    required this.chatRoomId,
    required this.lastMessage,
    required this.time});

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {

String profilePicUrl="", name="",username="", id="";


getthisUserInfo() async{
  username = widget.chatRoomId
      .replaceAll(widget.myUsername, "")
      .trim();
  QuerySnapshot querySnapShot=await DatabaseMethods().getUserInfo(username);
  name="${querySnapShot.docs[0]["Name"]}";
  profilePicUrl="${querySnapShot.docs[0]["Image"]}";
  id="${querySnapShot.docs[0]["Id"]}";
  setState(() {

  });

}

@override
void initState(){
  getthisUserInfo();
  super.initState();
}
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context,MaterialPageRoute(
            builder: (context)=>
                ChatPage(name: name!,
                    profileurl: profilePicUrl,
                    username: username!)));
      },
      child:  Material(
        elevation: 3.0,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(10)),
          width: MediaQuery
              .of(context)
              .size
              .width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              profilePicUrl==""?CircularProgressIndicator():
              ClipRRect(
                borderRadius: BorderRadius.circular(60),

                child: Image.network(profilePicUrl,
                  width: 70, height: 70,
                  fit: BoxFit.cover,),
              ),
              SizedBox(width: 10.0,),


                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10.0,),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),


                      Text(
                        widget.lastMessage,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color.fromARGB(151, 0, 0, 0),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),



              Spacer(),

              Text(
                widget.time,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(151, 0, 0, 0),
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              )


            ],
          ),

        ),
      ),


    );
  }
}


