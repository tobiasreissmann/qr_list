import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qr_list/models/item.dart';
import 'package:qr_list/services/database.service.dart';

class ItemListBloc {
  bool _alphabetical = false;

  List<Item> _itemList = [];
  List<Item> _backupItemList = [];

  void dispose() {
    _itemListController.close();
    _addItemController.close();
    _deleteItemController.close();
    _alphabeticalController.close();
  }

  // stream to publish the itemList
  final _itemListController = BehaviorSubject<List<Item>>();
  StreamSink<List<Item>> get _inItemListSink => _itemListController.sink;
  Stream<List<Item>> get itemListStream => _itemListController.stream;

  // stream to add item
  final _addItemController = StreamController<Item>();
  StreamSink<Item> get addItemSink => _addItemController.sink;

  // stream to delete item
  final _deleteItemController = StreamController<String>();
  StreamSink<String> get deleteItemSink => _deleteItemController.sink;

  // stream to publish alphabetical
  final _alphabeticalController = BehaviorSubject<bool>();
  StreamSink<bool> get _inAlphabeticalSink => _alphabeticalController.sink;
  Stream<bool> get alphabeticalStream => _alphabeticalController.stream;

  ItemListBloc() {
    _inItemListSink.add(_itemList);
    _inAlphabeticalSink.add(_alphabetical);
    _loadData();

    _addItemController.stream.listen(_addItemToItemList);
    _deleteItemController.stream.listen(_removeItemFromItemList);
  }

  void _addItemToItemList(Item item) {
    _itemList.add(item);
    _alphabetical ? _inItemListSink.add(_sortList(_itemList.toList())) : _inItemListSink.add(_itemList);
    databaseDeleteItem(item);
  }

  void _removeItemFromItemList(String number) {
    _backupItemList = _itemList;
    _itemList = _itemList.where((_item) => _item.number != number).toList();
    _alphabetical ? _inItemListSink.add(_sortList(_itemList.toList())) : _inItemListSink.add(_itemList);
    databaseRemoveItem(number);
  }

  void toggleAlphabetical() {
    _alphabetical = !_alphabetical;
    _inAlphabeticalSink.add(_alphabetical);
    _alphabetical ? _inItemListSink.add(_sortList(_itemList.toList())) : _inItemListSink.add(_itemList);
    _saveSettings();
  }

  void deleteItemList() {
    _backupItemList = _itemList;
    _itemList = [];
    _alphabetical ? _inItemListSink.add(_sortList(_itemList.toList())) : _inItemListSink.add(_itemList);
    databaseDeleteTable();
  }

  // for undo functionality
  void revertItemList() {
    _itemList = _backupItemList;
    _alphabetical ? _inItemListSink.add(_sortList(_itemList.toList())) : _inItemListSink.add(_itemList);
  }

  List<Item> _sortList(List<Item> _list) {
    _list.sort((a, b) => a.name.compareTo(b.name));
    return _list.toList();
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
    if (_itemList.where((_item) => _item.name == item.name && _item.number == item.number).toList().length > 0) return 1;
    if (_itemList.where((_item) => _item.number == item.number).toList().length > 0) return 2;
    return 3;
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('alphabetical', _alphabetical);
  }

  void _loadData() async {
    // getting settings
    final prefs = await SharedPreferences.getInstance();
    _alphabetical = prefs.getBool('alphabetical') ?? false;
    _inAlphabeticalSink.add(_alphabetical);

    // getting data
    _itemList = await databaseItemList;

    _alphabetical ? _inItemListSink.add(_sortList(_itemList.toList())) : _inItemListSink.add(_itemList);
  }
}
