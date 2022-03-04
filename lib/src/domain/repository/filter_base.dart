import 'package:mobx/mobx.dart';
import 'package:select_any/select_any.dart';

part 'filter_base.g.dart';

abstract class FilterBase = _FilterBaseBase with _$FilterBase;

abstract class _FilterBaseBase with Store {
  @observable
  ItemDataFilter? selectedValue;

  _FilterBaseBase({this.selectedValue});
}
