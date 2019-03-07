import 'dart:async';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qr_list/themes.dart';

class SettingsBloc {
  bool _darkThemeEnabled = false;
  bool _rotationLockEnabled = false;

  final _darkThemeController = BehaviorSubject<bool>();
  StreamSink<bool> get _inDarkThemeSink => _darkThemeController.sink;
  Stream<bool> get darkThemeEnabled => _darkThemeController.stream;

  final _rotationLockController = BehaviorSubject<bool>();
  StreamSink<bool> get _inRotationLockSink => _rotationLockController.sink;
  Stream<bool> get rotationLockEnabled => _rotationLockController.stream;

  void dispose() {
    _darkThemeController.close();
    _rotationLockController.close();
  }

  SettingsBloc() {
    _loadSettings();
    _inDarkThemeSink.add(_darkThemeEnabled);
    _inRotationLockSink.add(_rotationLockEnabled);
  }

  void toggleTheme() {
    _darkThemeEnabled = !_darkThemeEnabled;
    _darkThemeEnabled
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: darkTheme.scaffoldBackgroundColor))
        : SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(statusBarColor: lightTheme.scaffoldBackgroundColor));
    _inDarkThemeSink.add(_darkThemeEnabled);
    _saveSettings();
  }

  void toggleRotationLock() {
    _rotationLockEnabled = !_rotationLockEnabled;
    _rotationLockEnabled
        ? SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        : SystemChrome.setPreferredOrientations([]);
    _inRotationLockSink.add(_rotationLockEnabled);
    _saveSettings();
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkThemeEnabled', _darkThemeEnabled);
    prefs.setBool('rotationLockEnabled', _rotationLockEnabled);
  }

  void _loadSettings() async {
    // getting settings
    final prefs = await SharedPreferences.getInstance();
    _darkThemeEnabled = prefs.getBool('darkThemeEnabled') ?? false;
    _rotationLockEnabled = prefs.getBool('rotationLockEnabled') ?? false;
    _inDarkThemeSink.add(_darkThemeEnabled);
    _inRotationLockSink.add(_rotationLockEnabled);

    // need to set white statusbar manual (not system standard in Android)
    _darkThemeEnabled
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: darkTheme.scaffoldBackgroundColor))
        : SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(statusBarColor: lightTheme.scaffoldBackgroundColor));

    // set orientation setting
    _rotationLockEnabled
        ? SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        : SystemChrome.setPreferredOrientations([]);
  }
}
