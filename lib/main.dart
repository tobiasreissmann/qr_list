import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_list/home_screen.dart';

Future main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.white));
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR-Shoppinglist',
      theme: ThemeData(
        accentColor: Colors.green,
        brightness: Brightness.light,
        cursorColor: Colors.green,
        primaryColor: Colors.green,
        textSelectionColor: Colors.green,
      ),
      home: HomeScreen(),
    );
  }
}
