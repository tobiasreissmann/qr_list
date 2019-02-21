import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';

import 'package:qr_list/gui/qrList.dart';
import 'package:qr_list/models/item.dart';

class ItemMask extends StatefulWidget {
  @override
  _ItemMaskState createState() {
    return new _ItemMaskState();
  }
}

class _ItemMaskState extends State<ItemMask> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _numberController = new TextEditingController();
  FocusNode _nameFocusNode = new FocusNode();
  FocusNode _numberFocusNode = new FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _nameFocusNode.dispose();
    _numberFocusNode.dispose();
    super.dispose();
  }

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
              focusNode: _nameFocusNode,
              onFieldSubmitted: (string) {
                if (_numberController.text == '') return FocusScope.of(context).requestFocus(_numberFocusNode);
                if (_nameController.text == '') return FocusScope.of(context).requestFocus(_nameFocusNode);
                _confirmItem(context, Item(_nameController.text, _numberController.text));
              },
              style: new TextStyle(
                color: Theme.of(context).cardColor,
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
              focusNode: _numberFocusNode,
              onFieldSubmitted: (string) {
                if (_numberController.text == '') return FocusScope.of(context).requestFocus(_numberFocusNode);
                if (_nameController.text == '') return FocusScope.of(context).requestFocus(_nameFocusNode);
                _confirmItem(context, Item(_nameController.text, _numberController.text));
              },
              style: new TextStyle(
                color: Theme.of(context).cardColor,
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
    final _itemListBloc = ItemListProvider.of(context).itemListBloc;
    switch (_itemListBloc.validateItem(item)) {
      case 0:
        return _sendFeedbackMessage(context, FeedbackType.warning, 'There are fields left that need to be filled.', 3);
      case 1:
        return _sendFeedbackMessage(context, FeedbackType.warning, 'The list already contains this item.', 3);
      case 2:
        return _sendFeedbackMessage(context, FeedbackType.warning, 'This number is already taken.', 3);
      case 3:
        _addItemToItemList(context, item);
        return null;
      default:
        return _sendFeedbackMessage(context, FeedbackType.error, 'There was an issue.', 3);
    }
  }

  void _addItemToItemList(BuildContext context, Item item) {
    ItemListProvider.of(context).itemListBloc.addItemSink.add(item);
    _nameController.clear();
    _numberController.clear();
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _sendFeedbackMessage(
      BuildContext context, FeedbackType feedbacktype, String feedbackMessage, int duration) {
    Vibrate.feedback(feedbacktype);
    Scaffold.of(context).removeCurrentSnackBar();
    return Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(feedbackMessage),
      duration: Duration(seconds: duration),
    ));
  }
}
