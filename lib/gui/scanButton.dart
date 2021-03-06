import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibrate/vibrate.dart';

import 'package:qr_list/bloc/itemListProvider.dart';
import 'package:qr_list/locale/locales.dart';
import 'package:qr_list/models/item.dart';
import 'package:qr_list/models/itemValidity.dart';

class ScanButton extends StatelessWidget {
  ScanButton({
    @required this.scrollController,
    @required this.scaffoldKey,
    @required this.scanAnimationController,
    @required this.scanAnimation,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final ScrollController scrollController;
  final AnimationController scanAnimationController;
  final Animation scanAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scanAnimationController,
      builder: (BuildContext context, Widget child) {
        return Transform(
          transform: Matrix4.translationValues(0.0, scanAnimation.value * 200, 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Container(
                    child: ButtonTheme(
                      minWidth: 200,
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
          ),
        );
      },
    );
  }

  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>> _readCode(BuildContext context) async {
    Vibrate.feedback(FeedbackType.selection);
    try {
      // get scan
      bool scanInterrupted = false; 
      final String scan = await BarcodeScanner.scan().catchError((e) {
            scanInterrupted = true;
            print(e.toString());
          }) ??
          '';
      if (scanInterrupted) return null;

      // check if scan is of invalid format
      final RegExp expScan = RegExp(r"^VG\s([0-9]{3,4})");
      if (!expScan.hasMatch(scan))
        return _sendFeedbackMessage(context, FeedbackType.error, AppLocalizations.of(context).unsupportedScan, 3);

      // get item from scan
      final item = _readItemFromScan(scan);

      // check item validitys
      final _itemListBloc = ItemListProvider.of(context).bloc;
      switch (_itemListBloc.validateItem(item)) {
        case ItemValidity.emptyFields:
          return _sendFeedbackMessage(
              context, FeedbackType.warning, AppLocalizations.of(context).undefinedScanIssue, 3);
        case ItemValidity.itemExists:
          return _sendFeedbackMessage(context, FeedbackType.warning, AppLocalizations.of(context).itemExists, 3);
        case ItemValidity.numberExists:
          return _sendFeedbackMessage(context, FeedbackType.warning, AppLocalizations.of(context).numberExists, 3);
        case ItemValidity.valid:
          // no problems -> add item to itemList
          _addItemToItemList(context, item);
          // scroll to bottom of list
          if (!_itemListBloc.alphabetical) scrollController.jumpTo(scrollController.position.maxScrollExtent);
          return _sendFeedbackMessage(
            context,
            FeedbackType.light,
            '"${item.name}" ${AppLocalizations.of(context).itemAdded}',
            2,
          );
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
    scaffoldKey.currentState.removeCurrentSnackBar();
    return scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          feedbackMessage,
          style: TextStyle(
            color: Theme.of(context).indicatorColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        duration: Duration(seconds: duration),
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }

  Item _readItemFromScan(String scan) {
    for (String itemTypeIndicator in [' kg ', ' Bund ', ' Stück ', ' Schale ']) {
      List<String> splitted = scan.split(itemTypeIndicator);
      if (splitted.length > 1)
        return Item(
          splitted[1],
          RegExp(r"([0-9])\w+").stringMatch(scan),
        );
    }

    return Item('', '');
  }

  void _addItemToItemList(BuildContext context, Item item) {
    ItemListProvider.of(context).bloc.addItem.add(item);
  }
}
