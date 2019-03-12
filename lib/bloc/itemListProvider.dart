import 'package:flutter/material.dart';

import 'package:qr_list/bloc/itemListBloc.dart';

class ItemListProvider extends InheritedWidget {
  ItemListProvider({
    Key key,
    @required this.child,
  }) : super(key: key, child: child);

  final Widget child;

  final bloc = ItemListBloc();

  static ItemListProvider of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ItemListProvider) as ItemListProvider;
  }

  @override
  bool updateShouldNotify(ItemListProvider oldWidget) {
    return true;
  }
}