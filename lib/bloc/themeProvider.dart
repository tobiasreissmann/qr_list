import 'package:flutter/material.dart';
import 'package:qr_list/bloc/themeBloc.dart';

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
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return false;
  }
}