import 'package:flutter/material.dart';

class ScanButton extends StatelessWidget {
  const ScanButton({@required this.onSubmitted});

  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Container(
        child: ButtonTheme(
          minWidth: MediaQuery.of(context).size.width / 2,
          height: 70,
          buttonColor: Colors.green,
          child: RaisedButton(
            elevation: 8,
            textColor: Colors.white,
            onPressed: onSubmitted,
            child: const Text('SCAN', style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w300)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
          ),
        ),
      ),
    );
  }

  // Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>> scanItem(BuildContext context) async {
  //   try {
  //     // get scan
  //     final String scan = await BarcodeScanner.scan();

  //     // define regex for validation checks
  //     final RegExp expScan = new RegExp(r"^VG\s([0-9]{3,4})");
  //     final RegExp expNumber = new RegExp(r"([0-9])\w+");
  //     final RegExp expNameKg = new RegExp(r"^.*\skg\s");
  //     final RegExp expNameBund = new RegExp(r"^.*\sBund\s");
  //     final RegExp expNameStueck = new RegExp(r"^.*\sStück\s");

  //     String name = '';
  //     String number = expNumber.stringMatch(scan);

  //     // check if scan is of valid format
  //     if (!expScan.hasMatch(scan)) return errorMessage(context, 'This barcode / qr-code is not supported');

  //     // find item type
  //     if (expNameKg.hasMatch(scan)) name = scan.split(" kg ")[1];
  //     if (expNameBund.hasMatch(scan)) name = scan.split(" Bund ")[1];
  //     if (expNameStueck.hasMatch(scan)) name = scan.split(" Stück ")[1];

  //     // check whether there was a valid name found
  //     if (name == '') return errorMessage(context, 'There was a problem recognizing the item.');
  //     if (itemList.where((item) => item.name == name && item.number == number).toList().length > 0)
  //       return errorMessage(context, 'This item was already scanned.');
  //     if (itemList.where((item) => item.number == number).toList().length > 0) return errorMessage(context, 'This number is already taken.');

  //     // no problems -> add Item
  //     await addDatabaseItem(name, number);
  //     setState(() {
  //       itemList.add(Item(name, number));
  //     });
  //     if(!alphabetical) _scrollController.jumpTo(_scrollController.position.maxScrollExtent+150);
  //     return successMessage(context);
  //   } on PlatformException catch (e) {
  //     if (e.code == BarcodeScanner.CameraAccessDenied) return errorMessage(context, 'To scan items the permisson for camera access is required.');
  //   }
  //   return errorMessage(context, 'There was an undefined problem.');
  // }

}
