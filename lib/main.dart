import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';

import 'package:qr_list/bloc/itemListProvider.dart';
import 'package:qr_list/bloc/themeProvider.dart';
import 'package:qr_list/gui/qrList.dart';
import 'package:qr_list/locale/locales.dart';
import 'package:qr_list/themes.dart';

main() {
  runApp(
    ThemeProvider(
      child: QRListApp(),
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
          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', 'US'), // English
            const Locale('de', 'DE'), // German
          ],
          onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).title,
          theme: lightThemeEnabled.data ? lightTheme : darkTheme,
          home: ItemListProvider(
            child: QRList(),
          ),
        );
      },
    );
  }
}
