import "package:connecto/services/auth.dart";
import "package:flutter/material.dart";


class onBoard extends StatefulWidget {
  const onBoard({super.key});

  @override
  State<onBoard> createState() => _onBoardState();
}

class _onBoardState extends State<onBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child: SingleChildScrollView(
          child: Container(
          child: Column(
          children: [
            Image.asset("assets/images/onboard.png"),
            SizedBox(height: 20.0,),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                  "Enjoy the experience of chatting with global friends",
                  textAlign: TextAlign.center,
                  style:TextStyle(
                      color:Colors.black,
                  fontSize:25.0,
                  fontWeight: FontWeight.bold )),
            ),
            SizedBox(height: 30.0,),
          
          
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                  "Connect people around the world for free",
                  textAlign: TextAlign.center,
                  style:TextStyle(color:Colors.black54,
                      fontSize:17.0,
                      fontWeight: FontWeight.w500 )),
            ),
          
            SizedBox(height: 30.0,),

               GestureDetector(
                 onTap: (){
                   AuthMethod().signInWithGoogle(context);
                 },
                 child: Container(
                  margin: EdgeInsets.only(left: 30.0,right: 30.0),
                  child: Material(
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(20),

                    child: Container(
                      height: 70,
                      padding: EdgeInsets.only(top: 8.0, left: 30.0, bottom: 8.0),

                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Color(0xff703eff),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                      //  mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Image.asset(
                            "assets/images/search.png",
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,),

                          SizedBox(width: 20.0,),

                             Text("Sign in With Google",
                                textAlign: TextAlign.center,
                                style:TextStyle(color:Colors.white,
                                    fontSize:17.0,
                                    fontWeight: FontWeight.bold)),


                        ],
                      ),
                    ),
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
