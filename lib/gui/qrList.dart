import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_list/bloc/themeProvider.dart';
import 'package:qr_list/locale/locales.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibrate/vibrate.dart';
import 'package:flutter/animation.dart';

import 'package:qr_list/bloc/itemListProvider.dart';
import 'package:qr_list/gui/itemEntry.dart';
import 'package:qr_list/gui/itemMask.dart';
import 'package:qr_list/gui/scanButton.dart';
import 'package:qr_list/models/item.dart';

class QRList extends StatefulWidget {
  @override
  _QRList createState() => _QRList();
}

class _QRList extends State<QRList> with SingleTickerProviderStateMixin {
  final _key = GlobalKey<ScaffoldState>();
  ScrollController _listScrollController = ScrollController();
  AnimationController animationController;
  Animation animation;
  bool _rotationLock = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(duration: Duration(milliseconds: 700), vsync: this);
    animation = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: animationController,
    ));
    animationController.forward();
    _loadSettings();
  }

  @override
  dispose() {
    ItemListProvider.of(context).itemListBloc.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                onPressed: () => _toggleAlphabetical(context),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_sweep),
            color: Theme.of(context).errorColor,
            onPressed: () => _deleteItemList(context),
          ),
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).disabledColor,
            ),
            onSelected: (Options option) => _optionSelected(context, option),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Options>>[
                  PopupMenuItem(
                    value: Options.toggleTheme,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 38,
                          alignment: FractionalOffset(0, 0.5),
                          child: Icon(
                            Icons.invert_colors,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                        Container(
                          alignment: FractionalOffset(0, 0.5),
                          child: Text(
                            'Dark Mode',
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
                        Container(
                          width: 38,
                          alignment: FractionalOffset(0, 0.5),
                          child: Icon(
                            Icons.screen_lock_portrait,
                            color: _rotationLock ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                          ),
                        ),
                        Container(
                          alignment: FractionalOffset(0, 0.5),
                          child: Text(
                            'Lock Rotation',
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
      body: Builder(
        builder: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      child: StreamBuilder(
                        stream: ItemListProvider.of(context).itemListBloc.itemListStream,
                        builder: (BuildContext context, AsyncSnapshot<List<Item>> itemList) {
                          return ListView(
                            children: itemList.hasData
                                ? itemList.data.map((item) => _buildItemEntry(context, item)).toList()
                                : [_buildPlaceholder(0)].toList()
                              ..addAll([_buildPlaceholder(16), ItemMask(), _buildPlaceholder(200)].toList()),
                            controller: _listScrollController,
                          );
                        },
                      ),
                    ),
                  ),
                ]),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          final _width = MediaQuery.of(context).size.width;
          return Transform(
            transform: Matrix4.translationValues(0.0, animation.value * _width, 0.0),
            child: ScanButton(scrollController: _listScrollController),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _optionSelected(BuildContext context, Options option) {
    switch (option) {
      case Options.toggleTheme:
        _toggleTheme(context);
        break;
      case Options.toggleRotationLock:
        _toggleRotationLock();
        break;
    }
  }

  Widget _buildItemEntry(BuildContext context, Item item) {
    return Dismissible(
      key: Key(item.number), // INFO using item.number instead of item.name because key must be unique
      onDismissed: (direction) => setState(() => _deleteItem(context, item)),
      child: ItemEntry(
        item: item,
      ),
    );
  }

  Widget _buildPlaceholder(double height) {
    return SizedBox(
      height: height,
    );
  }

  void _deleteItem(BuildContext context, Item item) {
    ItemListProvider.of(context).itemListBloc.deleteItemSink.add(item.number);
    _sendDeleteFeedbackMessage(context, '"${item.name}" ${AppLocalizations.of(context).itemDeleted}');
  }

  void _deleteItemList(BuildContext context) {
    ItemListProvider.of(context).itemListBloc.deleteItemList();
    _sendDeleteFeedbackMessage(context, AppLocalizations.of(context).deleteItemList);
  }

  void _toggleAlphabetical(BuildContext context) {
    ItemListProvider.of(context).itemListBloc.toggleAlphabetical();
  }

  void _toggleRotationLock() async {
    _rotationLock = !_rotationLock;
    _rotationLock
        ? SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        : SystemChrome.setPreferredOrientations([]);
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('rotationLock', _rotationLock);
  }

  void _sendDeleteFeedbackMessage(BuildContext context, String feedbackMessage) {
    Vibrate.feedback(FeedbackType.light);
    _key.currentState.removeCurrentSnackBar();
    _key.currentState.showSnackBar(
      SnackBar(
        content: Text(feedbackMessage),
        action: new SnackBarAction(
          label: AppLocalizations.of(context).undo,
          onPressed: () => _undoDismissedItem(context),
        ),
      ),
    );
  }

  void _undoDismissedItem(BuildContext context) {
    ItemListProvider.of(context).itemListBloc.revertItemList();
  }

  void _toggleTheme(BuildContext context) {
    ThemeProvider.of(context).themeBloc.changeTheme();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _rotationLock = prefs.getBool('rotationLock') ?? false;
    _rotationLock
        ? SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        : SystemChrome.setPreferredOrientations([]);
  }
}

enum Options { toggleTheme, toggleRotationLock }
