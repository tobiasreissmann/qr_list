import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';

import 'package:qr_list/bloc/itemListProvider.dart';
import 'package:qr_list/bloc/settingsProvider.dart';
import 'package:qr_list/gui/presentationMode.dart';
import 'package:qr_list/locale/locales.dart';

class QrListAppBar extends AppBar {
  final BuildContext context;
  final GlobalKey<ScaffoldState> scaffoldKey;

  QrListAppBar({this.context, this.scaffoldKey})
      : super(
          backgroundColor: Theme.of(context).bottomAppBarColor,
          brightness: Theme.of(context).brightness,
          elevation: 0.0,
          title: Text(
            AppLocalizations.of(context).title,
            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w400, fontSize: 24),
          ),
          actions: <Widget>[
            StreamBuilder(
              stream: ItemListProvider.of(context).itemListBloc.alphabeticalStream,
              initialData: false,
              builder: (BuildContext context, AsyncSnapshot alphabetical) {
                return IconButton(
                  icon: Icon(Icons.sort_by_alpha),
                  color: alphabetical.data ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                  onPressed: () => ItemListProvider.of(context).itemListBloc.toggleAlphabetical(),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_sweep),
              color: Theme.of(context).errorColor,
              onPressed: () {
                ItemListProvider.of(context).itemListBloc.deleteItemList();
                Vibrate.feedback(FeedbackType.light);
                scaffoldKey.currentState.removeCurrentSnackBar();
                scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).deleteItemList,
                      style: TextStyle(
                        color: Theme.of(context).indicatorColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    action: new SnackBarAction(
                      label: AppLocalizations.of(context).undo,
                      onPressed: () => ItemListProvider.of(context).itemListBloc.revertItemList(),
                    ),
                    backgroundColor: Theme.of(context).cardColor,
                  ),
                );
              },
            ),
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).disabledColor,
              ),
              onSelected: (Options option) {
                switch (option) {
                  case Options.presentationMode:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PresentationMode(
                            sortedItemList: ItemListProvider.of(context).itemListBloc.itemListController.value.toList()
                              ..sort((a, b) => a.name.compareTo(b.name)),
                            statusBarColor: Theme.of(context).bottomAppBarColor,
                          );
                        },
                      ),
                    );
                    break;
                  case Options.toggleTheme:
                    SettingsProvider.of(context).settingsBloc.toggleTheme();
                    break;
                  case Options.toggleRotationLock:
                    SettingsProvider.of(context).settingsBloc.toggleRotationLock();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<Options>>[
                    PopupMenuItem(
                      value: Options.presentationMode,
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 38,
                            alignment: FractionalOffset(0, 0.5),
                            child: Icon(
                              Icons.present_to_all,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                          Container(
                            alignment: FractionalOffset(0, 0.5),
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
                            stream: SettingsProvider.of(context).settingsBloc.darkThemeEnabled,
                            initialData: false,
                            builder: (BuildContext context, AsyncSnapshot darkThemeEnabled) {
                              return Container(
                                width: 38,
                                alignment: FractionalOffset(0, 0.5),
                                child: Icon(
                                  Icons.invert_colors,
                                  color: darkThemeEnabled.data
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).disabledColor,
                                ),
                              );
                            },
                          ),
                          Container(
                            alignment: FractionalOffset(0, 0.5),
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
                            stream: SettingsProvider.of(context).settingsBloc.rotationLockEnabled,
                            initialData: false,
                            builder: (BuildContext context, AsyncSnapshot rotationLockEnabled) {
                              return Container(
                                width: 38,
                                alignment: FractionalOffset(0, 0.5),
                                child: Icon(
                                  Icons.screen_lock_portrait,
                                  color: rotationLockEnabled.data
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).disabledColor,
                                ),
                              );
                            },
                          ),
                          Container(
                            alignment: FractionalOffset(0, 0.5),
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
        );
}

enum Options { presentationMode, toggleTheme, toggleRotationLock }
