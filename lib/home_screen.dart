import 'package:flutter/material.dart';
import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:vibrate/vibrate.dart';
import 'package:sqflite/sqflite.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => new _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  List<Item> itemList = [];
  TextEditingController mName = TextEditingController();
  TextEditingController mNumber = TextEditingController();

  bool alphabetical = false;
  var _ev = 0;

  @override
  void dispose() {
    mName.dispose();
    mName.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Widget build(BuildContext context) {
    final bool showScan = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Text(
            'QR-Shoppinglist',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w300, fontSize: 24),
          ),
          actions: <Widget>[
            Container(
                child: _ev > 6
                    ? IconButton(
                        icon: Icon(Icons.favorite),
                        color: Colors.red,
                        onPressed: () {
                          setState(() {
                            _ev = 0;
                          });
                        })
                    : null),
            IconButton(
                icon: Icon(Icons.sort_by_alpha),
                color: alphabetical ? Colors.green : Colors.grey,
                onPressed: () {
                  setState(() {
                    alphabetical = !alphabetical;
                    if (alphabetical) {
                      itemList.sort((a, b) => a.name.compareTo(b.name));
                    }
                  });
                }),
            IconButton(
                icon: Icon(Icons.remove_circle),
                color: Colors.grey,
                onPressed: () {
                  deleteItemList();
                })
          ],
        ),
        body: Builder(
            builder: (context) => Stack(
                  children: <Widget>[
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Container(
                                  color: Colors.white,
                                  height: MediaQuery.of(context).size.height,
                                  child: ListView.builder(
                                    itemCount: itemList.length + 1,
                                    itemBuilder: (BuildContext context, int index) {
                                      if (index < itemList.length) {
                                        final item = itemList[index];
                                        return Dismissible(
                                            key: Key(item.name),
                                            onDismissed: (direction) {
                                              removeItem(itemList[index].name, itemList[index].number);
                                              setState(() => itemList.removeAt(index));
                                            },
                                            child: Padding(
                                                padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8, right: 8),
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(children: <Widget>[
                                                      Flexible(
                                                          flex: 0,
                                                          child: Container(
                                                            width: MediaQuery.of(context).size.width * 0.6,
                                                            padding: const EdgeInsets.only(right: 16.0),
                                                            child: Text(
                                                              item.name,
                                                              style: TextStyle(fontSize: 20.0),
                                                              overflow: TextOverflow.ellipsis,
                                                              textAlign: TextAlign.left,
                                                            ),
                                                          )),
                                                      Flexible(
                                                          fit: FlexFit.tight,
                                                          child: Container(
                                                              child: Text(item.number,
                                                                  style: TextStyle(fontSize: 26.0),
                                                                  overflow: TextOverflow.ellipsis,
                                                                  textAlign: TextAlign.left))),
                                                    ]),
                                                    Divider()
                                                  ],
                                                )));
                                      } else {
                                        return Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Row(children: <Widget>[
                                                Flexible(
                                                    flex: 0,
                                                    child: Container(
                                                        width: MediaQuery.of(context).size.width * 0.4,
                                                        padding: EdgeInsets.symmetric(horizontal: 4),
                                                        child: TextFormField(
                                                          controller: mName,
                                                          style: new TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 20,
                                                          ),
                                                          keyboardType: TextInputType.text,
                                                          decoration: const InputDecoration(
                                                            labelText: 'Item',
                                                          ),
                                                        ))),
                                                Flexible(
                                                    flex: 0,
                                                    child: Container(
                                                        width: MediaQuery.of(context).size.width * 0.5,
                                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                                        child: TextFormField(
                                                          controller: mNumber,
                                                          style: new TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 20,
                                                          ),
                                                          keyboardType: TextInputType.number,
                                                          decoration: const InputDecoration(
                                                            labelText: 'Number',
                                                          ),
                                                        ))),
                                                Flexible(
                                                    flex: 1,
                                                    child: Container(
                                                        alignment: Alignment.centerRight,
                                                        // width: MediaQuery.of(context).size.width * 0.1,
                                                        child: IconButton(
                                                          icon: Icon(Icons.check),
                                                          color: Colors.green[300],
                                                          onPressed: () {
                                                            return save(context);
                                                          },
                                                        )))
                                              ]),
                                            ),
                                            Container(height: 130)
                                          ],
                                        );
                                      }
                                    },
                                  )))
                        ]),
                    showScan
                        ? Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                            Center(
                                child: Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Container(
                                  child: ButtonTheme(
                                      minWidth: MediaQuery.of(context).size.width / 2,
                                      height: 100,
                                      buttonColor: Colors.white,
                                      child: RaisedButton(
                                          elevation: 8,
                                          textColor: Colors.green,
                                          onPressed: () {
                                            return scan(context);
                                          },
                                          child: const Text('SCAN', style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w300)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))))),
                            )),
                          ])
                        : Container(),
                  ],
                )));
  }

  Future scan(BuildContext context) async {
    try {
      Vibrate.feedback(FeedbackType.selection);
      String scan = await BarcodeScanner.scan();
      RegExp expNumber = new RegExp(r"([0-9])\w+");
      RegExp expNameKg = new RegExp(r"^.*\skg\s");
      RegExp expNameBund = new RegExp(r"^.*\sBund\s");
      RegExp expNameStueck = new RegExp(r"^.*\sStück\s");
      RegExp expValid = new RegExp(r"^VG\s([0-9]{3,4})");
      if (expValid.hasMatch(scan)) {
        if (expNameKg.hasMatch(scan)) {
          final name = scan.split(" kg ")[1];
          final number = expNumber.stringMatch(scan);
          if (itemList.where((item) => item.name == name && item.number == number).toList().length > 0) {
            Vibrate.feedback(FeedbackType.error);
            return Scaffold.of(context).showSnackBar(SnackBar(content: Text('This item was already scanned.')));
          } else {
            await addItem(name, number);
          }
        } else {
          if (expNameBund.hasMatch(scan)) {
            final name = scan.split(" Bund ")[1];
            final number = expNumber.stringMatch(scan);
            if (itemList.where((item) => item.name == name && item.number == number).toList().length > 0) {
              Vibrate.feedback(FeedbackType.error);
              return Scaffold.of(context).showSnackBar(SnackBar(content: Text('This item was already scanned.')));
            } else {
              await addItem(name, number);
            }
          } else {
            if (expNameStueck.hasMatch(scan)) {
              final name = scan.split(" Stück ")[1];
              final number = expNumber.stringMatch(scan);
              if (itemList.where((item) => item.name == name && item.number == number).toList().length > 0) {
                Vibrate.feedback(FeedbackType.error);
                return Scaffold.of(context).showSnackBar(SnackBar(content: Text('This item was already scanned.')));
              } else {
                await addItem(name, number);
              }
            } else {
              return Scaffold.of(context).showSnackBar(SnackBar(content: Text('There was a problem recognizing the item.')));
            }
          }
        }
      } else {
        return Scaffold.of(context).showSnackBar(SnackBar(content: Text('This barcode / qr-code is not supported.')));
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        return Scaffold.of(context).showSnackBar(SnackBar(content: Text('To scan items the permisson for camera access is required.')));
      } else {}
    } on FormatException {} catch (e) {}
    return null;
  }

  save(BuildContext context) async {
    setState(() => _ev++);
    if (itemList.where((item) => item.name == mName.text && item.number == mNumber.text).toList().length > 0) {
      Vibrate.feedback(FeedbackType.error);
      return Scaffold.of(context).showSnackBar(SnackBar(content: Text('The list already contains this item.')));
    } else {
      if (itemList.where((item) => item.number == mNumber.text).toList().length > 0) {
        Vibrate.feedback(FeedbackType.error);
        return Scaffold.of(context).showSnackBar(SnackBar(content: Text('This number is already taken.')));
      } else {
        if (mName.text != '' && mNumber.text != '') {
          var name = mName.text;
          var number = mNumber.text;
          await addItem(name, number);
          mName.text = '';
          mNumber.text = '';
          _ev = 0;
        }
      }
      return null;
    }
  }

  void getData() async {
    String path = join(await getDatabasesPath(), 'items.db');
    Database database = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE Items (name TEXT, number TEXT PRIMARY KEY)');
    });
    List<Map> list = await database.rawQuery('SELECT * FROM Items');
    List<Item> _itemList = [];
    for (var i = 0; i < list.length; i++) {
      _itemList.add(Item(list[i]['name'], list[i]['number']));
    }
    setState(() => itemList = _itemList);
    await database.close();
  }

  deleteItemList() async {
    String path = join(await getDatabasesPath(), 'items.db');
    Database database = await openDatabase(path);
      await database.transaction((txn) async {
        await txn.rawInsert('DELETE FROM Items');
      });
    getData();
  }

  addItem(String name, String number) async {
    if (name != '' && number != '') {
      Vibrate.feedback(FeedbackType.success);
      String path = join(await getDatabasesPath(), 'items.db');
      Database database = await openDatabase(path);
      await database.transaction((txn) async {
        await txn.rawInsert('INSERT INTO Items(name, number) VALUES("$name", "$number")');
      });
      // await database.close();
      setState(() {
        itemList.add(Item(name, number));
        if (alphabetical) {
          itemList.sort((a, b) => a.name.compareTo(b.name));
        }
      });
    } else {}
  }

  removeItem(String name, String number) async {
    String path = join(await getDatabasesPath(), 'items.db');
    Database database = await openDatabase(path);
    await database.rawDelete('DELETE FROM Items WHERE number = $number');
    getData();
  }
}

class Item {
  String name;
  String number;

  Item(this.name, this.number);
}
