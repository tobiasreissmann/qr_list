import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qr_list/models/itemValidity.dart';
import 'package:qr_list/models/item.dart';
import 'package:qr_list/services/database.service.dart';

class ItemListBloc {
  ItemListBloc() {
    _loadData();

    _addItemStream.listen(_addItemToItemList);
    _deleteItemStream.listen(_removeItemFromItemList);
  }

  // previous for revert / undo features
  List<Item> _backupItemList = [];

  // stream to publish the itemList
  final _itemListController = BehaviorSubject<List<Item>>();
  StreamSink<List<Item>> get _inItemListSink => _itemListController.sink;
  Stream<List<Item>> get itemListStream => _itemListController.stream;
  List<Item> get itemList => _itemListController.value.toList();

  // stream to add item
  final _addItemController = StreamController<Item>();
  StreamSink<Item> get addItem => _addItemController.sink;
  Stream<Item> get _addItemStream => _addItemController.stream;

  // stream to delete item
  final _deleteItemController = StreamController<String>();
  StreamSink<String> get deleteItem => _deleteItemController.sink;
  Stream<String> get _deleteItemStream => _deleteItemController.stream;

  // stream to toggle alphabetical
  final _alphabeticalController = BehaviorSubject<bool>();
  StreamSink<bool> get _inAlphabeticalSink => _alphabeticalController.sink;
  Stream<bool> get alphabeticalStream => _alphabeticalController.stream;
  bool get alphabetical => _alphabeticalController.value;

  void _addItemToItemList(Item _item) {
    _inItemListSink.add(_formatItemList(itemList.toList()..add(_item)));
    databaseAddItem(_item);
  }

  void _removeItemFromItemList(String number) {
    _backupItemList = itemList;
    _inItemListSink.add(_formatItemList(itemList.where((_item) => _item.number != number).toList()));
    databaseRemoveItem(number);
  }

  void toggleAlphabetical() async {
    _inAlphabeticalSink.add(!alphabetical);
    // need to get databaseItemList to possibly restore original order
    _inItemListSink.add(_formatItemList(await databaseItemList));
    _saveSettings();
  }

  void deleteItemList() {
    _backupItemList = itemList;
    _inItemListSink.add([]);
    databaseDeleteTable();
  }

  // undo functionality
  void revertItemList() {
    _inItemListSink.add(_formatItemList(_backupItemList));
    databaseSaveItemList(itemList);
  }

  List<Item> _formatItemList(List<Item> _itemList) {
    return alphabetical ? (_itemList.toList()..sort((a, b) => a.name.compareTo(b.name))) : _itemList.toList();
  }

  ItemValidity validateItem(Item item) {
    if (item.number == '' || item.name == '') return ItemValidity.emptyFields;
    if (itemList.where((_item) => _item.name == item.name && _item.number == item.number).toList().length > 0)
      return ItemValidity.itemExists;
    if (itemList.where((_item) => _item.number == item.number).toList().length > 0) return ItemValidity.numberExists;
    return ItemValidity.valid;
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('alphabetical', alphabetical);
  }

  void _loadData() async {
    // getting settings
    final prefs = await SharedPreferences.getInstance();
    _inAlphabeticalSink.add(prefs.getBool('alphabetical') ?? false);

    // getting data
    _inItemListSink.add(_formatItemList(await databaseItemList));
  }

  void close() {
    _itemListController.close();
    _addItemController.close();
    _deleteItemController.close();
    _alphabeticalController.close();
  }
}
