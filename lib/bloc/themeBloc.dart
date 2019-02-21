import 'dart:async';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qr_list/themes.dart';

class ThemeBloc {
  bool _lightThemeEnabled = true;

  final _themeController = BehaviorSubject<bool>();
  StreamSink<bool> get _inThemeSink => _themeController.sink;
  Stream<bool> get lightThemeEnabled => _themeController.stream;

  void dispose() {
    _themeController.close();
  }

  ThemeBloc() {
    _inThemeSink.add(_lightThemeEnabled);
    _loadSettings();
  }

  void changeTheme() {
    _lightThemeEnabled = !_lightThemeEnabled;

    _lightThemeEnabled
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: lightTheme.scaffoldBackgroundColor))
        : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: darkTheme.scaffoldBackgroundColor));
    _inThemeSink.add(_lightThemeEnabled);
    _saveSettings();
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('lightThemeEnabled', _lightThemeEnabled);
  }

  void _loadSettings() async {
    // getting settings
    final prefs = await SharedPreferences.getInstance();
    _lightThemeEnabled = prefs.getBool('lightThemeEnabled') ?? true;
    _inThemeSink.add(_lightThemeEnabled);
    
    // need to set white statusbar manual (not system standard in Android)
    _lightThemeEnabled
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: lightTheme.scaffoldBackgroundColor))
        : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: darkTheme.scaffoldBackgroundColor));
  }
}
