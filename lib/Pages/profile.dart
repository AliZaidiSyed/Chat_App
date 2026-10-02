import 'package:connecto/Pages/onboard.dart';
import 'package:connecto/services/auth.dart';
import 'package:connecto/services/shared_pref.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? myUsername, myName, myEmail, picture;
  bool isLoading = true;

  getthesharedpref() async {
    myUsername = await SharedpreferenceHelper.getuserUsername();
    myName = await SharedpreferenceHelper.getUserDisplayName();
    myEmail = await SharedpreferenceHelper.getUserEmail();
    picture = await SharedpreferenceHelper.getUserImage();

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getthesharedpref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff703eff),
      body: SafeArea(
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        )
            : SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 30.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xff703eff),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Profile",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(bottom: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(120),
                        child: picture != null && picture!.isNotEmpty
                            ? Image.network(
                          picture!,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: 120,
                              color: Color(0xffececf8),
                              child: Icon(
                                Icons.person,
                                color: Color(0xff703eff),
                                size: 65,
                              ),
                            );
                          },
                        )
                            : Container(
                          height: 120,
                          width: 120,
                          color: Color(0xffececf8),
                          child: Icon(
                            Icons.person,
                            color: Color(0xff703eff),
                            size: 65,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),

                      // Name
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Material(
                          elevation: 3.0,
                          shadowColor: Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  color: Color(0xff703eff),
                                  size: 30,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Name",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        myName ?? '',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Email
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Material(
                          elevation: 3.0,
                          shadowColor: Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  color: Color(0xff703eff),
                                  size: 30,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Email",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        myEmail ?? '',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),

                      // Logout
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Material(
                          color: Colors.white,
                          elevation: 3.0,
                          shadowColor: Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () async {
                              await AuthMethod().SignOut();
                              if (!mounted) return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => onBoard(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color: Color(0xff703eff),
                                    size: 30,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      "Logout",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: Color(0xff703eff),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Delete Account
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Material(
                          color: Colors.white,
                          elevation: 3.0,
                          shadowColor: Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () async {
                              await AuthMethod().deleteUser();
                              if (!mounted) return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => onBoard(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      "Delete Account",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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