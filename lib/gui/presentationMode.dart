import 'package:flutter/material.dart';
import 'package:qr_list/bloc/itemListProvider.dart';
import 'package:qr_list/gui/itemEntry.dart';
import 'package:qr_list/models/item.dart';

class PresentationMode extends StatefulWidget {
  final Widget child;

  PresentationMode({Key key, this.child}) : super(key: key);

  _PresentationModeState createState() => _PresentationModeState();
}

class _PresentationModeState extends State<PresentationMode> with TickerProviderStateMixin {
  AnimationController _backAnimationController;
  Animation _backAnimation;

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          body: Container(
            child: StreamBuilder(
              stream: ItemListProvider.of(context).itemListBloc.itemListStream,
              builder: (BuildContext context, AsyncSnapshot<List<Item>> itemList) {
                if (itemList.hasData) {
                  return ListView(
                    children: (itemList.data.toList()..sort((a, b) => a.name.compareTo(b.name)))
                        .map((item) => _buildItemEntry(context, item))
                        .toList(),
                  );
                } else {
                  return SizedBox();
                }
              },
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

  Widget _buildItemEntry(BuildContext context, Item item) {
    return ItemEntry(
      item: item,
    );
  }
}
