import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_list/data.service.dart';
import 'package:qr_list/globals.dart';
import 'package:qr_list/item.dart';
import 'package:qr_list/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibrate/vibrate.dart';

main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.white));
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR-Shoppinglist',
      theme: ThemeData(
        accentColor: Colors.green,
        brightness: Brightness.light,
        cursorColor: Colors.green,
        primaryColor: Colors.green,
        textSelectionColor: Colors.green,
      ),
      home: QRList(),
    );
  }
}

class QRList extends StatefulWidget {
  @override
  _QRList createState() => new _QRList();
}

class _QRList extends State<QRList> {
  @override
  initState() {
    super.initState();
    readSetting();
    getData();
    mName = TextEditingController();
    mNumber = TextEditingController();
  }

  @override
  dispose() {
    mName.dispose();
    mName.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          'QR-Shoppinglist',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w400, fontSize: 24),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.sort_by_alpha),
              color: alphabetical ? Colors.green : Colors.grey,
              onPressed: () {
                alphabetical = !alphabetical;
                alphabetical ? alphabetize() : getData();
                saveSetting();
              }),
          IconButton(
              icon: Icon(Icons.delete_sweep),
              color: Colors.red[700],
              onPressed: () {
                deleteItemList();
                getData();
              }),
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
                                    child: ItemEntry(index: index));
                              } else {
                                return Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Row(children: <Widget>[
                                        Flexible(
                                          flex: 0,
                                          child: Container(
                                            width: MediaQuery.of(context).size.width * 0.4,
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
                                            ),
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
                                        Flexible(
                                          flex: 0,
                                          child: Container(
                                            width: MediaQuery.of(context).size.width * 0.4,
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
                                              onPressed: () {
                                                manualAdd(context);
                                              },
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    Container(height: 150)
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ]),
                MediaQuery.of(context).viewInsets.bottom == 0.0
                    ? Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 24),
                            child: Container(
                              child: ButtonTheme(
                                minWidth: MediaQuery.of(context).size.width / 2,
                                height: 70,
                                buttonColor: Colors.green,
                                child: RaisedButton(
                                  elevation: 8,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    Vibrate.feedback(FeedbackType.selection);
                                    return scanItem(context);
                                  },
                                  child: const Text('SCAN', style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w300)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ])
                    : Container(),
              ],
            ),
      ),
    );
  }

  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>> scanItem(BuildContext context) async {
    try {
      // get scan
      final String scan = await BarcodeScanner.scan();

      // define regex for validation checks
      final RegExp expScan = new RegExp(r"^VG\s([0-9]{3,4})");
      final RegExp expNumber = new RegExp(r"([0-9])\w+");
      final RegExp expNameKg = new RegExp(r"^.*\skg\s");
      final RegExp expNameBund = new RegExp(r"^.*\sBund\s");
      final RegExp expNameStueck = new RegExp(r"^.*\sStück\s");

      String name = '';
      String number = expNumber.stringMatch(scan);

      // check if scan is of valid format
      if (!expScan.hasMatch(scan)) return errorMessage(context, 'This barcode / qr-code is not supported');

      // find item type
      if (expNameKg.hasMatch(scan)) name = scan.split(" kg ")[1];
      if (expNameBund.hasMatch(scan)) name = scan.split(" Bund ")[1];
      if (expNameStueck.hasMatch(scan)) name = scan.split(" Stück ")[1];

      // check whether there was a valid name found
      if (name == '') return errorMessage(context, 'There was a problem recognizing the item.');
      if (itemList.where((item) => item.name == name && item.number == number).toList().length > 0)
        return errorMessage(context, 'This item was already scanned.');
      if (itemList.where((item) => item.number == number).toList().length > 0) return errorMessage(context, 'This number is already taken.');

      // no problems -> add Item
      await addDatabaseItem(name, number);
      setState(() {
        itemList.add(Item(name, number));
      });
      return successMessage(context);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) return errorMessage(context, 'To scan items the permisson for camera access is required.');
    }
    return errorMessage(context, 'There was an undefined problem.');
  }

  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>> manualAdd(BuildContext context) async {
    if (mNumber.text == '' || mName.text == '') return errorMessage(context, 'There are fields left that need to be filled.');
    if (itemList.where((item) => item.name == mName.text && item.number == mNumber.text).toList().length > 0)
      return errorMessage(context, 'The list already contains this item.');
    if (itemList.where((item) => item.number == mNumber.text).toList().length > 0) return errorMessage(context, 'This number is already taken.');

    // no problems -> add item to itemList
    await addDatabaseItem(mName.text, mNumber.text);
    setState(() {
      itemList.add(Item(mName.text, mNumber.text));
      mName.text = '';
      mNumber.text = '';
    });
    return successMessage(context);
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> errorMessage(BuildContext context, String errorText) {
    Vibrate.feedback(FeedbackType.error);
    return Scaffold.of(context).showSnackBar(SnackBar(content: Text(errorText)));
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> successMessage(BuildContext context) {
    Vibrate.feedback(FeedbackType.light);
    return Scaffold.of(context).showSnackBar(SnackBar(content: Text('Item added successfully.')));
  }

  void getData() async {
    List<Item> _itemList = await getDatabaseItems();
    setState(() {
      itemList = _itemList;
      if (alphabetical) itemList.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  void alphabetize() {
    setState(() {
      itemList.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  void saveSetting() async {
    // save alphabetical setting
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('alphabetical', alphabetical);
  }

  void readSetting() async {
    // get saved alphabetical setting
    final prefs = await SharedPreferences.getInstance();
    alphabetical = prefs.getBool('alphabetical') ?? false;
  }
}
