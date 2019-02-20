import 'dart:async';

import 'package:qr_list/models/item.dart';
import 'package:qr_list/models/sinkEvent.dart';
import 'package:rxdart/rxdart.dart';

class ItemListBloc {
  bool _alphabetical = false;

  List<Item> _itemList = [];
  List<Item> _backupItemList = [];

  final _itemListController = BehaviorSubject<List<Item>>();
  StreamSink<List<Item>> get _inItemListSink => _itemListController.sink;
  Stream<List<Item>> get itemListStream => _itemListController.stream;

  final _addItemController = StreamController<Item>();
  StreamSink<Item> get addItemSink => _addItemController.sink;

  final _deleteItemController = StreamController<String>();
  StreamSink<String> get deleteItemSink => _deleteItemController.sink;

  final _toogleAlphabeticalController = StreamController<SinkEvent>();
  StreamSink<SinkEvent> get toogleAlphabeticalSink => _toogleAlphabeticalController.sink;

  final _spreadAlphabeticalController = BehaviorSubject<bool>();
  StreamSink<bool> get _inAlphabeticalSink => _spreadAlphabeticalController.sink;
  Stream<bool> get alphabeticalStream => _spreadAlphabeticalController.stream;

  ItemListBloc() {
    _inItemListSink.add(_itemList);
    _inAlphabeticalSink.add(_alphabetical);

    _addItemController.stream.listen(_mapItemToItemList);
    _deleteItemController.stream.listen(_removeItemFromList);
    _toogleAlphabeticalController.stream.listen(_toggleAlphabetical);
  }

  void _mapItemToItemList(Item item) {
    _itemList.add(item);
    _alphabetical ? _inItemListSink.add(_sortList(_itemList.toList())) : _inItemListSink.add(_itemList);
  }

  void _removeItemFromList(String number) {
    _backupItemList = _itemList;
    _itemList = _itemList.where((_item) => _item.number != number).toList();
    _alphabetical ? _inItemListSink.add(_sortList(_itemList.toList())) : _inItemListSink.add(_itemList);
  }

  void _toggleAlphabetical(SinkEvent event) {
    _alphabetical = !_alphabetical;
    _inAlphabeticalSink.add(_alphabetical);
    _alphabetical ? _inItemListSink.add(_sortList(_itemList.toList())) : _inItemListSink.add(_itemList);
  }

  void deleteItemList() {
    _backupItemList = _itemList;
    _itemList = [];
    _alphabetical ? _inItemListSink.add(_sortList(_itemList.toList())) : _inItemListSink.add(_itemList);
  }

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

  void dispose() {
    _itemListController.close();
    _addItemController.close();
    _deleteItemController.close();
    _toogleAlphabeticalController.close();
    _spreadAlphabeticalController.close();
  }
}
