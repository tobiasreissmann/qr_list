import 'package:flutter/material.dart';
import 'package:qr_list/globals.dart';

class ManualItemAdd extends StatelessWidget {
  const ManualItemAdd({this.onSubmit});

  final bool onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(children: <Widget>[
            Flexible(
              flex: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
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
                ),
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
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
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.playlist_add),
                  color: Colors.green,
                  onPressed: () {
                    return null;
                  },
                ),
              ),
            ),
          ]),
        ),
        Container(height: 150)
      ],
    );
  }
}
