import 'package:flutter/material.dart';
import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => new _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  List<String> itemList = [];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('QR-Shoppinglist'),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: ListView.builder(
                      itemCount: itemList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Container(
                                          padding: const EdgeInsets.only(right: 16.0),
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                'Item: ',
                                                style: TextStyle(fontSize: 16.0),
                                              ),
                                              Text(
                                                itemList[index],
                                                style: TextStyle(fontSize: 16.0),
                                              )
                                            ],
                                          ))
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Container(
                                          // padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                'Number: ',
                                                style: TextStyle(fontSize: 16.0),
                                              ),
                                              Text(
                                                itemList[index],
                                                style: TextStyle(fontSize: 16.0),
                                              )
                                            ],
                                          ))
                                    ],
                                  )
                                ],
                              )),
                        );
                      },
                    ))),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                      margin: const EdgeInsets.only(left: 8.0, bottom: 8.0, right: 8.0),
                      child: ButtonTheme(
                          minWidth: MediaQuery.of(context).size.width,
                          height: 150,
                          child: RaisedButton(
                            textColor: Colors.white,
                            onPressed: scan,
                            child: const Text('SCAN QR CODE'),
                          )))
                ])
          ]),
    );
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.itemList.add(barcode));
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
      } else {}
    } on FormatException {} catch (e) {}
  }
}
