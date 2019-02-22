import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:qr_list/models/item.dart';

Future<Database> get database async {
  String path = join(await getDatabasesPath(), 'items.db');
  return await openDatabase(path);
}

Future<List<Item>> get databaseItemList async {
  String path = join(await getDatabasesPath(), 'items.db');
  Database database = await openDatabase(path,
      version: 1, onCreate: (Database db, int version) async => await db.execute('CREATE TABLE Items (name TEXT, number TEXT PRIMARY KEY)'));
  List<Map> _list = await database.rawQuery('SELECT * FROM Items');
  List<Item> _itemList = [];
  _list.forEach((entry) => _itemList.add(Item(entry['name'], entry['number'])));
  return _itemList;
}

void databaseDeleteTable() async {
  Database _database = await database;
  await _database.transaction((txn) async => await txn.rawInsert('DELETE FROM Items'));
}

void databaseAddItem(Item item) async {
  Database _database = await database;
  await _database.transaction((txn) async => await txn.rawInsert('INSERT INTO Items(name, number) VALUES("${item.name}", "${item.number}")'));
}

void databaseSaveItemList(List<Item> itemList) async {
  Database _database = await database;
  await _database.transaction((txn) async => await txn.rawInsert('DELETE FROM Items'));
  itemList.forEach(
    (item) async =>
        await _database.transaction((txn) async => await txn.rawInsert('INSERT INTO Items(name, number) VALUES("${item.name}", "${item.number}")')),
  );
}

void databaseRemoveItem(String number) async {
  Database _database = await database;
  await _database.rawDelete('DELETE FROM Items WHERE number = "$number"');
}
