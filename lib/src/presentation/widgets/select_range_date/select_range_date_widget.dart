import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk_utils/extensions/date.dart';

import 'select_range_date_controller.dart';

typedef RangeDateChanged(DateTime? dataInicial, DateTime? dataFinal);

typedef List<DateTime> DatasNaoSelecionaveis();

// ignore: must_be_immutable
class SelectRangeDateWidget extends StatelessWidget {
  final SelectRangeDateController controller;

  //final String formatDate;
  DateTime? dateMin;
  DateTime? dateMax;
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final DatasNaoSelecionaveis? unselectableDays;

  final RangeDateChanged onChanged;
  SelectRangeDateWidget(this.controller, this.onChanged,
      {this.dateMin,
      this.dateMax,
      this.dateStart,
      this.dateEnd,
      this.unselectableDays}) {
    if (dateMin == null) {
      dateMin = DateTime.now().subtract(Duration(days: 90));
    }
    if (dateMax == null) {
      dateMax = DateTime.now().add(Duration(days: 90));
    }

    if (dateStart != null && controller.initialDate == null) {
      controller.initialDate = dateStart;
    }
    if (dateEnd != null && controller.finalDate == null) {
      controller.finalDate = dateEnd;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => InkWell(
        onTap: () async {
          _showCalendar(context);
        },
        child: Center(
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            alignment: Alignment.center,
            child: Text(
              controller.data,
              maxLines: 2,
            ),
          ),
        ),
      ),
    );
  }

  void _showCalendar(BuildContext buildContext) {
    // recupera as datas aqui para nao precisar recuperar pra cada um dos dias ali em baixo
    List<DateTime> localUnselectableDays = [];
    if (unselectableDays != null) {
      localUnselectableDays = unselectableDays!();
    }
    if (controller.initialDate != null && controller.finalDate != null) {
      // Verifica se o intervalo selecionado não está em algum dia que não é permitido
      int qtdDaysInterval =
          controller.finalDate!.difference(controller.initialDate!).inDays;
      for (int i = 0; i <= qtdDaysInterval; i++) {
        if (localUnselectableDays.any((day) {
          return day.string('dd-MM-yyyy') ==
              controller.initialDate!
                  .add(Duration(days: i))
                  .string('dd-MM-yyyy');
        })) {
          _clearSelection();
          break;
        }
      }
    } else {
      _clearSelection();
    }
    showDialog(
        context: buildContext,
        builder: (context) => AlertDialog(
              content: Observer(
                builder: (_) => RangePicker(
                  lastDate: dateMax!,
                  firstDate: dateMin!.subtract(Duration(days: 2)),
                  selectedPeriod: controller.period!,
                  onChanged: (DatePeriod datePediod) {
                    controller.period = datePediod;
                    controller.initialDate = DateTime(datePediod.start.year,
                        datePediod.start.month, datePediod.start.day, 0, 0, 0);
                    controller.finalDate = DateTime(datePediod.end.year,
                        datePediod.end.month, datePediod.end.day, 23, 59, 59);
                    onChanged(controller.initialDate, controller.finalDate);
                  },
                  selectableDayPredicate: (day) {
                    // solução alternativa usada para poder limpar o range de selecao
                    if (day.isBefore(dateMin!)) {
                      return false;
                    }
                    return !localUnselectableDays.any((element) =>
                        element.string('dd-MM-yyyy') ==
                        day.string('dd-MM-yyyy'));
                  },
                  onSelectionError: (day) {
                    ScaffoldMessenger.maybeOf(context)!.showSnackBar(SnackBar(
                        content: Text('Esse período não está disponível')));
                  },
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Limpar'),
                  onPressed: () {
                    _clearSelection();
                  },
                ),
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ));
  }

  void _clearSelection() {
    // seta o periodo como os dias antes da data minima, o que causa um problema na seleção
    // e faz o range de selecao ficar vazio
    controller.period = DatePeriod(dateMin!.subtract(Duration(days: 2)),
        dateMin!.subtract(Duration(days: 1)));
    controller.initialDate = null;
    controller.finalDate = null;
    onChanged(controller.initialDate, controller.finalDate);
  }
}
