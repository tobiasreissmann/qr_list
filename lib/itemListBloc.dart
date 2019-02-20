import 'dart:async';

import 'package:qr_list/models/item.dart';
import 'package:rxdart/rxdart.dart';

class ItemListBloc {
  List<Item> _itemList = [];
  List<Item> _backupItemList = [];

  final _itemStateController = BehaviorSubject<List<Item>>();
  StreamSink<List<Item>> get _inItemListSink => _itemStateController.sink;
  Stream<List<Item>> get itemListStream => _itemStateController.stream;

  final _itemController = StreamController<Item>();
  StreamSink<Item> get addItemSink => _itemController.sink;

  final _deleteItemController = StreamController<String>();
  StreamSink<String> get deleteItemSink => _deleteItemController.sink;

  ItemListBloc() {
    _itemController.stream.listen(_mapItemToItemList);
    _deleteItemController.stream.listen(_removeItemFromList);
  }

  void _mapItemToItemList(Item item) {
    _itemList.add(item);
    _inItemListSink.add(_itemList);
  }

  void _removeItemFromList(String number) {
    _backupItemList = _itemList;
    _itemList = _itemList.where((_item) => _item.number != number).toList();
    _inItemListSink.add(_itemList);
  }

  void deleteItemList() {
    _backupItemList = _itemList;
    _itemList = [];
    _inItemListSink.add(_itemList);
  }

  void revertItemList() {
    _itemList = _backupItemList;
    _inItemListSink.add(_itemList);
  }

  int validateItem(Item item) {
    /*
     * number legend :
     * 0 -> one field is empty
     * 1 -> item is already listed
     * 2 -> number is already given 
     * 3 -> success
     */
    if (item.number == '' || item.name == '') return 0;
    if (_itemList.where((_item) => _item.name == item.name && _item.number == item.number).toList().length > 0)
      return 1; //errorMessage(context, 'The list already contains this item.');
    if (_itemList.where((_item) => _item.number == item.number).toList().length > 0)
      return 2; // errorMessage(context, 'This number is already taken.');
    return 3;
  }

  void dispose() {
    _itemStateController.close();
    _itemController.close();
    _deleteItemController.close();
  }
}
