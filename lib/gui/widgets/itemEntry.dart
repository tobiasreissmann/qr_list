import 'package:flutter/material.dart';

import 'package:qr_list/models/item.dart';

class ItemEntry extends StatefulWidget {
  ItemEntry({@required this.item});
  final Item item;

  @override
  ItemEntryState createState() {
    return new ItemEntryState();
  }
}

class ItemEntryState extends State<ItemEntry> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        children: <Widget>[
          Row(children: <Widget>[
            Flexible(
              flex: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  widget.item.name,
                  style: TextStyle(fontSize: 20.0),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(widget.item.number, style: TextStyle(fontSize: 28.0), overflow: TextOverflow.ellipsis, textAlign: TextAlign.left),
              ),
            ),
          ]),
          Divider()
        ],
      ),
    );
  }
}
