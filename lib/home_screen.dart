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
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w300, fontSize: 24),
          ),
          actions:
              _ev > 6 ? <Widget>[IconButton(icon: Icon(Icons.favorite), color: Colors.red, onPressed: () {})] : null,
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
                                              setState(() {
                                                itemList.removeAt(index);
                                              });
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
                                                      Flexible(
                                                          flex: 1,
                                                          child: Container(
                                                              alignment: Alignment.centerRight,
                                                              child: IconButton(
                                                                  icon: Icon(Icons.cancel),
                                                                  color: Colors.grey[300],
                                                                  onPressed: () {
                                                                    setState(() {
                                                                      this.itemList.removeAt(index);
                                                                    });
                                                                  })))
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
                                                        ))),
                                                Flexible(
                                                    flex: 1,
                                                    child: Container(
                                                        alignment: Alignment.centerRight,
                                                        // width: MediaQuery.of(context).size.width * 0.1,
                                                        child: IconButton(
                                                          icon: Icon(Icons.check),
                                                          color: Colors.green[300],
                                                          onPressed: save,
                                                        )))
                                              ]),
                                            ),
                                            Container(height: 116)
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
                                          child: const Text('SCAN',
                                              style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w300)),
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
            Vibrate.feedback(FeedbackType.success);
            setState(() => this.itemList.add(Item(name, number)));
          }
        } else {
          if (expNameBund.hasMatch(scan)) {
            final name = scan.split(" Bund ")[1];
            final number = expNumber.stringMatch(scan);
            if (itemList.where((item) => item.name == name && item.number == number).toList().length > 0) {
              Vibrate.feedback(FeedbackType.error);
              return Scaffold.of(context).showSnackBar(SnackBar(content: Text('This item was already scanned.')));
            } else {
              Vibrate.feedback(FeedbackType.success);
              setState(() => this.itemList.add(Item(name, number)));
            }
          } else {
            if (expNameStueck.hasMatch(scan)) {
              final name = scan.split(" Stück ")[1];
              final number = expNumber.stringMatch(scan);
              if (itemList.where((item) => item.name == name && item.number == number).toList().length > 0) {
                Vibrate.feedback(FeedbackType.error);
                return Scaffold.of(context).showSnackBar(SnackBar(content: Text('This item was already scanned.')));
              } else {
                Vibrate.feedback(FeedbackType.success);
                setState(() => this.itemList.add(Item(name, number)));
              }
            } else {
              return Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text('There was a problem recognizing the item.')));
            }
          }
        }
      } else {
        return Scaffold.of(context).showSnackBar(SnackBar(content: Text('This barcode / qr-code is not supported.')));
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        return Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('To scan items the permisson for camera access is required.')));
      } else {}
    } on FormatException {} catch (e) {}
    return null;
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
