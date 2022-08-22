import 'package:collection/collection.dart' show IterableExtension;
import 'package:data_table_plus/data_table_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk_utils/msk_utils.dart';
import 'package:select_any/select_any.dart';
import 'package:select_any/src/presentation/widgets/select_range_date/select_range_date.dart';

class UtilsWidget {
  static DataRow generateDataRow(
      SelectModel selectModel,
      int index,
      ItemSelect itemSelect,
      BuildContext context,
      Map? data,
      Function(ItemSelect, bool, int index) onSelected,
      Function reloadData,
      int typeScreen,
      DataSource? dataSource,
      {bool generateActions = true}) {
    List<DataCell> cells = [];
    for (MapEntry mapEntry in itemSelect.strings.entries) {
      cells.add(DataCell(getWidgetLine(
          selectModel,
          mapEntry,
          itemSelect.object is Map ? itemSelect.object : itemSelect.strings,
          typeScreen, () {
        onSelected(itemSelect, !itemSelect.isSelected, index);
      })));
    }
    if (generateActions && selectModel.actions?.isNotEmpty == true) {
      List<Widget> widgets = [];
      for (ActionSelect action in selectModel.actions!) {
        widgets.add(IconButton(
          splashRadius: 24,
          color: selectModel.theme.defaultIconActionColor,
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
        onSelectChanged: (b) {
          onSelected(itemSelect, b ?? true, index);
        },
        selected: itemSelect.isSelected);
    return dataRow;
  }

  static List<DataColumn> generateDataColumn(SelectModel selectModel,
      {bool generateActions = true, Function(int, bool)? onSort}) {
    return selectModel.lines
        .map((e) => DataColumn(
            tooltip: e.tableTooltip,
            onSort: e.enableSorting ? onSort : null,
            label: Text(e.name ?? e.key.upperCaseFirstLower()!,
                style: selectModel.theme.tableTheme.headerTextStyle)))
        .toList()
      ..addAll(generateActions && selectModel.actions?.isNotEmpty == true
          ? [
              DataColumn(
                  label: Text('Ações',
                      style:
                          selectModel.theme.tableTheme.headerActionsTextStyle))
            ]
          : []);
  }

  static Widget getWidgetLine(SelectModel selectModel, MapEntry item, Map? map,
      int typeScreen, void Function()? onTap) {
    Line? linha =
        selectModel.lines.firstWhereOrNull((linha) => linha.key == item.key);
    if (linha == null) {
      return SizedBox();
    }
    if (linha.customLine != null) {
      return linha
          .customLine!(CustomLineData(data: map, typeScreen: typeScreen));
    } else {
      ObjFormatData objFormatData = ObjFormatData(data: item.value, map: map);
      if (linha.formatData != null) {
        return _getText(linha.formatData!.formatData(objFormatData), onTap,
            linha, selectModel, objFormatData);
      }
      if (item.value?.toString().isNullOrBlank != false) {
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

  static Widget _getText(String? value, void Function()? onTap, Line linha,
      SelectModel selectModel, ObjFormatData objFormatData) {
    if (linha.alwaysShowTextTableInScroll || linha.maxLines > 3) {
      return SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 2),
        child: _selectableText(value, onTap, linha, selectModel, objFormatData),
      ));
    }
    return _selectableText(value, onTap, linha, selectModel, objFormatData);
  }

  static Widget _selectableText(String? value, void Function()? onTap,
      Line linha, SelectModel selectModel, ObjFormatData objFormatData) {
    return SelectableText(value ?? '',
        style: linha.textStyle?.call(objFormatData) ??
            selectModel.theme.defaultTextStyle,
        maxLines: linha.maxLines,
        minLines: linha.minLines,
        onTap: onTap,
        scrollPhysics: const NeverScrollableScrollPhysics());
  }

  static void onAction(
      BuildContext context,
      ItemSelect? itemSelect,
      int? index,
      ActionSelect acao,
      Map? data,
      Function reloadData,
      DataSource? dataSource) async {
    if (acao.function != null) {
      if (acao.closePage) {
        Navigator.pop(context);
      }
      acao.function!(
          DataFunction(data: itemSelect, index: index, context: context));
    }
    if (acao.functionUpd != null) {
      if (acao.closePage) {
        Navigator.pop(context);
      }

      var res = await acao.functionUpd!(
          DataFunction(data: itemSelect, index: index, context: context));
      if (res == true) {
        reloadData();
      }
    } else if (acao.route != null || acao.page != null) {
      Map<String, dynamic> dados = Map();
      if (acao.keys?.entries != null) {
        for (MapEntry dado in acao.keys!.entries) {
          if (itemSelect != null &&
              (itemSelect.object as Map).containsKey(dado.key)) {
            dados.addAll({dado.value: itemSelect.object[dado.key]});
          } else if (data != null && data.containsKey(dado.key)) {
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
          ? acao.route!
          : new MaterialPageRoute(
              builder: (_) => acao.page!(), settings: settings));

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

  static void showListActions(
      BuildContext context,
      ItemSelect itemSelect,
      int index,
      List<ActionSelect>? actions,
      Map? data,
      Function reloadData,
      DataSource? dataSource) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: actions!
                  .map((acao) => new ListTile(
                      leading: acao.icon,
                      title: new Text(acao.description ?? ''),
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

  static void cbOnTap(BuildContext context, ItemSelect itemSelect, int index,
      SelectAnyController controller) {
    if (controller.selectModel!.typeSelect == TypeSelect.ACTION &&
        controller.selectModel!.actions != null) {
      if (controller.selectModel!.actions!.length > 1) {
        UtilsWidget.showListActions(
            context,
            itemSelect,
            index,
            controller.selectModel!.actions,
            controller.data,
            controller.reloadData,
            controller.actualDataSource);
      } else if (controller.selectModel!.actions!.isNotEmpty) {
        ActionSelect? acao = controller.selectModel!.actions?.first;
        if (acao != null) {
          UtilsWidget.onAction(
              context,
              itemSelect,
              index,
              acao,
              controller.data,
              controller.reloadData,
              controller.actualDataSource);
        }
      }
    } else if (controller.selectModel!.typeSelect == TypeSelect.SIMPLE) {
      Navigator.pop(context, itemSelect.object);
    } else if (controller.selectModel!.typeSelect == TypeSelect.MULTIPLE) {
      controller.updateSelectItem(itemSelect, !itemSelect.isSelected);
    }
  }

  static void tratarOnLongPres(BuildContext context, ItemSelect itemSelect,
      int index, SelectAnyController controller) {
    if (controller.selectModel!.actions != null) {
      if (controller.selectModel!.actions!.length > 1) {
        UtilsWidget.showListActions(
            context,
            itemSelect,
            index,
            controller.selectModel!.actions,
            controller.data,
            controller.reloadData,
            controller.actualDataSource);
      } else {
        ActionSelect? acao = controller.selectModel!.actions?.first;
        if (acao != null) {
          UtilsWidget.onAction(
              context,
              itemSelect,
              index,
              acao,
              controller.data,
              controller.reloadData,
              controller.actualDataSource);
        }
      }
    } else if (controller.selectModel!.typeSelect == TypeSelect.SIMPLE) {
      Navigator.pop(context, itemSelect.object);
    } else if (controller.selectModel!.typeSelect == TypeSelect.MULTIPLE) {
      controller.updateSelectItem(itemSelect, !itemSelect.isSelected);
    } else {
      /// caso seja do tipo acao, mas n tenha nenhuma acao
      Navigator.pop(context, itemSelect.object);
    }
  }

  static Future<TypeSearch?> showDialogChangeTypeSearch(
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

  static List<Widget> getFilters(
    SelectAnyController controller,
  ) {
    return controller.selectModel?.lines.map((e) {
          if (e.enableLineFilter == true &&
              !controller.filterWidgets.containsKey(e.key)) {
            if (e.filter != null) {
              if (e.filter is FilterRangeDate) {
                controller.filterWidgets[e] = SelectRangeDateWidget(
                    SelectRangeDateController(), (dateMin, dateMax) {
                  (e.filter as FilterRangeDate).selectedValueRange =
                      ItemDataFilterRange(start: dateMin, end: dateMax);
                  controller.onColumnFilterChanged();
                });
              } else if (e.filter is FilterSelectItem) {
                controller.filterWidgets[e] = Observer(builder: (_) {
                  return FutureBuilder<List<ItemDataFilter>>(
                      future: (e.filter as FilterSelectItem)
                          .fontDataFilter
                          .getList(
                              controller.actualFilters, controller.filter.text),
                      builder: (_, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return SizedBox();
                        }
                        if (snap.hasError) return Text('Falha ao carregar');

                        return Observer(builder: (_) {
                          if (snap.data?.any((element) =>
                                  element.value ==
                                  (e.filter as FilterSelectItem)
                                      .selectedValue
                                      ?.value) !=
                              true) {
                            (e.filter as FilterSelectItem)
                                .selectedValue
                                ?.value = null;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 3,
                              left: 8,
                              right: 8,
                            ),
                            child: DropdownButtonFormField<dynamic>(
                                onChanged: (value) {
                                  /// Limpa o input
                                  if (value == null) {
                                    if ((e.filter as FilterSelectItem)
                                            .selectedValue !=
                                        null) {
                                      (e.filter as FilterSelectItem)
                                          .selectedValue = null;
                                      controller.onColumnFilterChanged();
                                    }
                                    return;
                                  }
                                  final newValue = snap.data.firstWhereOrNull(
                                      (element) => element.value == value);
                                  if (newValue?.value !=
                                      (e.filter as FilterSelectItem)
                                          .selectedValue
                                          ?.value) {
                                    (e.filter as FilterSelectItem)
                                        .selectedValue = newValue;
                                    controller.onColumnFilterChanged();
                                  }
                                },
                                value: (e.filter as FilterSelectItem)
                                    .selectedValue
                                    ?.value,
                                items: [
                                  DropdownMenuItem<dynamic>(
                                      value: null, child: Text(''))
                                ]..addAll(snap.data!
                                    .map((e) => DropdownMenuItem(
                                        value: e.value,
                                        child: Text(e.label ?? '')))
                                    .toList())),
                          );
                        });
                      });
                });
              } else if (e.filter is FilterText) {
                controller.filterWidgets[e] = Padding(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 2, bottom: 3),
                  child: TextField(
                    controller: TextEditingController(),
                    decoration: InputDecoration(hintText: '${e.name ?? e.key}'),
                    inputFormatters: e.typeData is TDNumber
                        ? [FilteringTextInputFormatter.digitsOnly]
                        : [],
                    onChanged: (text) {
                      if (e.filter!.selectedValue?.toString() != text.trim()) {
                        e.filter!.selectedValue =
                            ItemDataFilter(value: text.trim());
                        controller.onColumnFilterChanged();
                      }
                    },
                  ),
                );
              }
            }
          }
          return Container(height: 48, child: controller.filterWidgets[e]);
        }).toList() ??
        [];
  }
}
