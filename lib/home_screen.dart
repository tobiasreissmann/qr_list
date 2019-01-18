import 'package:flutter/material.dart';
import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => new _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  List<Item> itemList = [];
  TextEditingController mName = TextEditingController();
  TextEditingController mNumber = TextEditingController();

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
          centerTitle: true,
          title: Text('QR-Shoppinglist'),
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
                          height: MediaQuery.of(context).size.height,
                          child: ListView.builder(
                            itemCount: itemList.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index < itemList.length) {
                                return Card(
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(children: <Widget>[
                                          Column(children: <Widget>[
                                            Container(
                                                padding: const EdgeInsets.only(right: 16.0),
                                                width: MediaQuery.of(context).size.width * 0.6,
                                                child: Row(children: <Widget>[
                                                  Text(itemList[index].name,
                                                      style: TextStyle(fontSize: 18.0), textAlign: TextAlign.left),
                                                ]))
                                          ]),
                                          Column(children: <Widget>[
                                            Container(
                                                width: MediaQuery.of(context).size.width * 0.2,
                                                // padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: <Widget>[
                                                      Text(itemList[index].number,
                                                          style: TextStyle(fontSize: 26.0), textAlign: TextAlign.right)
                                                    ]))
                                          ]),
                                          Column(
                                            children: <Widget>[
                                              Container(
                                                  width: MediaQuery.of(context).size.width * 0.1,
                                                  child: IconButton(
                                                      icon: Icon(Icons.cancel),
                                                      color: Colors.grey[300],
                                                      onPressed: () {
                                                        setState(() {
                                                          this.itemList.removeAt(index);
                                                        });
                                                      }))
                                            ],
                                          )
                                        ])));
                              } else {
                                return Column(
                                  children: <Widget>[
                                    Card(
                                        child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(children: <Widget>[
                                        Column(children: <Widget>[
                                          Container(
                                              width: MediaQuery.of(context).size.width * 0.4,
                                              padding: EdgeInsets.only(right: 4),
                                              child: TextFormField(
                                                controller: mName,
                                                keyboardType: TextInputType.text,
                                                decoration: const InputDecoration(
                                                  labelText: 'Item',
                                                ),
                                              ))
                                        ]),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                                width: MediaQuery.of(context).size.width * 0.4,
                                                child: TextFormField(
                                                  controller: mNumber,
                                                  keyboardType: TextInputType.number,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Number',
                                                  ),
                                                ))
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                                width: MediaQuery.of(context).size.width * 0.1,
                                                child: IconButton(
                                                  icon: Icon(Icons.check),
                                                  color: Colors.green[300],
                                                  onPressed: save,
                                                ))
                                          ],
                                        )
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
                              child: RaisedButton(
                                textColor: Colors.white,
                                onPressed: scan,
                                child: const Text('SCAN', style: TextStyle(fontSize: 32.0)),
                              ))),
                    )),
                  ])
                : Container(),
          ],
        ));
  }

  Future scan() async {
    try {
      String scan = await BarcodeScanner.scan();
      RegExp expNumber = new RegExp(r"([0-9])\w+");
      // RegExp expName = new RegExp(r"^.*\skg\s|^.*\sStück\s|^.*\sBund\s");
      RegExp expValid = new RegExp(r"^VG\s([0-9]{3,4})");
      if (expValid.hasMatch(scan)) {
        setState(() => this.itemList.add(Item(scan.split(" kg ")[1], expNumber.stringMatch(scan))));
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
      } else {}
    } on FormatException {} catch (e) {}
  }

  save() {
    setState(() {
      if(mName.text != '' && mNumber.text != '') {
        itemList.add(Item(mName.text, mNumber.text));
        mName.text = '';
        mNumber.text = '';
      }
    });
  }
}

class Item {
  String name;
  String number;

  Item(this.name, this.number);
}
