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
}
