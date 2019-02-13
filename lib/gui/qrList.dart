import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibrate/vibrate.dart';

import 'package:qr_list/globals.dart';
import 'package:qr_list/gui/widgets/itemEntry.dart';
import 'package:qr_list/gui/widgets/manualItemAdd.dart';
import 'package:qr_list/gui/widgets/scan.dart';
import 'package:qr_list/models/item.dart';
import 'package:qr_list/services/data.service.dart';

class QRList extends StatefulWidget {
  @override
  _QRList createState() => new _QRList();
}

class _QRList extends State<QRList> {
  ScrollController _scrollController = new ScrollController();

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
                            controller: _scrollController,
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
                                    ManualItemAdd(
                                      onSubmitted: () {
                                        return manualAdd(context);
                                      },
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
                          child: ScanButton(
                            onSubmitted: () {
                              Vibrate.feedback(FeedbackType.selection);
                              return scanItem(context);
                            }
                          )
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
      if(!alphabetical) _scrollController.jumpTo(_scrollController.position.maxScrollExtent+150);
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
