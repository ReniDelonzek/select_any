import 'package:flutter/material.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:select_any/app/models/models.dart';
import 'package:msk_utils/extensions/string.dart';
import 'package:select_any/app/modules/select_any/select_any_page.dart';

class UtilsWidget {
  static DataRow generateDataRow(
      SelectModel selectModel,
      int index,
      ItemSelect itemSelect,
      BuildContext context,
      Function(ItemSelect, bool) onSelected) {
    List<DataCell> cells = [];
    for (MapEntry mapEntry in itemSelect.strings.entries) {
      cells.add(DataCell(getLinha(selectModel, mapEntry,
          itemSelect.object is Map ? itemSelect.object : itemSelect.strings)));
    }
    if (selectModel.acoes?.isNotEmpty == true) {
      List<Widget> widgets = [];
      for (Acao acao in selectModel.acoes) {
        widgets.add(IconButton(
          tooltip: acao.descricao,
          icon: acao.icon ?? Text(acao.descricao ?? 'Ação'),
          onPressed: () {
            if (acao.funcao != null) {
              acao.funcao(data: itemSelect, index: index);
            }
          },
        ));
      }
      cells.add(DataCell(Row(children: widgets)));
    }
    DataRow dataRow = DataRow(
        cells: cells,
        onSelectChanged: selectModel.tipoSelecao ==
                    SelectAnyPage.TIPO_SELECAO_SIMPLES ||
                selectModel.tipoSelecao == SelectAnyPage.TIPO_SELECAO_MULTIPLA
            ? (b) {
                onSelected(itemSelect, b);
              }
            : null,
        selected: itemSelect.isSelected ?? false);
    return dataRow;
  }

  static List<DataColumn> generateDataColumn(SelectModel selectModel) {
    return selectModel.linhas
        .map((e) =>
            DataColumn(label: Text(e.nome ?? e.chave.upperCaseFirstLower())))
        .toList()
          ..addAll(selectModel.acoes?.isNotEmpty == true
              ? [DataColumn(label: Text('Ações'))]
              : []);
  }

  static Widget getLinha(SelectModel selectModel, MapEntry item, Map map) {
    Linha linha = selectModel.linhas
        .firstWhere((linha) => linha.chave == item.key, orElse: () => null);
    if (linha != null &&
        (linha.involucro != null || linha.personalizacao != null)) {
      if (linha.personalizacao != null) {
        return linha.personalizacao(map);
      }

      /// Não insere o invólucro pois este já vai no header
      return (SelectableText(linha.involucro.replaceAll('???', '')));
    } else {
      if (item.value?.toString()?.isNullOrBlank != false) {
        return SelectableText(linha.valorPadrao ?? '');
      }
      return SelectableText(item.value?.toString());
    }
  }
}
