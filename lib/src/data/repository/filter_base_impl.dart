import 'package:select_any/select_any.dart';

class FilterRangeDate extends FilterBase {
  DateTime? dateMin;
  DateTime? dateMax;
  DateTime? dateDefault;
  ItemDataFilterRange? selectedValueRange;
  FilterRangeDate(
      {this.dateMin, this.dateMax, this.dateDefault, this.selectedValueRange});
}

class FilterSelectItem extends FilterBase {
  FontDataFilterBase fontDataFilter;

  /// custom key for filters by id
  String? keyFilterId;

  FilterSelectItem(this.fontDataFilter,
      {this.keyFilterId, ItemDataFilter? selectedValue})
      : super(selectedValue: selectedValue);
}

class FilterText extends FilterBase {
  FilterText();
}
