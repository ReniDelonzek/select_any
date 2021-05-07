import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/extensions/date.dart';

part 'selecionar_range_data_controller.g.dart';

class SelecionarRangeDataController = _SelecionarRangeDataController
    with _$SelecionarRangeDataController;

abstract class _SelecionarRangeDataController with Store {
  @observable
  DateTime dataInicial;
  @observable
  DateTime dataFinal;
  @observable
  DatePeriod periodo;
  @computed
  String get data {
    if (dataInicial != null && dataFinal != null) {
      return '${dataInicial.string('dd/MM/yyyy')} - ${dataFinal.string('dd/MM/yyyy')}';
    } else
      return 'Toque aqui para selecionar';
  }

  _SelecionarRangeDataController() {
    if (dataInicial != null && dataFinal != null) {
      periodo = DatePeriod(dataInicial, dataFinal);
    }
  }

  clear() {
    dataInicial = null;
    dataFinal = null;
  }
}
