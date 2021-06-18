import 'package:flutter/material.dart';
import 'package:select_any/select_any.dart';

class FilterWidget extends StatelessWidget {
  final FilterBase filter;

  FilterWidget(this.filter);

  @override
  Widget build(BuildContext context) {
    switch (filter.runtimeType) {
      case FilterRangeDate:
        return IconButton(
            splashRadius: 24,
            onPressed: () {},
            icon: Icon(Icons.calendar_today_outlined));
      case FilterSelectItem:
        return SizedBox();
      default:
        return SizedBox();
    }
  }
}
