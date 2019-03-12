import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';

import 'package:qr_list/bloc/itemListProvider.dart';
import 'package:qr_list/locale/locales.dart';
import 'package:qr_list/models/item.dart';
import 'package:qr_list/models/itemValidity.dart';

class ItemMask extends StatefulWidget {
  @override
  _ItemMaskState createState() {
    return new _ItemMaskState();
  }
}

class _ItemMaskState extends State<ItemMask> {
  TextEditingController _nameTextController = new TextEditingController();
  TextEditingController _numberTextController = new TextEditingController();
  FocusNode _nameFocusNode = new FocusNode();
  FocusNode _numberFocusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              keyboardAppearance: Theme.of(context).brightness,
              controller: _nameTextController,
              focusNode: _nameFocusNode,
              scrollPadding: const EdgeInsets.all(-50),
              onFieldSubmitted: (string) {
                if (_nameTextController.text == '') return FocusScope.of(context).requestFocus(_nameFocusNode);
                if (_numberTextController.text == '') return FocusScope.of(context).requestFocus(_numberFocusNode);
                _confirmItem(context, Item(_nameTextController.text, _numberTextController.text));
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: TextFormField(
              keyboardAppearance: Theme.of(context).brightness,
              controller: _numberTextController,
              focusNode: _numberFocusNode,
              scrollPadding: const EdgeInsets.all(-50),
              onFieldSubmitted: (string) {
                if (_numberTextController.text == '') return FocusScope.of(context).requestFocus(_numberFocusNode);
                if (_nameTextController.text == '') return FocusScope.of(context).requestFocus(_nameFocusNode);
                _confirmItem(context, Item(_nameTextController.text, _numberTextController.text));
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
          IconButton(
            icon: Icon(Icons.playlist_add),
            color: Theme.of(context).primaryColor,
            onPressed: () => _confirmItem(context, Item(_nameTextController.text, _numberTextController.text)),
          ),
        ],
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _confirmItem(BuildContext context, Item item) {
    switch (ItemListProvider.of(context).bloc.validateItem(item)) {
      case ItemValidity.emptyFields:
        return _sendFeedbackMessage(context, FeedbackType.warning, AppLocalizations.of(context).emptyFields, 3);
      case ItemValidity.itemExists:
        return _sendFeedbackMessage(context, FeedbackType.warning, AppLocalizations.of(context).itemExists, 3);
      case ItemValidity.numberExists:
        return _sendFeedbackMessage(context, FeedbackType.warning, AppLocalizations.of(context).numberExists, 3);
      case ItemValidity.valid:
        _addItemToItemList(context, item);
        return null;
      default:
        return _sendFeedbackMessage(context, FeedbackType.error, AppLocalizations.of(context).undefinedIssue, 3);
    }
  }

  void _addItemToItemList(BuildContext context, Item item) {
    ItemListProvider.of(context).bloc.addItem.add(item);
    _nameTextController.clear();
    _numberTextController.clear();
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _sendFeedbackMessage(
    BuildContext context,
    FeedbackType feedbacktype,
    String feedbackMessage,
    int duration,
  ) {
    Vibrate.feedback(feedbacktype);
    Scaffold.of(context).removeCurrentSnackBar();
    return Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(
          feedbackMessage,
          style: TextStyle(
            color: Theme.of(context).indicatorColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        duration: Duration(seconds: duration),
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _numberTextController.dispose();
    _nameFocusNode.dispose();
    _numberFocusNode.dispose();
    super.dispose();
  }
}
