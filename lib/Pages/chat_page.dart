import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecto/services/database.dart';
import 'package:connecto/services/shared_pref.dart';

//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  String name,profileurl,username;


  ChatPage({ required this.name,required this.profileurl,required this.username});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  TextEditingController messagecontroller=  TextEditingController();
Stream? messageStream;
File? selectedImage;
final ImagePicker _picker=ImagePicker();

  String? myUsername,myName,myEmail,picture,chatRoomId,messageId;

  Future<void> getthesharedpref() async{
    myUsername=await SharedpreferenceHelper.getuserUsername();
    myName=await SharedpreferenceHelper.getUserDisplayName();
    myEmail=await SharedpreferenceHelper.getUserEmail();
    picture=await SharedpreferenceHelper.getUserImage();
    chatRoomId=getChatRoomIdbyUsername(widget.username, myUsername!);

    setState(() {

    });
  }
bool _isRecording=false;
  String? _filePath;
  final FlutterSoundRecorder _recorder=  FlutterSoundRecorder();

  Future<void> _initialize() async {
    await _recorder.openRecorder();
    var tempDir=await getTemporaryDirectory();
    _filePath="${tempDir.path}/audio.aac";

  }


  Future<bool> _requestPermission() async {
    var status = await Permission.microphone.status;

    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    return status.isGranted;
  }




Future<void> _startRecording() async{
    await _requestPermission();
    await _recorder.startRecorder(toFile:_filePath);
    setState(() {
      _isRecording=true;
    });
    Navigator.pop(context);
    openRecording();
}

Future<void> _stopRecording() async{
    await _recorder.stopRecorder();
    setState(() {
      _isRecording=false;
    });
    Navigator.pop(context);
    openRecording();
}





  ontheload() async{
    await getthesharedpref();
    await getandSetMessages();
    setState(() {

    });

  }
@override
  void initState(){

    ontheload();
    _initialize();
    super.initState();


  }

  Future<void> _uploadFile() async{
    ScaffoldMessenger.of(context).
    showSnackBar(SnackBar(
      backgroundColor: Colors.redAccent,
        content:
        Text("Your Audio is Uploading Please Wait...",
          style: TextStyle(fontSize: 20.0),)
    ));

    File file= File(_filePath!);


    try {
      String filePath="uploads/${randomAlphaNumeric(10)}.aac";
      await Supabase.instance.client.storage.
      from("chat_files").
      upload(filePath, file);
      String downloadUrl=Supabase.instance.client.
      storage.
      from("chat_files").
      getPublicUrl(filePath);
      DateTime now = DateTime.now();
      String formattedDate = DateFormat("h:mm a").format(now);
      Map<String, dynamic> messageInfoMap = {
        "Data": "Audio",
        "message": downloadUrl,
        "sendBy": myUsername,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "ImgUrl": picture,
      };
      messageId = randomAlphaNumeric(10);
      await DatabaseMethods().addMessage(
          chatRoomId!, messageId!, messageInfoMap).
      then((value) {
        Map<String, dynamic> LastMessageInfoMap = {
          "LastMessage": "Audio",
          "LastMessageSendTs": formattedDate,
          "LastMessageSendBy": myUsername,


          "time": FieldValue.serverTimestamp(),
          "ImgUrl": picture,
        };
        DatabaseMethods().updateLastMessageSend(
            chatRoomId!, LastMessageInfoMap);
      });
    }catch (e){
        print("Error Uploading Audio");
      
    }
  }


  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playAudio(String url) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint('Audio playback error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio not played'),
        ),
      );
    }
  }



  Widget chatMessageTile(String message, bool sendByMe,String Data){
    return Row(
      mainAxisAlignment:sendByMe?
      MainAxisAlignment.end:
      MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(horizontal: 14,vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
    topLeft:Radius.circular(30),
    bottomRight: sendByMe?Radius.circular(0):Radius.circular(30),
    topRight: Radius.circular(30),
    bottomLeft: sendByMe?Radius.circular(30):Radius.circular(0),
            ),
    color: sendByMe?
    Colors.black45:
    Colors.blue
          ),
            child: Data=="Image"
              ?Image.network(message,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ):Data=="Audio"
                       ?Row(
            mainAxisSize: MainAxisSize.min,
          children: [
                  IconButton(
                        icon: const Icon(
                      Icons.play_arrow,
                          color: Colors.white,
    ),
                 onPressed: () => _playAudio(message),
    ),
                          const Text(
                                      'Audio',
                                        style: TextStyle(
                                        color: Colors.white,
                                              fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                  ),
                                  ),
                                IconButton(
                                      icon: const Icon(
                                            Icons.stop,
                                                color: Colors.white,
                                                ),
                                                  onPressed: () async {
                                            await _audioPlayer.stop();
    },
    ),
    ],
    )



                :Text(message,
              style:
            TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),)
        )
        ),
      ],
    );
  }

  Future<void> _uploadImage() async{
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.redAccent,
        content:
        Text("Your Image is Uploading Please Wait",
          style: TextStyle(fontSize: 20),
        ),
    ));
    try{
      String addId=randomAlphaNumeric(10);
      String filePath="BlogImage/$addId";
      await Supabase.instance.client.storage.from("chat_files").upload(filePath, selectedImage!);
      var downloadUrl=Supabase.instance.client.storage.from("chat_files").getPublicUrl(filePath);
      DateTime now=DateTime.now();
      String formattedDate = DateFormat("h:mm a").format(now);
      Map<String,dynamic> messageInfoMap={
        "Data":"Image",
        "message":downloadUrl,
        "sendBy":myUsername,
        "ts":formattedDate,
        "time":FieldValue.serverTimestamp(),
        "ImgUrl":picture,
      };

      messageId=randomAlphaNumeric(10);
      await DatabaseMethods().addMessage(chatRoomId!, messageId!, messageInfoMap)
      .then((value) {
    Map<String,dynamic> lastMessageInfoMap={
    "LastMessage":"Image",
    "LastMessageSendTs":formattedDate,
    "time":FieldValue.serverTimestamp(),
      "LastMessageSendBy": myUsername,
    };

      DatabaseMethods().
    updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
  });
  }
  catch(e){
      print("error Uploading Image");
    }

  }


  getandSetMessages() async{
    messageStream=await DatabaseMethods().getChatRoomMessage(chatRoomId);
      setState(() {

      });
    }

    Future getImage() async{
    var image= await ImagePicker().pickImage(source:ImageSource.gallery);
    selectedImage=File(image!.path);
    _uploadImage();
    setState(() {

    });
    }






  Widget chatMessage() {
    return StreamBuilder(
    stream:messageStream,
      builder: (context, AsyncSnapshot snapshot) {
      return snapshot.hasData
    ?  ListView.builder(
        itemCount: snapshot.data.docs.length,
          reverse: true,
          itemBuilder:(context,index) {
          DocumentSnapshot ds=snapshot.data.docs[index];
          return chatMessageTile(ds['message'],
              myUsername==ds['sendBy'],ds["Data"]

          );

      })
          :Container();

      },

    );
  }
  getChatRoomIdbyUsername(String a, String b){
    if(a.substring(0,1).codeUnitAt(0)>b.substring(0,1).codeUnitAt(0)){
      return "$b\ $a";
    }
    else{
      return "$a\ $b";
    }
  }


  //to send message to another user
  addMessage(bool sendClicked) async {
    if(messagecontroller.text!="") {
      String message = messagecontroller.text;
      messagecontroller.text = "";

      DateTime now = DateTime.now();
      String formattedDate = DateFormat("h:mm a").format(now);
      Map<String, dynamic> messageInfoMap = {
        "Data":"Message",
        "message": message,
        "sendBy": myUsername,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "ImgUrl": picture,

      };

      messageId=randomAlphaNumeric(10);

      await DatabaseMethods().
      addMessage(chatRoomId!, messageId!, messageInfoMap).then((value){
        Map<String, dynamic> lastMessageInfoMap = {
          "LastMessage": message,
          "LastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "LastMessageSendBy": myUsername,
        };
        DatabaseMethods().updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
        if(sendClicked){
          message="";
        }
      });
      }

    }
    
  @override
  Widget build(BuildContext context) {


    return Scaffold(
    // resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xff703eff),
      body: SafeArea(
        child: Container(
        //  margin: EdgeInsets.only(left: 40.0),
          child: Column(
            children: [
        
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap:(){
                        Navigator.pop(context);
        },
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color:Colors.white),
                    ),
                 //   SizedBox(width: MediaQuery.of(context).size.width/5,),
        
                    Expanded(
                      child: Center(
                        child: Text(widget.name,
                           // textAlign: TextAlign.center,
                            style:TextStyle(color:Colors.white,
                                fontSize:26.0,
                                fontWeight: FontWeight.bold)),




      ),
                    ),
    ],
    ),


                ),

        
        SizedBox(height: 20,),
        
        
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 10.0),
            width: MediaQuery.of(context).size.width,
        
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft:Radius.circular(30),
                    topRight:Radius.circular(30))
        
        
            ),
            child: Column(
        
              children: [
            //    SizedBox(height: 50.0,),



                  Expanded(
                    child:   chatMessage()
                  ),

         
                GestureDetector(
                  onTap: (){
                    openRecording();
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Color(0xff703eff),
                            borderRadius: BorderRadius.circular(60),


                          ),

                        child: Icon(Icons.mic,
                          color: Colors.white,
                          size: 35.0,
                        ),

                        ),
                        SizedBox(width:10.0),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                                color: Color(0xFFececf8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              onChanged: (value){},

                              controller: messagecontroller,
                              decoration: InputDecoration(border:InputBorder.none,
                                hintText: "Write a Message",
                                suffixIcon: GestureDetector(
                                  onTap: (){
                                    getImage();
                                  },
                                    child: Icon(Icons.attach_file)
                                )

                              ),

                            ),
                          ),

                        ),

                              SizedBox(width: 10.0,),
                              GestureDetector(
                                onTap: (){
                  addMessage(true);
                                },
                                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xff703eff),
                    borderRadius: BorderRadius.circular(60),


                  ),

                  child: Icon(Icons.send,
                    color: Colors.white,
                    size: 35.0,
                  ),
                                ),
                              ),
                        SizedBox(width: 10.0,),
                      ],
                    ),
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

    );
  }
  
  
  
  Future openRecording()=> showDialog(
      context: context, 
      builder:
          (context)=>AlertDialog(
        content: SingleChildScrollView(
        child:Container(
          child: Column(
            children: [
              Text("Add Voice Note",style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: (){
                  if(_isRecording){
                    _stopRecording();
                  }else{
                    _startRecording();
                  }
                },
                child: Text(_isRecording? "Stop Recording":"Start Recording",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold),),
              ),


              SizedBox(height: 20,),

              ElevatedButton(
                onPressed: (){
                  if(_isRecording){
                    null;
                  }else{
                    _uploadFile();
                  }
                },
                child: Text(
                  "Upload Audio",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold),),
              ),



            ],
          ),
          
        )
      ),
      ),
  );
}
