import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_list/home_screen.dart';
// import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

Future main() async {
  // await FlutterStatusbarcolor.setNavigationBarColor(Colors.green[700]);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(new MyApp());
    });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR-Shoppinglist',
      theme: ThemeData(
        primarySwatch: Colors.green
      ),
      home: HomeScreen(),
    );
  }
}