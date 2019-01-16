import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => new _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  String item = ''; // stores last value from qrcode

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('QR-Shoppinglist'),
      ),
      body: Column(children: [
        Row(children: [
          Expanded(
            child: Text('Last scanned item: '),
          ),
          Expanded(
            child: Text(item),
          )
        ]),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: RaisedButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  splashColor: Colors.grey,
                  onPressed: scan,
                  child: const Text('SCAN QR CODE')),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: RaisedButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  splashColor: Colors.grey,
                  onPressed: () {},
                  child: const Text('SHOW SHOPPINGLIST')),
            ),
          ],
        ),
      ]),
    );
  }

  // Widget lastItem = Row(children: [
  //   Expanded(
  //     child: Text('Last scanned item: '),
  //   ),
  //   Expanded(
  //     child: Text(item),
  //   )
  // ]);

  // Widget menuButtons = Column(
  //   mainAxisAlignment: MainAxisAlignment.center,
  //   crossAxisAlignment: CrossAxisAlignment.stretch,
  //   children: <Widget>[
  //     Padding(
  //       padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  //       child: RaisedButton(
  //           color: Colors.green,
  //           textColor: Colors.white,
  //           splashColor: Colors.grey,
  //           onPressed: scan,
  //           child: const Text('SCAN QR CODE')),
  //     ),
  //     Padding(
  //       padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  //       child: RaisedButton(
  //           color: Colors.green,
  //           textColor: Colors.white,
  //           splashColor: Colors.grey,
  //           onPressed: () {},
  //           child: const Text('SHOW SHOPPINGLIST')),
  //     ),
  //   ],
  // );

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.item = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() => this.item =
            'The camera can only be used, if this application gets granted the permissons for the camera');
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
