import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_list/itemListBloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qr_list/globals.dart';
import 'package:qr_list/gui/widgets/itemEntry.dart';
import 'package:qr_list/gui/widgets/manualItemAdd.dart';
import 'package:qr_list/gui/widgets/scanButton.dart';
import 'package:qr_list/models/item.dart';
import 'package:qr_list/services/data.service.dart';
import 'package:vibrate/vibrate.dart';

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
  initState() {
    super.initState();
    // readSetting();
    // getData();
  }

  @override
  dispose() {
    super.dispose();
    BlocProvider.of(context).bloc.dispose();
  }

  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of(context).bloc;
    return Scaffold(
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
          // IconButton(
          //     icon: Icon(Icons.sort_by_alpha),
          //     color: alphabetical ? Colors.green : Colors.grey,
          //     onPressed: () {
          //       alphabetical = !alphabetical;
          //       alphabetical ? alphabetize() : getData();
          //       saveSetting();
          //     }),
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
                              if (!snapshot.hasData)
                                return SizedBox();
                              else
                                return ListView(
                                  children: snapshot.data.map((item) => _buildItemEntry(context, item)).toList(),
                                  controller: _listScrollController,
                                );
                            },
                          ),
                        ),
                      ),
                      ManualItemAdd(),
                    ]),
                // MediaQuery.of(context).viewInsets.bottom == 0.0
                //     ? Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                //         Center(
                //           child: ScanButton(
                //             onSubmitted: () {
                //               Vibrate.feedback(FeedbackType.selection);
                //               return scanItem(context);
                //             }
                //           )
                //         ),
                //       ])
                //     : Container(),
              ],
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

  void _deleteItem(BuildContext context, Item item) {
    BlocProvider.of(context).bloc.deleteItemSink.add(item.number);
    _sendDeleteFeedbackMessage(context, 'Item ${item.name} was deleted.');
  }

  void _deleteItemList(BuildContext context) {
    BlocProvider.of(context).bloc.deleteItemList();
    _sendDeleteFeedbackMessage(context, 'Items were deleted.');
  }

  void _sendDeleteFeedbackMessage(BuildContext context, String feedbackMessage) {
    Vibrate.feedback(FeedbackType.light);
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

  // void alphabetize() {
  //   setState(() {
  //     itemList.sort((a, b) => a.name.compareTo(b.name));
  //   });
  // }

  // void saveSetting() async {
  //   // save alphabetical setting
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.setBool('alphabetical', alphabetical);
  // }

  // void readSetting() async {
  //   // get saved alphabetical setting
  //   final prefs = await SharedPreferences.getInstance();
  //   alphabetical = prefs.getBool('alphabetical') ?? false;
  // }
}
