import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';

import 'package:qr_list/bloc/itemListProvider.dart';
import 'package:qr_list/gui/itemEntry.dart';
import 'package:qr_list/gui/itemMask.dart';
import 'package:qr_list/gui/qrListAppBar.dart';
import 'package:qr_list/gui/scanButton.dart';
import 'package:qr_list/locale/locales.dart';
import 'package:qr_list/models/item.dart';

class QRList extends StatefulWidget {
  @override
  _QRList createState() => _QRList();
}

class _QRList extends State<QRList> with SingleTickerProviderStateMixin {
  final _key = GlobalKey<ScaffoldState>();
  ScrollController _listScrollController = ScrollController();
  AnimationController _scanAnimationController;
  Animation _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );
    _scanAnimation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        curve: Curves.fastOutSlowIn,
        parent: _scanAnimationController,
      ),
    );
    _scanAnimationController.forward();
  }

  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          key: _key,
          body: Builder(
            builder: (context) => Stack(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            child: StreamBuilder(
                              stream: ItemListProvider.of(context).bloc.itemListStream,
                              builder: (BuildContext context, AsyncSnapshot<List<Item>> itemList) {
                                return ListView(
                                  children: <Widget>[_buildPlaceholder(65)]
                                    ..addAll(itemList.hasData
                                        ? itemList.data.map((item) => _buildItemEntry(context, item)).toList()
                                        : [_buildPlaceholder(0)].toList())
                                    ..addAll([_buildPlaceholder(16), ItemMask(), _buildPlaceholder(200)].toList()),
                                  controller: _listScrollController,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                      child: Container(
                        height: 80,
                        child: QrListAppBar(
                          context: context,
                          scaffoldKey: _key,
                        ),
                      ),
                    ),
                  ],
                ),
          ),
        ),
        AnimatedBuilder(
          animation: _scanAnimationController,
          builder: (BuildContext context, Widget child) {
            return Transform(
              transform: Matrix4.translationValues(0.0, _scanAnimation.value * 200, 0.0),
              child: ScanButton(scrollController: _listScrollController, scaffoldKey: _key),
            );
          },
        ),
      ],
    );
  }

  Widget _buildItemEntry(BuildContext context, Item item) {
    return Dismissible(
      key: Key(item.number),
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
    ItemListProvider.of(context).bloc.deleteItem.add(item.number);
    _sendDeleteFeedbackMessage(context, '"${item.name}" ${AppLocalizations.of(context).itemDeleted}');
  }

  void _sendDeleteFeedbackMessage(BuildContext context, String feedbackMessage) {
    Vibrate.feedback(FeedbackType.light);
    _key.currentState.removeCurrentSnackBar();
    _key.currentState.showSnackBar(
      SnackBar(
        content: Text(
          feedbackMessage,
          style: TextStyle(
            color: Theme.of(context).indicatorColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        action: new SnackBarAction(
          label: AppLocalizations.of(context).undo,
          onPressed: () => ItemListProvider.of(context).bloc.revertItemList(),
        ),
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }

  @override
  dispose() {
    ItemListProvider.of(context).bloc.close();
    super.dispose();
  }
}
