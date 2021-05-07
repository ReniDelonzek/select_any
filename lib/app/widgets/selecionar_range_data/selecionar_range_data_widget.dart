import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk_utils/extensions/date.dart';

import 'selecionar_range_data_controller.dart';

typedef RangeDateChanged(DateTime dataInicial, DateTime dataFinal);

typedef List<DateTime> DatasNaoSelecionaveis();

class SelecionarRangeDataWidget extends StatelessWidget {
  final SelecionarRangeDataController controller;

  final String formatDate;
  DateTime dataMin;
  DateTime dataMax;
  final DateTime dataInicial;
  final DateTime dataFinal;
  final DatasNaoSelecionaveis datasNaoSelecionaveis;

  final RangeDateChanged onChanged;
  SelecionarRangeDataWidget(this.controller, this.onChanged,
      {this.formatDate = 'dd/MM/yyyy',
      this.dataMin,
      this.dataMax,
      this.dataInicial,
      this.dataFinal,
      this.datasNaoSelecionaveis}) {
    if (dataMin == null) {
      dataMin = DateTime.now().subtract(Duration(days: 90));
    }
    if (dataMax == null) {
      dataMax = DateTime.now().add(Duration(days: 90));
    }

    if (dataInicial != null && controller.dataInicial == null) {
      controller.dataInicial = dataInicial;
    }
    if (dataFinal != null && controller.dataFinal == null) {
      controller.dataFinal = dataFinal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => InkWell(
        onTap: () async {
          _exibirCalendario(context);
          //_showDatePicked(context);
        },
        child: Center(
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            alignment: Alignment.center,
            child: Text(
              this.controller.data != null
                  ? this.controller.data
                  : 'Selecione as datas',
              maxLines: 2,
            ),
          ),
        ),
      ),
    );
  }

  _exibirCalendario(BuildContext buildContext) {
    // recupera as datas aqui para nao precisar recuperar pra cada um dos dias ali em baixo
    List<DateTime> datasNSelecionais = [];
    if (datasNaoSelecionaveis != null) {
      datasNSelecionais = datasNaoSelecionaveis();
    }
    if (controller.dataInicial != null && controller.dataFinal != null) {
      // Verifica se o intervalo selecionado não está em algum dia que não é permitido
      int qtdDiasIntervalo =
          controller.dataFinal.difference(controller.dataInicial).inDays;
      for (int i = 0; i <= qtdDiasIntervalo; i++) {
        if (datasNSelecionais.any((day) {
          return day.string('dd-MM-yyyy') ==
              controller.dataInicial
                  .add(Duration(days: i))
                  .string('dd-MM-yyyy');
        })) {
          _limparSelecao();
          /*
          Caso tenha que remover a solução alternativa da data minima ser dois dias menor que o especificado e desabilitada em seguida
          if (datasNSelecionais.length >= 1) {
            // caso o tamanho da lista seja maior que 1, marca o range em uma data não disponível
            // para que ele não fique com nenhuma seleção
            controller.periodo =
                DatePeriod(datasNSelecionais.first, datasNSelecionais[1]);
          } else {
            // caso tenha, pega o primeiro dia disponível
            int diasDepoisDaDataMinina = 0;
            while (true) {
              // adiciona a quantidade de iteracoes a data inicial
              DateTime dataVerificada = dataMin
                ..add(Duration(days: diasDepoisDaDataMinina));
              // caso seja antes da data maxima
              if (dataVerificada.isBefore(dataMax)) {
                // caso o dia nao esteja na lista de datas nao selecionaveis
                if (!datasNSelecionais.any((day) =>
                    day.string('dd-MM-yyyy') ==
                    dataVerificada.string('dd-MM-yyyy'))) {
                  controller.periodo = DatePeriod(
                      dataVerificada, dataVerificada.add(Duration(days: 1)));
                  break;
                }
              } else {
                break;
              }
              diasDepoisDaDataMinina++;
            }
          }
          */
          break;
        }
      }
    } else {
      _limparSelecao();
    }
    showDialog(
        context: buildContext,
        builder: (context) => AlertDialog(
              content: Observer(
                builder: (_) => RangePicker(
                  lastDate: dataMax,
                  firstDate: dataMin.subtract(Duration(days: 2)),
                  selectedPeriod: controller.periodo,
                  onChanged: (DatePeriod periodoSelecionado) {
                    controller.periodo = periodoSelecionado;
                    this.controller.dataInicial = DateTime(
                        periodoSelecionado.start.year,
                        periodoSelecionado.start.month,
                        periodoSelecionado.start.day,
                        0,
                        0,
                        0);
                    this.controller.dataFinal = DateTime(
                        periodoSelecionado.end.year,
                        periodoSelecionado.end.month,
                        periodoSelecionado.end.day,
                        23,
                        59,
                        59);
                    onChanged(
                        this.controller.dataInicial, this.controller.dataFinal);
                  },
                  selectableDayPredicate: (day) {
                    // solução alternativa usada para poder limpar o range de selecao
                    if (day.isBefore(dataMin)) {
                      return false;
                    }
                    if (datasNSelecionais != null) {
                      return !datasNSelecionais.any((element) =>
                          element.string('dd-MM-yyyy') ==
                          day.string('dd-MM-yyyy'));
                    }
                    return true;
                  },
                  onSelectionError: (day) {
                    ScaffoldMessenger.maybeOf(context).showSnackBar(SnackBar(
                        content: Text('Esse período não está disponível')));
                  },
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Limpar'),
                  onPressed: () {
                    _limparSelecao();
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

  _limparSelecao() {
    // seta o periodo como os dias antes da data minima, o que causa um problema na seleção
    // e faz o range de selecao ficar vazio
    controller.periodo = DatePeriod(dataMin.subtract(Duration(days: 2)),
        dataMin.subtract(Duration(days: 1)));
    controller.dataInicial = null;
    controller.dataFinal = null;
    onChanged(this.controller.dataInicial, this.controller.dataFinal);
  }

/*
  Future _showDatePicked(BuildContext context) async {
    final List<DateTime> dates = await DateRagePicker.showDatePicker(
        context: context,
        locale: Locale('pt', 'BR'),
        initialFirstDate: (controller.dataInicial ?? DateTime.now()),
        initialLastDate: ((controller.dataFinal ??
            (controller.dataInicial ?? new DateTime.now())
                .add(new Duration(days: 7)))),
        firstDate: (dataMin ?? new DateTime(2019)),
        lastDate: dataMax ?? DateTime.now().add(Duration(days: 365)));
    if (dates != null && dates.isNotEmpty) {
      if (dates.length == 1) {
        dates.add(DateTime(
            dates.first.year, dates.first.month, dates.first.day, 23, 59, 59));
      }
      this.controller.dataInicial = DateTime(
          dates.first.year, dates.first.month, dates.first.day, 0, 0, 0);
      this.controller.dataFinal = DateTime(
          dates.last.year, dates.last.month, dates.last.day, 23, 59, 59);

      onChanged(this.controller.dataInicial, this.controller.dataFinal);
    }
  }*/
}
