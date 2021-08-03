import 'package:flutter/material.dart';

class UtilsColor {
  static Color getAccentColor(BuildContext context) {
    return (Theme.of(context).colorScheme?.secondary ??
        // ignore: deprecated_member_use
        Theme.of(context).accentColor ??
        Colors.teal);
  }
}
