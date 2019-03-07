import 'package:flutter/material.dart';
import 'package:qr_list/gui/settings.dart';
import 'package:qr_list/locale/locales.dart';
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

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(duration: Duration(milliseconds: 700), vsync: this);
    animation = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: animationController,
    ));
    animationController.forward();
  }

  @override
  dispose() {
    ItemListProvider.of(context).itemListBloc.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: QrListAppBar(
        context: context,
        scaffoldKey: _key,
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
              ],
            ),
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

  void _sendDeleteFeedbackMessage(BuildContext context, String feedbackMessage) {
    Vibrate.feedback(FeedbackType.light);
    _key.currentState.removeCurrentSnackBar();
    _key.currentState.showSnackBar(
      SnackBar(
        content: Text(feedbackMessage),
        action: new SnackBarAction(
          label: AppLocalizations.of(context).undo,
          onPressed: () => ItemListProvider.of(context).itemListBloc.revertItemList(),
        ),
      ),
    );
  }
}
