import 'package:flutter/material.dart';

ThemeData get darkTheme {
  return ThemeData(
    accentColor: Colors.green,
    brightness: Brightness.dark,
    buttonColor: Colors.green,
    cursorColor: Colors.green,
    disabledColor: Colors.white,
    highlightColor: Colors.black,
    primaryColor: Colors.green,
    scaffoldBackgroundColor: Colors.black,
    splashColor: Colors.black,
    textSelectionColor: Colors.green,
    textSelectionHandleColor: Colors.green,
    toggleableActiveColor: Colors.green,
  );
}

ThemeData get lightTheme {
  return ThemeData(
    accentColor: Colors.green,
    brightness: Brightness.light,
    buttonColor: Colors.green,
    cursorColor: Colors.green,
    disabledColor: Colors.grey,
    highlightColor: Colors.white,
    primaryColor: Colors.green,
    scaffoldBackgroundColor: Colors.white,
    splashColor: Colors.grey,
    textSelectionColor: Colors.green,
    textSelectionHandleColor: Colors.green,
    toggleableActiveColor: Colors.green,
    errorColor: Colors.red,
  );
}
