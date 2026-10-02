
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecto/Pages/chat_page.dart';
import 'package:connecto/Pages/home.dart';
import 'package:connecto/Pages/onboard.dart';
import 'package:connecto/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://ncrnmtqunqdkphfyvsnz.supabase.co',
    publishableKey: 'sb_publishable_rNxwkK8MzqHDuAY7xhKJUA_CGaMnla9',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connecto',
      debugShowCheckedModeBanner: false,

      theme:  ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,


      ),
      home:onBoard(),

    );
  }
}





