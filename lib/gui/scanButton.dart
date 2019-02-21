import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibrate/vibrate.dart';

import 'package:qr_list/gui/qrList.dart';
import 'package:qr_list/models/item.dart';

class ScanButton extends StatelessWidget {
  ScanButton({@required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Container(
            child: ButtonTheme(
              minWidth: MediaQuery.of(context).size.width / 2,
              height: 70,
              buttonColor: Theme.of(context).buttonColor,
              splashColor: Theme.of(context).splashColor,
              child: RaisedButton(
                elevation: 8,
                textColor: Colors.white,
                onPressed: () {
                  return _readCode(context);
                },
                child: const Text('SCAN', style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w300)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>> _readCode(BuildContext context) async {
    Vibrate.feedback(FeedbackType.impact);
    try {
      // get scan
      final String scan = await BarcodeScanner.scan();

      // check if scan is of invalid format
      final RegExp expScan = new RegExp(r"^VG\s([0-9]{3,4})");
      if (!expScan.hasMatch(scan)) return _sendFeedbackMessage(context, FeedbackType.error, 'This barcode / qr-code is not supported', 3);

      // get item from scan
      final item = _readItemFromScan(scan);

      // check item validitys
      final _bloc = ItemListProvider.of(context).itemListBloc;
      switch (_bloc.validateItem(item)) {
        case 0:
          return _sendFeedbackMessage(context, FeedbackType.warning, 'There was a recognizing the item.', 3);
        case 1:
          return _sendFeedbackMessage(context, FeedbackType.warning, 'This item was already scanned.', 3);
        case 2:
          return _sendFeedbackMessage(context, FeedbackType.warning, 'This number is already taken.', 3);
        case 3:
          // no problems -> add item to itemList
          _addItemToItemList(context, item);
          // scroll to bottom of list
          _bloc.alphabeticalStream.listen((alphabetical) {
            if (!alphabetical) scrollController.jumpTo(scrollController.position.maxScrollExtent);
          });
          return _sendFeedbackMessage(context, FeedbackType.light, 'Item added "${item.name}" successfully.', 1);
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied)
        return _sendFeedbackMessage(context, FeedbackType.warning, 'No camera access permission provided.', 3);
    }
    return _sendFeedbackMessage(context, FeedbackType.error, 'There was a problem scanning the code.', 3);
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _sendFeedbackMessage(
      BuildContext context, FeedbackType feedbacktype, String feedbackMessage, int duration) {
    Vibrate.feedback(feedbacktype);
    Scaffold.of(context).removeCurrentSnackBar();
    return Scaffold.of(context).showSnackBar(SnackBar(content: Text(feedbackMessage), 
      duration: Duration(seconds: duration),));
  }

  Item _readItemFromScan(String scan) {
    // define regex for validation checks
    final RegExp expNumber = new RegExp(r"([0-9])\w+");
    final RegExp expNameKg = new RegExp(r"^.*\skg\s");
    final RegExp expNameBund = new RegExp(r"^.*\sBund\s");
    final RegExp expNameStueck = new RegExp(r"^.*\sStück\s");

    String name;
    String number = expNumber.stringMatch(scan);

    // find item name (differences between diffrent item types)
    if (expNameKg.hasMatch(scan)) name = scan.split(" kg ")[1];
    if (expNameBund.hasMatch(scan)) name = scan.split(" Bund ")[1];
    if (expNameStueck.hasMatch(scan)) name = scan.split(" Stück ")[1];

    return Item(name, number);
  }

  void _addItemToItemList(BuildContext context, Item item) {
    ItemListProvider.of(context).itemListBloc.addItemSink.add(item);
  }
}
