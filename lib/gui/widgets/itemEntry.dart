import 'package:flutter/material.dart';
import 'package:qr_list/gui/qrList.dart';

import 'package:qr_list/models/item.dart';
import 'package:vibrate/vibrate.dart';

class ItemEntry extends StatefulWidget {
  ItemEntry({@required this.item});
  final Item item;

  @override
  ItemEntryState createState() {
    return new ItemEntryState();
  }
}

class ItemEntryState extends State<ItemEntry> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.item.number), // INFO using item.number instead of item.name because key must be unique
      onDismissed: (direction) => setState(() {
            _deleteItem(context, widget.item);
          }),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          children: <Widget>[
            Row(children: <Widget>[
              Flexible(
                flex: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    widget.item.name,
                    style: TextStyle(fontSize: 20.0),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(widget.item.number, style: TextStyle(fontSize: 26.0), overflow: TextOverflow.ellipsis, textAlign: TextAlign.left),
                ),
              ),
            ]),
            Divider()
          ],
        ),
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _deleteItem(BuildContext context, Item item) {
    final _bloc = MyInherited.of(context).bloc;
    _bloc.deleteItemSink.add(item.number);
    return _sendFeedbackMessage(context, FeedbackType.light, 'Item "${item.name}" was deleted.');
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _sendFeedbackMessage(
      BuildContext context, FeedbackType feedbacktype, String feedbackMessage) {
    Vibrate.feedback(feedbacktype);
    Scaffold.of(context).removeCurrentSnackBar();
    return Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(feedbackMessage),
      action: new SnackBarAction(
        label: 'UNDO',
        // onPressed: () => _undoDismissedItem(context), // ! context non existent in this moment
      ),
    ));
  }

  void _undoDismissedItem(BuildContext context) { // TODO find Solution -> context is non-existend when calling this method
    MyInherited.of(context).bloc.revertItemList();
  }
}
