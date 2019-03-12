import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';

import 'package:qr_list/bloc/itemListProvider.dart';
import 'package:qr_list/bloc/settingsProvider.dart';
import 'package:qr_list/gui/presentationMode.dart';
import 'package:qr_list/locale/locales.dart';

class QrListAppBar extends StatefulWidget {
  QrListAppBar({Key key, this.child, @required this.scaffoldKey}) : super(key: key);

  final Widget child;
  final GlobalKey<ScaffoldState> scaffoldKey;

  _QrListAppBarState createState() => _QrListAppBarState();
}

class _QrListAppBarState extends State<QrListAppBar> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
      child: Container(
        height: 81,
        child: AppBar(
          backgroundColor: Theme.of(context).bottomAppBarColor,
          brightness: Theme.of(context).brightness,
          elevation: 0.0,
          title: Text(
            AppLocalizations.of(context).title,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w400,
              fontSize: 24,
            ),
          ),
          actions: <Widget>[
            StreamBuilder(
              stream: ItemListProvider.of(context).bloc.alphabeticalStream,
              initialData: false,
              builder: (BuildContext context, AsyncSnapshot alphabetical) {
                return IconButton(
                  icon: Icon(Icons.sort_by_alpha),
                  color: alphabetical.data ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                  onPressed: () => _toggleAlphabetical(),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_sweep),
              color: Theme.of(context).errorColor,
              onPressed: () => _deleteItemList(),
            ),
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).disabledColor,
              ),
              onSelected: (Options option) => _optionSelected(option),
              elevation: 9,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<Options>>[
                    PopupMenuItem(
                      value: Options.presentationMode,
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Icon(
                              Icons.present_to_all,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                          ),
                          Container(
                            child: Text(
                              AppLocalizations.of(context).presentationMode,
                              style: TextStyle(
                                color: Theme.of(context).indicatorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: Options.toggleTheme,
                      child: Row(
                        children: <Widget>[
                          StreamBuilder<Object>(
                            stream: SettingsProvider.of(context).bloc.darkThemeEnabledStream,
                            initialData: false,
                            builder: (BuildContext context, AsyncSnapshot darkThemeEnabled) {
                              return Container(
                                child: Icon(
                                  Icons.invert_colors,
                                  color: darkThemeEnabled.data
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).disabledColor,
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                          ),
                          Container(
                            child: Text(
                              AppLocalizations.of(context).darkMode,
                              style: TextStyle(
                                color: Theme.of(context).indicatorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: Options.toggleRotationLock,
                      child: Row(
                        children: <Widget>[
                          StreamBuilder<Object>(
                            stream: SettingsProvider.of(context).bloc.rotationLockEnabledStream,
                            initialData: false,
                            builder: (BuildContext context, AsyncSnapshot rotationLockEnabled) {
                              return Container(
                                child: Icon(
                                  Icons.screen_lock_portrait,
                                  color: rotationLockEnabled.data
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).disabledColor,
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                          ),
                          Container(
                            child: Text(
                              AppLocalizations.of(context).rotationLock,
                              style: TextStyle(
                                color: Theme.of(context).indicatorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  _optionSelected(Options option) {
    switch (option) {
      case Options.presentationMode:
        _navigatePresentationMode();
        break;
      case Options.toggleTheme:
        _toggleTheme();
        break;
      case Options.toggleRotationLock:
        _toggleRotationLock();
        break;
    }
  }

  _deleteItemList() {
    ItemListProvider.of(context).bloc.deleteItemList();
    Vibrate.feedback(FeedbackType.light);
    widget.scaffoldKey.currentState.removeCurrentSnackBar();
    widget.scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).deleteItemList,
          style: TextStyle(
            color: Theme.of(context).indicatorColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        action: SnackBarAction(
          label: AppLocalizations.of(context).undo,
          onPressed: () => ItemListProvider.of(context).bloc.revertItemList(),
        ),
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }

  _navigatePresentationMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PresentationMode(
            sortedItemList: ItemListProvider.of(context).bloc.itemList..sort((a, b) => a.name.compareTo(b.name)),
            statusBarColor: Theme.of(context).bottomAppBarColor,
          );
        },
      ),
    );
  }

  _toggleAlphabetical() => ItemListProvider.of(context).bloc.toggleAlphabetical();

  _toggleRotationLock() => SettingsProvider.of(context).bloc.toggleRotationLock();

  _toggleTheme() => SettingsProvider.of(context).bloc.toggleTheme();
}

enum Options {
  presentationMode,
  toggleRotationLock,
  toggleTheme,
}
