import 'dart:async';

import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBloc {
  SettingsBloc() {
    _loadSettings();
  }

  final _darkThemeController = BehaviorSubject<bool>();
  StreamSink<bool> get _inDarkThemeSink => _darkThemeController.sink;
  Stream<bool> get darkThemeEnabledStream => _darkThemeController.stream;
  bool get _darkThemeEnabled => _darkThemeController.value;

  final _rotationLockController = BehaviorSubject<bool>();
  StreamSink<bool> get _inRotationLockSink => _rotationLockController.sink;
  Stream<bool> get rotationLockEnabledStream => _rotationLockController.stream;
  bool get _rotationLockEnabled => _rotationLockController.value;

  void toggleTheme() {
    _inDarkThemeSink.add(!_darkThemeEnabled);
    _saveSettings();
  }

  void toggleRotationLock() {
    _inRotationLockSink.add(!_rotationLockEnabled);
    _rotationLockEnabled
        ? SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        : SystemChrome.setPreferredOrientations([]);
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
    _inDarkThemeSink.add(prefs.getBool('darkThemeEnabled') ?? false);
    _inRotationLockSink.add(prefs.getBool('rotationLockEnabled') ?? false);

    // set orientation setting
    _rotationLockEnabled
        ? SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        : SystemChrome.setPreferredOrientations([]);
  }

  void close() {
    _darkThemeController.close();
    _rotationLockController.close();
  }
}
