import 'package:flutter/material.dart';

ThemeData get darkTheme {
  return ThemeData(
    accentColor: Colors.green,
    brightness: Brightness.dark,
    buttonColor: Colors.green,
    cursorColor: Colors.green,
    disabledColor: Colors.grey[400],
    dividerColor: Colors.grey[400],
    errorColor: Colors.red,
    highlightColor: Colors.green[900],
    hintColor: Colors.grey[400],
    indicatorColor: Colors.grey[200],
    primaryColor: Colors.green,
    scaffoldBackgroundColor: Colors.black,
    splashColor: Colors.black54,
    textSelectionColor: Colors.green,
    textSelectionHandleColor: Colors.green,
    toggleableActiveColor: Colors.green,
    bottomAppBarColor: Colors.black54,
    cardColor: Colors.grey[900],
  );
}

ThemeData get lightTheme {
  return ThemeData(
    accentColor: Colors.green,
    brightness: Brightness.light,
    buttonColor: Colors.green,
    cursorColor: Colors.green,
    disabledColor: Colors.grey,
    dividerColor: Colors.grey,
    errorColor: Colors.red,
    highlightColor: Colors.green[200],
    hintColor: Colors.grey,
    indicatorColor: Colors.grey[800],
    primaryColor: Colors.green,
    scaffoldBackgroundColor: Colors.white,
    splashColor: Colors.black12,
    textSelectionColor: Colors.green,
    textSelectionHandleColor: Colors.green,
    toggleableActiveColor: Colors.green,
    bottomAppBarColor: Colors.white70,
    cardColor: Colors.grey[50],
  );
}
