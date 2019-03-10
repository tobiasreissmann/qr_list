import 'package:flutter/material.dart';
import 'package:qr_list/locale/locales.dart';
import 'package:vibrate/vibrate.dart';

import 'package:qr_list/bloc/itemListProvider.dart';
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
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: TextFormField(
                keyboardAppearance: Theme.of(context).brightness,
                controller: _nameController,
                focusNode: _nameFocusNode,
                scrollPadding: EdgeInsets.all(-50),
                onFieldSubmitted: (string) {
                  if (_nameController.text == '') return FocusScope.of(context).requestFocus(_nameFocusNode);
                  if (_numberController.text == '') return FocusScope.of(context).requestFocus(_numberFocusNode);
                  _confirmItem(context, Item(_nameController.text, _numberController.text));
                },
                style: new TextStyle(
                  color: Theme.of(context).indicatorColor,
                  fontSize: 20,
                ),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    gapPadding: 0,
                  ),
                  labelText: AppLocalizations.of(context).item,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: Container(
              child: TextFormField(
                keyboardAppearance: Theme.of(context).brightness,
                controller: _numberController,
                focusNode: _numberFocusNode,
                scrollPadding: EdgeInsets.all(-50),
                onFieldSubmitted: (string) {
                  if (_numberController.text == '') return FocusScope.of(context).requestFocus(_numberFocusNode);
                  if (_nameController.text == '') return FocusScope.of(context).requestFocus(_nameFocusNode);
                  _confirmItem(context, Item(_nameController.text, _numberController.text));
                },
                style: TextStyle(
                  color: Theme.of(context).indicatorColor,
                  fontSize: 20,
                ),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    gapPadding: 0,
                  ),
                  labelText: AppLocalizations.of(context).number,
                ),
              ),
            ),
          ),
          Container(
            child: IconButton(
              icon: Icon(Icons.playlist_add),
              color: Theme.of(context).primaryColor,
              onPressed: () => _confirmItem(context, Item(_nameController.text, _numberController.text)),
            ),
          ),
        ],
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _confirmItem(BuildContext context, Item item) {
    final _itemListBloc = ItemListProvider.of(context).itemListBloc;
    switch (_itemListBloc.validateItem(item)) {
      case 0:
        return _sendFeedbackMessage(context, FeedbackType.warning, AppLocalizations.of(context).emptyFields, 3);
      case 1:
        return _sendFeedbackMessage(context, FeedbackType.warning, AppLocalizations.of(context).itemExists, 3);
      case 2:
        return _sendFeedbackMessage(context, FeedbackType.warning, AppLocalizations.of(context).numberExists, 3);
      case 3:
        _addItemToItemList(context, item);
        return null;
      default:
        return _sendFeedbackMessage(context, FeedbackType.error, AppLocalizations.of(context).undefinedIssue, 3);
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
      content: Text(
        feedbackMessage,
        style: TextStyle(
          color: Theme.of(context).indicatorColor,
          fontWeight: FontWeight.w400,
        ),
      ),
      duration: Duration(seconds: duration),
      backgroundColor: Theme.of(context).cardColor,
    ));
  }
}
