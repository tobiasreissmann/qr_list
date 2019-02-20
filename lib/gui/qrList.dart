import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibrate/vibrate.dart';

import 'package:qr_list/bloc/itemListBloc.dart';
import 'package:qr_list/gui/itemEntry.dart';
import 'package:qr_list/gui/manualItemAdd.dart';
import 'package:qr_list/gui/scanButton.dart';
import 'package:qr_list/models/item.dart';

class BlocProvider extends InheritedWidget {
  BlocProvider({
    Key key,
    @required this.child,
  }) : super(key: key, child: child);

  final Widget child;

  final bloc = ItemListBloc();

  static BlocProvider of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(BlocProvider) as BlocProvider;
  }

  @override
  bool updateShouldNotify(BlocProvider oldWidget) {
    return true;
  }
}

class QRList extends StatefulWidget {
  @override
  _QRList createState() => new _QRList();
}

class _QRList extends State<QRList> {
  final _key = GlobalKey<ScaffoldState>();
  ScrollController _listScrollController = new ScrollController();

  @override
  dispose() {
    BlocProvider.of(context).bloc.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of(context).bloc;
    return GestureDetector(
      onTap: () => _key.currentState.removeCurrentSnackBar(),
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Text(
            'QR-Shoppinglist',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w400, fontSize: 24),
          ),
          actions: <Widget>[
            StreamBuilder(
              stream: _bloc.alphabeticalStream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return IconButton(
                  icon: Icon(Icons.sort_by_alpha),
                  color: snapshot.hasData ? snapshot.data ? Colors.green : Colors.grey : Colors.grey,
                  onPressed: () {
                    _toggleAlphabetical(context);
                  },
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_sweep),
              color: Colors.red[700],
              onPressed: () => _deleteItemList(context),
            ),
          ],
        ),
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
                              stream: _bloc.itemListStream,
                              builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
                                return ListView(
                                  children: (snapshot.hasData
                                    ? (snapshot.data.map((item) => _buildItemEntry(context, item)).toList())
                                    : [_buildPlaceholer(0)].toList()
                                  ..addAll([ManualItemAdd(), _buildPlaceholer(300)].toList())),
                                  controller: _listScrollController,
                                );
                              },
                            ),
                          ),
                        ),
                      ]),
                  MediaQuery.of(context).viewInsets.bottom > 0 ? _buildPlaceholer(0) : ScanButton(scrollController: _listScrollController),
                ],
              ),
        ),
      ),
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

  Widget _buildPlaceholer(double height) {
    return SizedBox(
      height: height,
    );
  }

  void _deleteItem(BuildContext context, Item item) {
    BlocProvider.of(context).bloc.deleteItemSink.add(item.number);
    _sendDeleteFeedbackMessage(context, 'Item "${item.name}" deleted.');
  }

  void _deleteItemList(BuildContext context) {
    BlocProvider.of(context).bloc.deleteItemList();
    _sendDeleteFeedbackMessage(context, 'Items deleted.');
  }

  void _toggleAlphabetical(BuildContext context) {
    BlocProvider.of(context).bloc.toggleAlphabetical();
  }

  void _sendDeleteFeedbackMessage(BuildContext context, String feedbackMessage) {
    Vibrate.feedback(FeedbackType.impact);
    _key.currentState.removeCurrentSnackBar();
    _key.currentState.showSnackBar(
      SnackBar(
        content: Text(feedbackMessage),
        action: new SnackBarAction(
          label: 'UNDO',
          onPressed: () => _undoDismissedItem(context),
        ),
      ),
    );
  }

  void _undoDismissedItem(BuildContext context) {
    BlocProvider.of(context).bloc.revertItemList();
  }

  // void getData() async {
  //   List<Item> _itemList = await getDatabaseItems();
  //   setState(() {
  //     itemList = _itemList;
  //     if (alphabetical) itemList.sort((a, b) => a.name.compareTo(b.name));
  //   });
  // }
}
