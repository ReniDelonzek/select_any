import 'package:flutter/material.dart';

class UtilsColor {
  static Color getAccentColor(BuildContext context) {
    // ignore: deprecated_member_use
    return (Theme.of(context).accentColor ??
        Theme.of(context).colorScheme?.secondary ??
        Colors.teal);
  }
}
