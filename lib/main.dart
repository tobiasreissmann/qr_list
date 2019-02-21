import 'package:flutter/material.dart';
import 'package:qr_list/bloc/themeBloc.dart';

import 'package:qr_list/gui/qrList.dart';
import 'package:qr_list/themes.dart';

main() {
  runApp(
    ThemeProvider(
      child: QrListApp(),
    ),
  );
}

class QrListApp extends StatefulWidget {
  @override
  QrListAppState createState() {
    return QrListAppState();
  }
}

class QrListAppState extends State<QrListApp> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ThemeProvider.of(context).themeBloc.lightThemeEnabled,
      initialData: true,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final lightThemeEnabled = snapshot.data;
        return MaterialApp(
          title: 'QR-Shoppinglist',
          theme: lightThemeEnabled ? lightTheme : darkTheme,
          home: ItemListProvider(
            child: QRList(),
          ),
        );
      },
    );
  }
}

class ThemeProvider extends InheritedWidget {
  ThemeProvider({
    Key key,
    @required this.child,
  }) : super(key: key, child: child);

  final Widget child;

  final themeBloc = ThemeBloc();

  static ThemeProvider of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ThemeProvider) as ThemeProvider;
  }

  @override
  bool updateShouldNotify(ItemListProvider oldWidget) {
    return true;
  }
}
