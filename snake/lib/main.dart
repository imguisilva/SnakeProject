import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCBEkfkNVv7XVQdzYQb5IKH_dg9e1if67U",
          authDomain: "snakegame-ab57d.firebaseapp.com",
          projectId: "snakegame-ab57d",
          storageBucket: "snakegame-ab57d.appspot.com",
          messagingSenderId: "327891100109",
          appId: "1:327891100109:web:54d90056ea34f36856a484",
          measurementId: "G-3JX2GY9FNF"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(brightness: Brightness.dark),
    );
  }
}
