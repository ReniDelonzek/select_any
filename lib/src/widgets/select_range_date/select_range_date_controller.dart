import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/extensions/date.dart';

part 'select_range_date_controller.g.dart';

class SelectRangeDateController = _SelectRangeDateController
    with _$SelectRangeDateController;

abstract class _SelectRangeDateController with Store {
  @observable
  DateTime initialDate;
  @observable
  DateTime finalDate;
  @observable
  DatePeriod period;
  @computed
  String get data {
    if (initialDate != null && finalDate != null) {
      return '${initialDate.string('dd/MM/yyyy')} - ${finalDate.string('dd/MM/yyyy')}';
    } else
      return 'Toque aqui para selecionar';
  }

  _SelectRangeDateController() {
    if (initialDate != null && finalDate != null) {
      period = DatePeriod(initialDate, finalDate);
    }
  }

  clear() {
    initialDate = null;
    finalDate = null;
  }
}
