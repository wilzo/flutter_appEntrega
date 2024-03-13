import 'package:flutter_projeto/pages/login/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  var options = const FirebaseOptions(
      apiKey: "AIzaSyDJOjWeeO_3gamsv4hZRt88QUD7b2hrqF8",
      authDomain: "testeapp23-6ca39.firebaseapp.com",
      projectId: "testeapp23-6ca39",
      storageBucket: "testeapp23-6ca39.appspot.com",
      messagingSenderId: "361982466517",
      appId: "1:361982466517:web:5cd1847d020b3ea91e055c",
      measurementId: "G-JZEBX8KP5K");
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(options: options);
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}
