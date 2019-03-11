import 'package:flutter/material.dart';

import 'package:qr_list/bloc/settingsBloc.dart';

class SettingsProvider extends InheritedWidget {
  SettingsProvider({
    Key key,
    @required this.child,
  }) : super(key: key, child: child);

  final Widget child;

  final settingsBloc = SettingsBloc();

  static SettingsProvider of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(SettingsProvider) as SettingsProvider;
  }

  @override
  bool updateShouldNotify(SettingsProvider oldWidget) {
    return false;
  }
}