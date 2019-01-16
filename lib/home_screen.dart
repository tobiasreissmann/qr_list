import 'package:flutter/material.dart';
import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => new _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  String item = ''; // stores last value from qrcode
  List<Object> itemList = [1, 2, 3, 4, 5];

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
                    height: MediaQuery.of(context).size.height - 300,
                    child: ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemExtent: 20.0,
                      itemBuilder: (BuildContext context, int index) {
                        return Text('entry $index');
                      },
                    ))),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                      margin: const EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10.0),
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
      setState(() => this.item = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() =>
            this.item = 'The camera can only be used, if this application gets granted the permissons for the camera');
      } else {
        setState(() => this.item = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.item = '');
    } catch (e) {
      setState(() => this.item = 'Unknown error: $e');
    }
  }
}
