import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_list/gui/itemEntry.dart';
import 'package:qr_list/models/item.dart';

class PresentationMode extends StatefulWidget {
  final Widget child;
  final List<Item> sortedItemList;

  PresentationMode({Key key, this.child, @required this.sortedItemList}) : super(key: key);

  _PresentationModeState createState() => _PresentationModeState(sortedItemList: sortedItemList);
}

class _PresentationModeState extends State<PresentationMode> with TickerProviderStateMixin {
  AnimationController _backAnimationController;
  Animation _backAnimation;

  final List<Item> sortedItemList;

  _PresentationModeState({@required this.sortedItemList});

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    _backAnimationController = AnimationController(
      duration: Duration(milliseconds: 700),
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
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          body: Container(
            child: sortedItemList.length > 0
                ? ListView(
                    children: sortedItemList.map((item) => _buildItemEntry(item)).toList(),
                  )
                : Center(
                    heightFactor: 3,
                    child: Container(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No items available',
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
                      padding: EdgeInsets.only(bottom: 50),
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
      ],
    );
  }

  Widget _buildItemEntry(Item item) {
    return Dismissible(
      key: Key(item.number), // INFO using item.number instead of item.name because key must be unique
      onDismissed: (direction) => setState(() => sortedItemList.removeWhere((_item) => _item.number == item.number)),
      child: ItemEntry(
        item: item,
      ),
    );
  }
}
