import 'package:flutter/material.dart';

import 'package:qr_list/gui/qrList.dart';
import 'package:qr_list/themes.dart';
import 'package:qr_list/bloc/itemListProvider.dart';
import 'package:qr_list/bloc/themeProvider.dart';

main() {
  runApp(
    ThemeProvider(
      child: ItemListProvider(
        child: QRListApp(),
      ),
    ),
  );
}

class QRListApp extends StatefulWidget {
  @override
  QRListAppState createState() {
    return QRListAppState();
  }
}

class QRListAppState extends State<QRListApp> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ThemeProvider.of(context).themeBloc.lightThemeEnabled,
      initialData: true,
      builder: (BuildContext context, AsyncSnapshot lightThemeEnabled) {
        return MaterialApp(
          title: 'QR-Shoppinglist',
          theme: lightThemeEnabled.data ? lightTheme : darkTheme,
          home: ItemListProvider(
            child: QRList(),
          ),
        );
      },
    );
  }
}
