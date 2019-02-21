import 'package:flutter/material.dart';

ThemeData get darkTheme {
  return ThemeData(
    accentColor: Colors.green,
    brightness: Brightness.dark,
    buttonColor: Colors.green,
    cursorColor: Colors.green,
    primaryColor: Colors.green,
    highlightColor: Colors.black,
    splashColor: Colors.black,
    textSelectionColor: Colors.green,
    textSelectionHandleColor: Colors.green,
    scaffoldBackgroundColor: Colors.black,
    disabledColor: Colors.white,
    toggleableActiveColor: Colors.green,
    cardColor: Colors.white,
  );
}

ThemeData get lightTheme {
  return ThemeData(
    accentColor: Colors.green,
    brightness: Brightness.light,
    buttonColor: Colors.green,
    cursorColor: Colors.green,
    primaryColor: Colors.green,
    highlightColor: Colors.white,
    splashColor: Colors.grey,
    textSelectionColor: Colors.green,
    textSelectionHandleColor: Colors.green,
    scaffoldBackgroundColor: Colors.white,
    disabledColor: Colors.grey,
    toggleableActiveColor: Colors.green,
    cardColor: Colors.black,
  );
}
