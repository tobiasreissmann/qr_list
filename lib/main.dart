import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qr_list/gui/qrList.dart';
import 'package:qr_list/themes.dart';

main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.white));
  runApp(QRListApp());
}

class QRListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR-Shoppinglist',
      theme: lightTheme,
      home: ItemListProvider(
        child: QRList(),
      ),
    );
  }
}
