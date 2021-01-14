import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:select_any/app/models/models.dart';
import 'package:msk_utils/extensions/string.dart';
import 'package:select_any/app/modules/select_any/select_any_page.dart';

part 'table_data_controller.g.dart';

class TableDataController = _TableDataControllerBase with _$TableDataController;

abstract class _TableDataControllerBase with Store {
  SelectModel selectModel;
  final TextEditingController ctlSearch = TextEditingController();
  @observable
  int page = 1;
  @observable
  int total = 0;
  @observable
  ObservableList<ItemSelectTable> list = ObservableList();
  var error;
  @observable
  bool loading = false;

  /// Guarda os ids de todos os registros selecionados
  /// Necessário para persistir o estado da seleção
  Set<ItemSelect> selectedList = {};

  setDataSource() async {
    /// Somente busca os dados caso eles ainda não esteja na lista
    if ((page - 1) * 10 >= list.length) {
      loading = true;
      int offset = (page - 1) * 10;
      (await selectModel.fonteDados.getList(10, offset, selectModel)).listen(
          (event) {
        error = null;
        if (ctlSearch.text.trim().isEmpty) {
          event.data.forEach((item) {
            item.isSelected =
                selectedList.any((element) => element.id == item.id);
            int index = list.indexWhere((element) => element.id == item.id);
            if (index > -1) {
              list[index] = item;
            } else {
              list.add(item);
            }
          });
          loading = false;
          total = event.total;
        }
      }, onError: (error) {
        print(error);
        loading = false;
        this.error = error;
      });
    }
  }

  setDataSourceSearch() async {
    loading = true;
    String text = ctlSearch.text.trim();
    (await selectModel.fonteDados
            .getListSearch(text, 10, (page - 1) * 10, selectModel))
        .listen((ResponseData event) {
      error = null;

      /// Só altera se o texto ainda for idêntico ao pesquisado
      if (ctlSearch.text.trim() == text && text == event.filter) {
        event.data.forEach((item) {
          item.isSelected =
              selectedList.any((element) => element.id == item.id);
          int index = list.indexWhere((element) => element.id == item.id);
          if (index > -1) {
            list[index] = item;
          } else {
            list.add(item);
          }
        });
        total = event.total;
        loading = !(ctlSearch.text.trim() == text);
      }
    }, onError: (error) {
      print(error);
      loading = false;
      this.error = error;
    });
  }

  reloadData() {
    list.clear();
    if (ctlSearch.text.trim().isEmpty) {
      setDataSource();
    } else {
      setDataSourceSearch();
    }
  }

  removeItem(int id) {
    list.removeWhere((element) => element.id == id);
    --total;
  }

  DataRow generateDataRow(ItemSelect itemSelect, BuildContext context) {
    List<DataCell> cells = [];
    for (MapEntry mapEntry in itemSelect.strings.entries) {
      cells.add(DataCell(_getLinha(mapEntry, itemSelect.object)));
    }
    if (selectModel.acoes?.isNotEmpty == true) {
      List<Widget> widgets = [];
      for (Acao acao in selectModel.acoes) {
        widgets.add(IconButton(
          tooltip: acao.descricao,
          icon: acao.icon ?? Text(acao.descricao ?? 'Ação'),
          onPressed: () {
            if (acao.funcao != null) {
              acao.funcao(data: itemSelect);
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
                if (selectModel.tipoSelecao ==
                    SelectAnyPage.TIPO_SELECAO_SIMPLES) {
                  if (Navigator?.of(context)?.canPop() == true) {
                    Navigator?.of(context)?.pop(itemSelect);
                  }
                } else {
                  if (b) {
                    selectedList.add(itemSelect);
                  } else {
                    selectedList
                        .removeWhere((element) => element.id == itemSelect.id);
                  }
                  itemSelect.isSelected = b;
                }
              }
            : null,
        selected: itemSelect.isSelected ?? false);
    return dataRow;
  }

  List<DataColumn> generateDataColumn() {
    return selectModel.linhas
        .map((e) =>
            DataColumn(label: Text(e.nome ?? e.chave.upperCaseFirstLower())))
        .toList()
          ..addAll(selectModel.acoes?.isNotEmpty == true
              ? [DataColumn(label: Text('Ações'))]
              : []);
  }

  Widget _getLinha(MapEntry item, Map map) {
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
