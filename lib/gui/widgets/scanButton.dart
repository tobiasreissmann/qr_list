import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:qr_list/gui/qrList.dart';
import 'package:qr_list/models/item.dart';
import 'package:vibrate/vibrate.dart';
import 'package:flutter/services.dart';

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
              buttonColor: Colors.green,
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
    try {
      // get scan
      final String scan = await BarcodeScanner.scan();

      // check if scan is of invalid format
      final RegExp expScan = new RegExp(r"^VG\s([0-9]{3,4})");
      if (!expScan.hasMatch(scan)) return _sendFeedbackMessage(context, FeedbackType.error, 'This barcode / qr-code is not supported');

      // get item from scan
      final item = _readItemFromScan(scan);

      // check item validitys
      final _bloc = BlocProvider.of(context).bloc;
      switch (_bloc.validateItem(item)) {
        case 0:
          return _sendFeedbackMessage(context, FeedbackType.error, 'There was a recognizing the item.');
        case 1:
          return _sendFeedbackMessage(context, FeedbackType.error, 'This item was already scanned.');
        case 2:
          return _sendFeedbackMessage(context, FeedbackType.error, 'This number is already taken.');
        case 3:
          // no problems -> add item to itemList
          _addItemToItemList(context, item);
          // scroll to list.bottom // TODO only when alphabetical
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
          return _sendFeedbackMessage(context, FeedbackType.light, 'Item added successfully.');
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied)
        return _sendFeedbackMessage(context, FeedbackType.error, 'No camera access permission provided.');
    }
    return _sendFeedbackMessage(context, FeedbackType.error, 'There was a problem scanning the code.');
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _sendFeedbackMessage(
      BuildContext context, FeedbackType feedbacktype, String feedbackMessage) {
    Vibrate.feedback(feedbacktype);
    Scaffold.of(context).removeCurrentSnackBar();
    return Scaffold.of(context).showSnackBar(SnackBar(content: Text(feedbackMessage)));
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
    BlocProvider.of(context).bloc.addItemSink.add(item);
  }
}
