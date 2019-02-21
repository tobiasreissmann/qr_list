import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qr_list/gui/qrList.dart';

main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.white));
  runApp(new QRListApp());
}

class QRListApp extends StatelessWidget {
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
        scaffoldBackgroundColor: Colors.white,
      ),
      home: ItemListProvider(
        child: QRList(),
      ),
    );
  }
}
