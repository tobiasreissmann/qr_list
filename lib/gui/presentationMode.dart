import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:qr_list/gui/itemEntry.dart';
import 'package:qr_list/locale/locales.dart';
import 'package:qr_list/models/item.dart';

class PresentationMode extends StatefulWidget {
  PresentationMode({Key key, @required this.sortedItemList, @required this.statusBarColor}) : super(key: key);

  final List<Item> sortedItemList;
  final Color statusBarColor;

  _PresentationModeState createState() => _PresentationModeState();
}

class _PresentationModeState extends State<PresentationMode> with TickerProviderStateMixin {
  AnimationController _backAnimationController;
  Animation _backAnimation;

  @override
  void initState() {
    super.initState();
    _backAnimationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _backAnimation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        curve: Curves.fastOutSlowIn,
        parent: _backAnimationController,
      ),
    );
    _backAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          body: Container(
            child: widget.sortedItemList.length > 0
                ? ListView(
                    children: widget.sortedItemList.map((item) => _buildItemEntry(item)).toList(),
                  )
                : Center(
                    heightFactor: 3,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        AppLocalizations.of(context).noItems,
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        AnimatedBuilder(
          animation: _backAnimationController,
          builder: (BuildContext context, Widget child) {
            return Transform(
              transform: Matrix4.translationValues(0.0, _backAnimation.value * 200, 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: Container(
                        child: ButtonTheme(
                          minWidth: 70,
                          height: 70,
                          buttonColor: Theme.of(context).buttonColor,
                          splashColor: Theme.of(context).splashColor,
                          child: RaisedButton(
                            onPressed: () => Navigator.pop(context),
                            textColor: Colors.white,
                            elevation: 9,
                            child: Icon(Icons.keyboard_backspace),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: Container(
            color: widget.statusBarColor,
            height: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildItemEntry(Item item) {
    return Dismissible(
      key: Key(item.number),
      onDismissed: (direction) =>
          setState(() => widget.sortedItemList.removeWhere((_item) => _item.number == item.number)),
      child: ItemEntry(
        item: item,
      ),
    );
  }
}
