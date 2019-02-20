import 'package:flutter/material.dart';
import 'package:qr_list/gui/qrList.dart';
import 'package:qr_list/models/item.dart';
import 'package:vibrate/vibrate.dart';

class ManualItemAdd extends StatefulWidget {
  @override
  _ManualItemAddState createState() {
    return new _ManualItemAddState();
  }
}

class _ManualItemAddState extends State<ManualItemAdd> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _numberController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(children: <Widget>[
        Flexible(
          flex: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: TextFormField(
              controller: _nameController,
              style: new TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Item',
              ),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
        Flexible(
          flex: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: TextFormField(
              controller: _numberController,
              style: new TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number',
              ),
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: Container(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.playlist_add),
              color: Colors.green,
              onPressed: () => _confirmItem(context, Item(_nameController.text, _numberController.text)),
            ),
          ),
        ),
      ]),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _confirmItem(BuildContext context, Item item) {
    final _bloc = BlocProvider.of(context).bloc;
    switch (_bloc.validateItem(item)) {
      case 0:
        return _sendFeedbackMessage(context, FeedbackType.error, 'There are fields left that need to be filled.');
      case 1:
        return _sendFeedbackMessage(context, FeedbackType.error, 'The list already contains this item.');
      case 2:
        return _sendFeedbackMessage(context, FeedbackType.error, 'This number is already taken.');
      case 3:
        _addItemToItemList(context, item);
        return _sendFeedbackMessage(context, FeedbackType.light, 'Item added successfully.');
      default:
        return _sendFeedbackMessage(context, FeedbackType.error, 'There was an issue.');
    }
  }

  void _addItemToItemList(BuildContext context, Item item) {
    BlocProvider.of(context).bloc.addItemSink.add(item);
    _nameController.clear();
    _numberController.clear();
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _sendFeedbackMessage(
      BuildContext context, FeedbackType feedbacktype, String feedbackMessage) {
    Vibrate.feedback(feedbacktype);
    Scaffold.of(context).removeCurrentSnackBar();
    return Scaffold.of(context).showSnackBar(SnackBar(content: Text(feedbackMessage)));
  }
}
