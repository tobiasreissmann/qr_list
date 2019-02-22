import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_list/i18n/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get title {
    return Intl.message(
      'QR-Shoppinglist',
      name: 'title',
      desc: 'The title of the application',
    );
  }

  String get deleteItemList {
    return Intl.message(
      'All items deleted.',
      name: 'deleteItemList',
      desc: 'Feedback after deleting item list.',
    );
  }

  String get emptyFields {
    return Intl.message(
      'There are fields left that need to be filled.',
      name: 'emptyFields',
      desc: 'Feedback when trying to push item with empty values.',
    );
  }

  String get itemExists {
    return Intl.message(
      'The list already contains this item.',
      name: 'itemExists',
      desc: 'Feedback when item is already in list.',
    );
  }

  String get item {
    return Intl.message(
      'Item',
      name: 'item',
      desc: 'designation of item',
    );
  }

  String get noCameraPermission {
    return Intl.message(
      'No camera access permissions provided.',
      name: 'noCameraPermission',
      desc: 'Feedback when trying to scan code without camera permissions.',
    );
  }

  String get numberExists {
    return Intl.message(
      'This number is already given.',
      name: 'numberExists',
      desc: 'Feedback when trying to commit item without unique number',
    );
  }

  String get number {
    return Intl.message(
      'Item Number',
      name: 'number',
      desc: 'designation of item number',
    );
  }

  String get scanButton {
    return Intl.message(
      'SCAN',
      name: 'scanButton',
      desc: 'label of scan button',
    );
  }

  String get undefinedIssue {
    return Intl.message(
      'There was an issue.',
      name: 'undefinedIssue',
      desc: 'Feedback when an issue occured, that could not be idendified.',
    );
  }

  String get undefinedScanIssue {
    return Intl.message(
      'There was a recognizing the item.',
      name: 'undefinedScanIssue',
      desc: 'Feedback when scan crashed without knowing the cause',
    );
  }

  String get undo {
    return Intl.message(
      'UNDO',
      name: 'undo',
      desc: 'label of undo button',
    );
  }

  String get unsupportedScan {
    return Intl.message(
      'This barcode / qr-code is not supported',
      name: 'unsupportedScan',
      desc: 'Feedback when scan form is not supported.',
    );
  }
  
  String get itemDeleted {
    return Intl.message(
      'removed',
      name: 'itemDeleted',
      desc: 'Feedback when item was deleted.',
    );
  }

  String get itemAdded {
    return Intl.message(
      'added',
      name: 'itemAdded',
      desc: 'Feedback when item was added.',
    );
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) {
    return false;
  }
}
