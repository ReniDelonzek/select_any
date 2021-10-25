import 'package:flutter/material.dart';
import 'package:select_any/src/utils/utils_color.dart';

class ButtonChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final GestureTapCallback onTap;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;

  ButtonChip(this.title,
      {this.isSelected = false,
      this.onTap,
      this.textColor,
      this.textStyle,
      this.padding =
          const EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16)});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: new BoxDecoration(
            color: isSelected == true
                ? UtilsColor.getAccentColor(context)
                : Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
            border: new Border.all(
                color: Theme.of(context).brightness == Brightness.light
                    ? UtilsColor.getAccentColor(context)
                    : Colors.transparent)),
        child: InkWell(
          splashColor: Colors.white24,
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          onTap: onTap,
          child: Container(
            padding: padding,
            child: Text(
              title,
              textAlign: TextAlign.left,
              maxLines: 1,
              style: textStyle ??
                  TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.27,
                      color: (isSelected
                          ? Colors.white
                          : UtilsColor.getAccentColor(context))),
            ),
          ),
        ));
  }
}
