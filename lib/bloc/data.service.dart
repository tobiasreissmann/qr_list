import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:qr_list/models/item.dart';

Future<Database> getDatabase() async {
  String path = join(await getDatabasesPath(), 'items.db');
  return await openDatabase(path);
}

Future<List<Item>>getDatabaseItems() async {
  String path = join(await getDatabasesPath(), 'items.db');
  Database database = await openDatabase(path, version: 1, onCreate: (Database db, int version) async => await db.execute('CREATE TABLE Items (name TEXT, number TEXT PRIMARY KEY)'));
  List<Map> list = await database.rawQuery('SELECT * FROM Items');
  List<Item> _itemList = [];
  for (var i = 0; i < list.length; i++) _itemList.add(Item(list[i]['name'], list[i]['number']));
  await database.close();
  return _itemList;  
}

void deleteItemList() async {
  Database database = await getDatabase();
  await database.transaction((txn) async => await txn.rawInsert('DELETE FROM Items'));
}

Future addDatabaseItem(String name, String number) async {
  Database database = await getDatabase();
  await database.transaction((txn) async => await txn.rawInsert('INSERT INTO Items(name, number) VALUES("$name", "$number")'));
}

void removeItem(String name, String number) async {
  Database database = await getDatabase();
  await database.rawDelete('DELETE FROM Items WHERE number = "$number"');
}
