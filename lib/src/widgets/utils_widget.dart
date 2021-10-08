import 'package:data_table_plus/data_table_plus.dart';
import 'package:flutter/material.dart';
import 'package:msk_utils/extensions/date.dart';
import 'package:msk_utils/extensions/string.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:msk_utils/msk_utils.dart';
import 'package:select_any/src/models/models.dart';
import 'package:select_any/src/widgets/my_snack_bar.dart';

class UtilsWidget {
  static DataRow generateDataRow(
      SelectModel selectModel,
      int index,
      ItemSelect itemSelect,
      BuildContext context,
      Map data,
      Function(ItemSelect, bool, int index) onSelected,
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
        onSelected(itemSelect, !(itemSelect.isSelected ?? false), index);
      })));
    }
    if (generateActions && selectModel.actions?.isNotEmpty == true) {
      List<Widget> widgets = [];
      for (ActionSelect action in selectModel.actions) {
        widgets.add(IconButton(
          splashRadius: 24,
          color: selectModel.theme?.defaultIconActionColor,
          tooltip: action.description,
          icon: action.icon ?? Text(action.description ?? 'Ação'),
          onPressed: () {
            UtilsWidget.onAction(context, itemSelect, index, action, data,
                reloadData, dataSource);
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
          onSelected(itemSelect, b, index);
        },
        selected: itemSelect.isSelected ?? false);
    return dataRow;
  }

  static List<DataColumn> generateDataColumn(SelectModel selectModel,
      {bool generateActions = true, Function(int, bool) onSort}) {
    return selectModel.lines
        .map((e) => DataColumn(
            tooltip: e.tableTooltip,
            onSort: e.enableSorting ? onSort : null,
            label: Text(e.name ?? e.key.upperCaseFirstLower(),
                style: selectModel.theme?.tableTheme?.headerTextStyle ??
                    TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))))
        .toList()
      ..addAll(generateActions && selectModel.actions?.isNotEmpty == true
          ? [
              DataColumn(
                  label: Text('Ações',
                      style: selectModel.theme?.tableTheme?.headerTextStyle ??
                          TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)))
            ]
          : []);
  }

  static Widget getLinha(SelectModel selectModel, MapEntry item, Map map,
      int typeScreen, Function onTap) {
    Line linha = selectModel.lines
        .firstWhere((linha) => linha.key == item.key, orElse: () => null);
    ObjFormatData objFormatData = ObjFormatData(data: item.value, map: map);
    if (linha != null && linha.customLine != null) {
      return linha
          .customLine(CustomLineData(data: map, typeScreen: typeScreen));
    } else {
      if (linha.formatData != null) {
        return _getText(linha.formatData.formatData(objFormatData), onTap,
            linha, selectModel, objFormatData);
      }
      if (item.value?.toString()?.isNullOrBlank != false) {
        return _getText(linha.defaultValue?.call(map) ?? '', onTap, linha,
            selectModel, objFormatData);
      }
      if (linha.typeData is TDDateTimestamp) {
        return _getText(
            DateTime.fromMillisecondsSinceEpoch(item.value)
                .string((linha.typeData as TDDateTimestamp).outputFormat),
            onTap,
            linha,
            selectModel,
            objFormatData);
      }
      return _getText(
          item.value?.toString(), onTap, linha, selectModel, objFormatData);
    }
  }

  static Widget _getText(String value, Function onTap, Line linha,
      SelectModel selectModel, ObjFormatData objFormatData) {
    if ((linha?.maxLines ?? 1) > 3 || linha.showTextInTableScroll == true) {
      return SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 2),
        child: _selectableText(value, onTap, linha, selectModel, objFormatData),
      ));
    } else
      return _selectableText(value, onTap, linha, selectModel, objFormatData);
  }

  static Widget _selectableText(String value, Function onTap, Line linha,
      SelectModel selectModel, ObjFormatData objFormatData) {
    return SelectableText(value ?? '',
        style: linha.textStyle?.call(objFormatData) ??
            selectModel?.theme?.defaultTextStyle,
        maxLines: linha?.maxLines,
        minLines: linha?.minLines,
        onTap: onTap,
        scrollPhysics: const NeverScrollableScrollPhysics());
  }

  static void onAction(
      BuildContext context,
      ItemSelect itemSelect,
      int index,
      ActionSelect acao,
      Map data,
      Function reloadData,
      DataSource dataSource) async {
    if (acao.function != null) {
      if (acao.closePage) {
        Navigator.pop(context);
      }
      acao.function(
          DataFunction(data: itemSelect, index: index, context: context));
    }
    if (acao.functionUpd != null) {
      if (acao.closePage) {
        Navigator.pop(context);
      }

      var res = await acao.functionUpd(
          DataFunction(data: itemSelect, index: index, context: context));
      if (res == true) {
        reloadData();
      }
    } else if (acao.route != null || acao.page != null) {
      Map<String, dynamic> dados = Map();
      if (acao.keys?.entries != null) {
        for (MapEntry dado in acao.keys.entries) {
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
              builder: (_) => acao.page(), settings: settings));

      if (res != null && res != false) {
        if (acao.closePage) {
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
      List<ActionSelect> actions,
      Map data,
      Function reloadData,
      DataSource dataSource) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: actions
                  .map((acao) => new ListTile(
                      leading: acao.icon,
                      title: new Text(acao.description),
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
    if (selectModel.typeSelect == TypeSelect.ACTION &&
        selectModel.actions != null) {
      if (selectModel.actions.length > 1) {
        UtilsWidget.exibirListaAcoes(context, itemSelect, index,
            selectModel.actions, data, onDataUpdate, dataSource);
      } else if (selectModel.actions.isNotEmpty) {
        ActionSelect acao = selectModel.actions?.first;
        if (acao != null) {
          UtilsWidget.onAction(
              context, itemSelect, index, acao, data, onDataUpdate, dataSource);
        }
      }
    } else if (selectModel.typeSelect == TypeSelect.SIMPLE) {
      Navigator.pop(context, itemSelect.object);
    } else if (selectModel.typeSelect == TypeSelect.MULTIPLE) {
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
    if (selectModel.actions != null) {
      if (selectModel.actions.length > 1) {
        UtilsWidget.exibirListaAcoes(context, itemSelect, index,
            selectModel.actions, data, onDataUpdate, dataSource);
      } else {
        ActionSelect acao = selectModel.actions?.first;
        if (acao != null) {
          UtilsWidget.onAction(
              context, itemSelect, index, acao, data, onDataUpdate, dataSource);
        }
      }
    } else if (selectModel.typeSelect == TypeSelect.SIMPLE) {
      Navigator.pop(context, itemSelect.object);
    } else if (selectModel.typeSelect == TypeSelect.MULTIPLE) {
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
  if (UtilsPlatform.isMobile) {
    ScaffoldMessenger.maybeOf(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
  } else {
    ScaffoldMessenger.maybeOf(context).showSnackBar(MySnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
  }
}
