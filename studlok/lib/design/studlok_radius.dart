import 'package:flutter/material.dart';

/// Corner-radius scale — buttons and cards keep the values already shipped
/// (they already formed a correct two-tier system); `sheet` is the one new
/// tier, for modals/bottom sheets.
class StudlokRadius {
  StudlokRadius._();

  static const button = 12.0;
  static const card = 16.0;
  static const sheet = 20.0;

  static const buttonRadius = BorderRadius.all(Radius.circular(button));
  static const cardRadius = BorderRadius.all(Radius.circular(card));
  static const sheetRadius = BorderRadius.vertical(top: Radius.circular(sheet));
}
