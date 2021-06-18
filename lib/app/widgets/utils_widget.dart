import 'package:data_table_plus/data_table_plus.dart';
import 'package:flutter/material.dart';
import 'package:msk_utils/extensions/date.dart';
import 'package:msk_utils/extensions/string.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:select_any/app/models/models.dart';
import 'package:select_any/app/modules/select_any/select_any_page.dart';

class UtilsWidget {
  static DataRow generateDataRow(
      SelectModel selectModel,
      int index,
      ItemSelect itemSelect,
      BuildContext context,
      Map data,
      Function(ItemSelect, bool) onSelected,
      Function reloadData,
      int typeScreen,
      DataSource dataSource,
      {bool generateActions = true}) {
    List<DataCell> cells = [];
    for (MapEntry mapEntry in itemSelect.strings.entries) {
      cells.add(DataCell(getLinha(
          selectModel,
          mapEntry,
          itemSelect.object is Map ? itemSelect.object : itemSelect.strings,
          typeScreen, () {
        onSelected(itemSelect, !(itemSelect.isSelected ?? false));
      })));
    }
    if (generateActions && selectModel.acoes?.isNotEmpty == true) {
      List<Widget> widgets = [];
      for (Acao acao in selectModel.acoes) {
        widgets.add(IconButton(
          splashRadius: 24,
          tooltip: acao.descricao,
          icon: acao.icon ?? Text(acao.descricao ?? 'Ação'),
          onPressed: () {
            UtilsWidget.onAction(
                context, itemSelect, index, acao, data, reloadData, dataSource);
          },
        ));
      }
      cells.add(DataCell(Row(children: widgets)));
    }
    DataRowPlus dataRow = DataRowPlus.byIndex(
        index: index,
        cells: cells,
        onSelectChanged:
            //  selectModel.tipoSelecao ==
            //             SelectAnyPage.TIPO_SELECAO_SIMPLES ||
            //         selectModel.tipoSelecao == SelectAnyPage.TIPO_SELECAO_MULTIPLA
            (b) {
          onSelected(itemSelect, b);
        },
        selected: itemSelect.isSelected ?? false);
    return dataRow;
  }

  static List<DataColumn> generateDataColumn(SelectModel selectModel,
      {bool generateActions = true, Function(int, bool) onSort}) {
    return selectModel.linhas
        .map((e) => DataColumn(
            onSort: onSort,
            label: Text(e.nome ?? e.chave.upperCaseFirstLower(),
                style: TextStyle(
                    fontSize: 16,
                    height: 0.85,
                    fontWeight: FontWeight.bold,
                    color: Colors.white))))
        .toList()
          ..addAll(generateActions && selectModel.acoes?.isNotEmpty == true
              ? [
                  DataColumn(
                      label: Text('Ações',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)))
                ]
              : []);
  }

  static Widget getLinha(SelectModel selectModel, MapEntry item, Map map,
      int typeScreen, Function onTap) {
    Linha linha = selectModel.linhas
        .firstWhere((linha) => linha.chave == item.key, orElse: () => null);
    if (linha != null && linha.personalizacao != null) {
      return linha
          .personalizacao(CustomLineData(data: map, typeScreen: typeScreen));
    } else {
      if (linha.formatData != null) {
        return _getText(
            linha.formatData.formatData(ObjFormatData(data: item.value)),
            onTap,
            linha);
      }
      if (item.value?.toString()?.isNullOrBlank != false) {
        return _getText(linha.valorPadrao?.call(map) ?? '', onTap, linha);
      }
      if (linha.typeData is TDDateTimestamp) {
        return _getText(
            DateTime.fromMillisecondsSinceEpoch(item.value)
                .string((linha.typeData as TDDateTimestamp).outputFormat),
            onTap,
            linha);
      }
      return _getText(item.value?.toString(), onTap, linha);
    }
  }

  static Widget _getText(String value, Function onTap, Linha linha) {
    if ((linha?.maxLines ?? 1) > 2 || linha.showTextInTableScroll == true) {
      return SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 2),
        child: _selectableText(value, onTap, linha),
      ));
    } else
      return _selectableText(value, onTap, linha);
  }

  static Widget _selectableText(String value, Function onTap, Linha linha) {
    return SelectableText(value ?? '',
        maxLines: linha?.maxLines,
        minLines: linha?.minLines,
        onTap: onTap,
        scrollPhysics: const NeverScrollableScrollPhysics());
  }

  static void onAction(BuildContext context, ItemSelect itemSelect, int index,
      Acao acao, Map data, Function reloadData, DataSource dataSource) async {
    if (acao.funcao != null) {
      if (acao.fecharTela) {
        Navigator.pop(context);
      }
      acao.funcao(
          DataFunction(data: itemSelect, index: index, context: context));
    }
    if (acao.funcaoAtt != null) {
      if (acao.fecharTela) {
        Navigator.pop(context);
      }

      var res = await acao.funcaoAtt(data: itemSelect, context: context);
      if (res == true) {
        reloadData();
      }
    } else if (acao.route != null || acao.page != null) {
      Map<String, dynamic> dados = Map();
      if (acao.chaves?.entries != null) {
        for (MapEntry dado in acao.chaves.entries) {
          if (itemSelect != null &&
              (itemSelect.object as Map).containsKey(dado.key)) {
            dados.addAll({dado.value: itemSelect.object[dado.key]});
          } else if (data.containsKey(dado.key)) {
            dados.addAll({dado.value: data[dado.key]});
          }
        }
      }

      RouteSettings settings = (itemSelect != null || dados.isNotEmpty)
          ? RouteSettings(arguments: {
              'cod_obj': itemSelect?.id,
              'obj': itemSelect?.object,
              'data': dados,
              'dataSource': dataSource
            })
          : RouteSettings();

      var res = await Navigator.of(context).push(acao.route != null
          ? acao.route
          : new MaterialPageRoute(
              builder: (_) => acao.page, settings: settings));

      if (res != null && res != false) {
        if (acao.fecharTela) {
          if (res is Map &&
              res['dados'] != null &&
              res['dados'] is Map &&
              res['dados'].isNotEmpty) {
            Navigator.pop(context, res['dados']);
          } else if (res is Map &&
              res['data'] != null &&
              res['data'] is Map &&
              res['data'].isNotEmpty) {
            Navigator.pop(context, res['data']);
          } else {
            Navigator.pop(context, res);
          }
        } else {
          reloadData();
        }
      }
    }
  }

  static void exibirListaAcoes(
      BuildContext context,
      ItemSelect itemSelect,
      int index,
      List<Acao> acoes,
      Map data,
      Function reloadData,
      DataSource dataSource) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: acoes
                  .map((acao) => new ListTile(
                      leading: acao.icon,
                      title: new Text(acao.descricao),
                      onTap: () {
                        Navigator.pop(context);
                        UtilsWidget.onAction(context, itemSelect, index, acao,
                            data, reloadData, dataSource);
                      }))
                  .toList(),
            ),
          );
        });
  }

  static tratarOnTap(
      BuildContext context,
      ItemSelect itemSelect,
      int index,
      SelectModel selectModel,
      Map data,
      Function onDataUpdate,
      DataSource dataSource) {
    if (selectModel.tipoSelecao == SelectAnyPage.TIPO_SELECAO_ACAO &&
        selectModel.acoes != null) {
      if (selectModel.acoes.length > 1) {
        UtilsWidget.exibirListaAcoes(context, itemSelect, index,
            selectModel.acoes, data, onDataUpdate, dataSource);
      } else if (selectModel.acoes.isNotEmpty) {
        Acao acao = selectModel.acoes?.first;
        if (acao != null) {
          UtilsWidget.onAction(
              context, itemSelect, index, acao, data, onDataUpdate, dataSource);
        }
      }
    } else if (selectModel.tipoSelecao == SelectAnyPage.TIPO_SELECAO_SIMPLES) {
      Navigator.pop(context, itemSelect.object);
    } else if (selectModel.tipoSelecao == SelectAnyPage.TIPO_SELECAO_MULTIPLA) {
      itemSelect.isSelected = !itemSelect.isSelected;
    }
  }

  static void tratarOnLongPres(
      BuildContext context,
      ItemSelect itemSelect,
      int index,
      SelectModel selectModel,
      Map data,
      Function onDataUpdate,
      DataSource dataSource) {
    if (selectModel.acoes != null) {
      if (selectModel.acoes.length > 1) {
        UtilsWidget.exibirListaAcoes(context, itemSelect, index,
            selectModel.acoes, data, onDataUpdate, dataSource);
      } else {
        Acao acao = selectModel.acoes?.first;
        if (acao != null) {
          UtilsWidget.onAction(
              context, itemSelect, index, acao, data, onDataUpdate, dataSource);
        }
      }
    } else if (selectModel.tipoSelecao == SelectAnyPage.TIPO_SELECAO_SIMPLES) {
      Navigator.pop(context, itemSelect.object);
    } else if (selectModel.tipoSelecao == SelectAnyPage.TIPO_SELECAO_MULTIPLA) {
      itemSelect.isSelected = !itemSelect.isSelected;
    } else {
      //case seja do tipo acao, mas n tenha nenhuma acao
      Navigator.pop(context, itemSelect.object);
    }
  }

  static Future<TypeSearch> showDialogChangeTypeSearch(
      BuildContext context, TypeSearch actualType) async {
    return await showDialog(
        context: context,
        builder: (alertContext) => AlertDialog(
              title: Text('Seleciona um tipo de pesquisa'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Contém'),
                    trailing: actualType == TypeSearch.CONTAINS
                        ? Icon(Icons.done)
                        : null,
                    onTap: () {
                      Navigator.pop(alertContext, TypeSearch.CONTAINS);
                    },
                  ),
                  ListTile(
                    title: Text('Inicia com'),
                    trailing: actualType == TypeSearch.BEGINSWITH
                        ? Icon(Icons.done)
                        : null,
                    onTap: () {
                      Navigator.pop(alertContext, TypeSearch.BEGINSWITH);
                    },
                  ),
                  ListTile(
                    title: Text('Termina com'),
                    trailing: actualType == TypeSearch.ENDSWITH
                        ? Icon(Icons.done)
                        : null,
                    onTap: () {
                      Navigator.pop(alertContext, TypeSearch.ENDSWITH);
                    },
                  ),
                  ListTile(
                    title: Text('Não contém'),
                    trailing: actualType == TypeSearch.NOTCONTAINS
                        ? Icon(Icons.done)
                        : null,
                    onTap: () {
                      Navigator.pop(alertContext, TypeSearch.NOTCONTAINS);
                    },
                  ),
                ],
              ),
            ));
  }
}

showSnackMessage(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)
      .showSnackBar(SnackBar(content: Text(message)));
}
