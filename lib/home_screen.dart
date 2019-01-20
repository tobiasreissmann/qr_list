import 'package:flutter/material.dart';
import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:vibrate/vibrate.dart';  
// import 'package:flutter/gestures.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => new _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  List<Item> itemList = [];
  TextEditingController mName = TextEditingController();
  TextEditingController mNumber = TextEditingController();
  var _ev = 0;

  @override
  void dispose() {
    mName.dispose();
    mName.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final bool showScan = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          // centerTitle: true,
          title: Text(
            'QR-Shoppinglist',
            style: TextStyle(
                color: Colors.green, fontWeight: FontWeight.w300, fontSize: 24),
          ),
          actions: _ev > 6
              ? <Widget>[
                  IconButton(
                      icon: Icon(Icons.favorite),
                      color: Colors.red,
                      onPressed: () {
                        return AlertDialog(
                            content: Text('A.L.F.'),
                            actions: <Widget>[
                              FlatButton(
                                child: Icon(Icons.favorite_border),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ]);
                      })
                ]
              : null,
        ),
        body: Stack(
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
                            padding: EdgeInsets.only(top: 16),
                            itemCount: itemList.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index < itemList.length) {
                                return Card(
                                    elevation: 5,
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(children: <Widget>[
                                          Flexible(
                                              flex: 0,
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.6,
                                                padding: const EdgeInsets.only(
                                                    right: 16.0),
                                                child: Text(
                                                  itemList[index].name,
                                                  style:
                                                      TextStyle(fontSize: 20.0),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.left,
                                                ),
                                              )),
                                          Flexible(
                                              fit: FlexFit.tight,
                                              child: Container(
                                                  child: Text(
                                                      itemList[index].number,
                                                      style: TextStyle(
                                                          fontSize: 26.0),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.left))),
                                          Flexible(
                                              flex: 1,
                                              child: Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: IconButton(
                                                      icon: Icon(Icons.cancel),
                                                      color: Colors.grey[300],
                                                      onPressed: () {
                                                        setState(() {
                                                          this
                                                              .itemList
                                                              .removeAt(index);
                                                        });
                                                      })))
                                        ])));
                              } else {
                                return Column(
                                  children: <Widget>[
                                    Card(
                                      elevation: 5,
                                        child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Row(children: <Widget>[
                                        Flexible(
                                            flex: 0,
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 4),
                                                child: TextFormField(
                                                  controller: mName,
                                                  style: new TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                  ),
                                                  keyboardType:
                                                      TextInputType.text,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Item',
                                                  ),
                                                ))),
                                        Flexible(
                                            flex: 0,
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: TextFormField(
                                                  controller: mNumber,
                                                  style: new TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Number',
                                                  ),
                                                ))),
                                        Flexible(
                                            flex: 1,
                                            child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                // width: MediaQuery.of(context).size.width * 0.1,
                                                child: IconButton(
                                                  icon: Icon(Icons.check),
                                                  color: Colors.green[300],
                                                  onPressed: save,
                                                )))
                                      ]),
                                    )),
                                    Container(height: 116)
                                  ],
                                );
                              }
                            },
                          ))),
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
                                  textColor: Colors.green,
                                  onPressed: scan,
                                  child: const Text('SCAN',
                                      style: TextStyle(
                                          fontSize: 32.0,
                                          fontWeight: FontWeight.w300)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20))))),
                    )),
                  ])
                : Container(),
          ],
        ));
  }

  Future scan() async {
    try {
      print(await Vibrate.canVibrate);
      Vibrate.feedback(FeedbackType.light);
      String scan = await BarcodeScanner.scan();
      RegExp expNumber = new RegExp(r"([0-9])\w+");
      RegExp expNameKg = new RegExp(r"^.*\skg\s");
      RegExp expNameBund = new RegExp(r"^.*\sBund\s");
      RegExp expNameStueck = new RegExp(r"^.*\sStück\s");
      RegExp expValid = new RegExp(r"^VG\s([0-9]{3,4})");
      if (expValid.hasMatch(scan)) {
        if (expNameKg.hasMatch(scan)) {
          setState(() => this
              .itemList
              .add(Item(scan.split(" kg ")[1], expNumber.stringMatch(scan))));
        } else {
          if (expNameBund.hasMatch(scan)) {
            setState(() => this.itemList.add(
                Item(scan.split(" Bund ")[1], expNumber.stringMatch(scan))));
          } else {
            if (expNameStueck.hasMatch(scan)) {
              setState(() => this.itemList.add(
                  Item(scan.split(" Stück ")[1], expNumber.stringMatch(scan))));
            }
          }
        }
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
      } else {}
    } on FormatException {} catch (e) {}
  }

  save() {
    _ev++;
    setState(() {
      if (mName.text != '' && mNumber.text != '') {
        itemList.add(Item(mName.text, mNumber.text));
        mName.text = '';
        mNumber.text = '';
        _ev = 0;
      }
    });
  }
}

class Item {
  String name;
  String number;

  Item(this.name, this.number);
}
