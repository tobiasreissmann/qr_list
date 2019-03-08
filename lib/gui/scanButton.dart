import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_list/bloc/itemListProvider.dart';
import 'package:qr_list/locale/locales.dart';
import 'package:vibrate/vibrate.dart';

import 'package:qr_list/models/item.dart';

class ScanButton extends StatelessWidget {
  ScanButton({@required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: Container(
              child: ButtonTheme(
                minWidth: 210,
                height: 70,
                buttonColor: Theme.of(context).buttonColor,
                splashColor: Theme.of(context).splashColor,
                child: RaisedButton(
                  elevation: 9,
                  textColor: Colors.white,
                  onPressed: () {
                    return _readCode(context);
                  },
                  child: Text(AppLocalizations.of(context).scanButton,
                      style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w300)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>> _readCode(BuildContext context) async {
    Vibrate.feedback(FeedbackType.selection);
    try {
      // get scan
      final String scan = await BarcodeScanner.scan();

      // check if scan is of invalid format
      final RegExp expScan = new RegExp(r"^VG\s([0-9]{3,4})");
      if (!expScan.hasMatch(scan))
        return _sendFeedbackMessage(context, FeedbackType.error, AppLocalizations.of(context).unsupportedScan, 3);

      // get item from scan
      final item = _readItemFromScan(scan);

      // check item validitys
      final _itemListBloc = ItemListProvider.of(context).itemListBloc;
      switch (_itemListBloc.validateItem(item)) {
        case 0:
          return _sendFeedbackMessage(
              context, FeedbackType.warning, AppLocalizations.of(context).undefinedScanIssue, 3);
        case 1:
          return _sendFeedbackMessage(context, FeedbackType.warning, AppLocalizations.of(context).itemExists, 3);
        case 2:
          return _sendFeedbackMessage(context, FeedbackType.warning, AppLocalizations.of(context).numberExists, 3);
        case 3:
          // no problems -> add item to itemList
          _addItemToItemList(context, item);
          // scroll to bottom of list
          _itemListBloc.alphabeticalStream.listen((alphabetical) {
            if (!alphabetical) scrollController.jumpTo(scrollController.position.maxScrollExtent);
          });
          return _sendFeedbackMessage(
              context, FeedbackType.light, '"${item.name}" ${AppLocalizations.of(context).itemAdded}', 2);
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied)
        return _sendFeedbackMessage(context, FeedbackType.warning, AppLocalizations.of(context).noCameraPermission, 3);
    }
    return _sendFeedbackMessage(context, FeedbackType.error, AppLocalizations.of(context).undefinedIssue, 3);
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _sendFeedbackMessage(
      BuildContext context, FeedbackType feedbacktype, String feedbackMessage, int duration) {
    Vibrate.feedback(feedbacktype);
    Scaffold.of(context).removeCurrentSnackBar();
    return Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(feedbackMessage),
      duration: Duration(seconds: duration),
    ));
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
