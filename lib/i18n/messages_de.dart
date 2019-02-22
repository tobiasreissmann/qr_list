// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

// ignore: unnecessary_new
final messages = new MessageLookup();

// ignore: unused_element
final _keepAnalysisHappy = Intl.defaultLocale;

// ignore: non_constant_identifier_names
typedef MessageIfAbsent(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'de';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "deleteItemList" : MessageLookupByLibrary.simpleMessage("Alle Artikel wurden gelöscht."),
    "emptyFields" : MessageLookupByLibrary.simpleMessage("Es wurden noch nicht alle Felder ausgefüllt."),
    "item" : MessageLookupByLibrary.simpleMessage("Artikel"),
    "itemExists" : MessageLookupByLibrary.simpleMessage("Die Liste beinhaltet diesen Artikel bereits."),
    "noCameraPermission" : MessageLookupByLibrary.simpleMessage("Kein Kamera-Berechtigungen erteilt."),
    "number" : MessageLookupByLibrary.simpleMessage("Artikelnummer"),
    "numberExists" : MessageLookupByLibrary.simpleMessage("Diese Nummer wurde schon vergeben."),
    "scanButton" : MessageLookupByLibrary.simpleMessage("SCANNEN"),
    "title" : MessageLookupByLibrary.simpleMessage("QR-Einkaufsliste"),
    "undefinedIssue" : MessageLookupByLibrary.simpleMessage("Ein Problem ist aufgetreten."),
    "undefinedScanIssue" : MessageLookupByLibrary.simpleMessage("Es gab einen Fehler beim Untersuchen des Artikels."),
    "undo" : MessageLookupByLibrary.simpleMessage("ZURÜCK"),
    "unsupportedScan" : MessageLookupByLibrary.simpleMessage("Dieser Bar-/ QR-Code wird nicht unterstützt."),
    "itemDeleted" : MessageLookupByLibrary.simpleMessage("entfernt"),
    "itemAdded" : MessageLookupByLibrary.simpleMessage("hinzugefügt")
  };
}
