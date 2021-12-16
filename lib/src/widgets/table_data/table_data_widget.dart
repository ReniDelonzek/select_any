import 'package:data_table_plus/data_table_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk_utils/extensions/list.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:msk_utils/utils/utils_hive.dart';
import 'package:select_any/src/models/models.dart';
import 'package:select_any/src/modules/select_any/select_any_controller.dart';
import 'package:select_any/src/widgets/fail/fail_widget.dart';
import 'package:select_any/src/widgets/select_range_date/select_range_date_controller.dart';
import 'package:select_any/src/widgets/select_range_date/select_range_date_widget.dart';
import 'package:select_any/src/widgets/utils_widget.dart';

class TableDataWidget extends StatelessWidget {
  final SelectAnyController controller;

  TableDataWidget(SelectModel selectModel,
      {Key? key, required this.controller, bool carregarDados = true})
      : super(key: key) {
    controller.selectModel = selectModel;
    if (selectModel.preSelected != null) {
      controller.selectedList = selectModel.preSelected!.toSet();
    }

    if (carregarDados) {
      controller.actualDataSource = selectModel.dataSource;
      controller.setDataSource();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: controller.selectModel!.theme.tableTheme.tablePadding,
      child: SingleChildScrollView(
          child:
              controller.selectModel!.theme.tableTheme.showTableInCard != false
                  ? Card(child: _buildContent(context))
                  : _buildContent(context)),
    );
  }

  Widget _buildContent(BuildContext context) {
    List<Widget> buttons = [];
    if (controller.selectModel!.buttons != null) {
      controller.setOnTapButtons(context);
      for (ActionSelectBase action in controller.selectModel!.buttons!) {
        if ((action.buttonPosition ??
                    controller.selectModel!.theme.defaultButtonPosition)
                .call((controller.typeDiplay)) ==
            ButtonPosition.IN_TABLE) {
          buttons.add(action.build(ButtonPosition.IN_TABLE));
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 54,
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: buttons),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Observer(builder: (_) {
                          if (!controller.showSearch) {
                            return SizedBox();
                          }
                          return Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                                width: 300,
                                child: TextField(
                                  focusNode: controller.focusNodeSearch,
                                  decoration:
                                      InputDecoration(hintText: 'Pesquisar'),
                                  controller: controller.filter,
                                  onChanged: (text) {
                                    controller.filtroPesquisaModificado();
                                  },
                                )),
                            SizedBox(width: 8),
                            IconButton(
                                splashRadius: 24,
                                tooltip: 'Opções de pesquisa',
                                onPressed: () async {
                                  var newType = await UtilsWidget
                                      .showDialogChangeTypeSearch(
                                          context, controller.typeSearch);
                                  controller.updateTypeSearch(newType);
                                },
                                icon: Icon(
                                  Icons.saved_search,
                                )),
                          ]);
                        }),

                        /// fonteDadoAtual pode ser null caso o carregarDados seja false
                        if (controller.actualDataSource?.allowExport == true)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 8),
                              IconButton(
                                  splashRadius: 24,
                                  tooltip: 'Exportar',
                                  icon: Icon(Icons.file_download),
                                  onPressed: () {
                                    controller.export(context);
                                  })
                            ],
                          )
                      ],
                    )),
              ),
            ],
          ),
        ),
        Observer(builder: (_) {
          if (controller.confirmToLoadData) {
            return Center(
                child: TextButton.icon(
                    icon: Icon(Icons.sync),
                    label: Text('Carregar dados'),
                    onPressed: () {
                      /// Aqui é vantagem usar o setState, pois toda a tela precisa ser recarregada

                      controller.confirmToLoadData = false;
                      controller.actualDataSource =
                          controller.selectModel!.dataSource;
                      controller.setDataSource();
                    }));
          }

          if (controller.error != null) {
            return FailWidget('Houve uma falha ao carregar os dados',
                error: controller.error);
          }

          /// Codigo para armazenar em variáveis partes do conteúdo

          List<DataRow> rows = [];
          List<ItemSelect> subList = [];
          if (!controller.loading) {
            int start =
                (controller.page - 1).abs() * controller.quantityItensPage!;
            int end = controller.page * controller.quantityItensPage!;

            subList = controller.list
                .where((element) =>
                    element.position! >= start && element.position! <= end)
                .toList();

            int i = 0;
            for (var element in subList) {
              rows.add(UtilsWidget.generateDataRow(
                  controller.selectModel!, i, element, context, controller.data,
                  (ItemSelect itemSelect, bool b, int index) {
                if (controller.selectModel!.typeSelect == TypeSelect.SIMPLE) {
                  if (Navigator.maybeOf(context)?.canPop() == true) {
                    Navigator.maybeOf(context)?.pop(itemSelect.object);
                  }
                } else if (controller.selectModel!.typeSelect ==
                    TypeSelect.ACTION) {
                  /// Gambi para evitar problemas ao usuário clicar em selecionar todos
                  if ((controller.lastClick + 500) <
                      (DateTime.now().millisecondsSinceEpoch)) {
                    controller.lastClick =
                        DateTime.now().millisecondsSinceEpoch;
                    UtilsWidget.cbOnTap(context, itemSelect, index, controller);
                  }
                } else if (controller.selectModel!.typeSelect ==
                    TypeSelect.MULTIPLE) {
                  controller.updateSelectItem(itemSelect, b);
                }
              }, controller.reloadData, 2, controller.actualDataSource,
                  generateActions: false));
              i++;
            }
          }
          ScrollController scrollController = ScrollController();
          return Column(
            children: [
              Row(children: [
                Expanded(child: LayoutBuilder(builder: (context, constraint) {
                  return Scrollbar(
                    controller: scrollController,
                    child: SingleChildScrollView(
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          constraints:
                              BoxConstraints(minWidth: constraint.maxWidth),
                          child: DataTablePlus(
                              showCheckboxColumn:
                                  controller.selectModel!.typeSelect ==
                                      TypeSelect.MULTIPLE,
                              tableColumnsWidth: controller.selectModel!.theme
                                  .tableTheme.widthTableColumns,
                              headingRowColor: controller.selectModel!.theme
                                          .tableTheme.headerColor !=
                                      null
                                  ? MaterialStateColor.resolveWith((states) {
                                      return controller.selectModel!.theme
                                          .tableTheme.headerColor!;
                                    })
                                  : null,
                              sortColumnIndex: controller.itemSort?.indexLine,
                              customRows: getCustomRows(rows),
                              decoration: BoxDecoration(),
                              sortAscending: controller.itemSort?.typeSort !=
                                  EnumTypeSort.DESC,
                              columns: UtilsWidget.generateDataColumn(
                                  controller.selectModel!,
                                  generateActions: false,
                                  onSort: (int index, bool sort) {
                                if (controller
                                    .selectModel!.lines[index].enableSorting) {
                                  controller.itemSort = ItemSort(
                                      typeSort: sort
                                          ? EnumTypeSort.ASC
                                          : EnumTypeSort.DESC,
                                      line:
                                          controller.selectModel!.lines[index],
                                      indexLine: index);
                                  controller.updateSortCollumn();
                                }
                              }),
                              rows: rows),
                        )),
                  );
                })),
                if (controller.selectModel!.actions?.isNotEmpty == true)
                  Container(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[]
                          ..addAll(controller.showLineFilter
                              ? [
                                  SizedBox(
                                    height: 48,
                                    child: IconButton(
                                      splashRadius: 24,
                                      onPressed: () {
                                        controller.clearFilters();
                                        showSnackMessage(
                                            context, 'Os filtros foram limpos');
                                      },
                                      icon: Icon(Icons.clear),
                                    ),
                                  )
                                ]
                              : [])
                          ..addAll(List.generate(rows.length + 1, (index) {
                            if (index == 0) {
                              return Column(
                                children: [
                                  Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                        color: controller.selectModel!.theme
                                            .tableTheme.headerColor),
                                    constraints: BoxConstraints(minWidth: 60),
                                    width: controller
                                            .selectModel!.actions!.length *
                                        50.0,
                                    alignment: Alignment.center,
                                    child: Text('Ações',
                                        style: controller.selectModel!.theme
                                                .tableTheme.headerTextStyle ??
                                            TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.white)),
                                  ),
                                ],
                              );
                            } else {
                              return Row(
                                  children: controller.selectModel!.actions!
                                      .map((acao) {
                                return Container(
                                  height: 48,
                                  child: IconButton(
                                    splashRadius: 24,
                                    color: controller.selectModel!.theme
                                        .defaultIconActionColor,
                                    tooltip: acao.description,
                                    icon: acao.icon ??
                                        Text(acao.description ?? 'Ação'),
                                    onPressed: () {
                                      /// Tira 1 do index pois o index 0 é o do header
                                      int newIndex = index - 1;
                                      UtilsWidget.onAction(
                                          context,
                                          subList[newIndex],
                                          index,
                                          acao,
                                          controller.data,
                                          controller.reloadData,
                                          controller.actualDataSource);
                                    },
                                  ),
                                );
                              }).toList());
                            }
                          }))),
                  )
              ]),
              if (controller.loading) LinearProgressIndicator(),
              if (!controller.loading && subList.isEmpty)
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Text(
                    'Nenhum item encontrado',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ))
            ],
          );
        }),
        _bottomContent(context)
      ],
    );
  }

  List<CustomRow> getCustomRows(List<DataRow> rows) {
    return controller.showLineFilter
        ? [
            CustomRow(
                index: -1,
                cells: <Widget>[]
                  ..addAll(controller.selectModel?.typeSelect ==
                              TypeSelect.MULTIPLE &&
                          rows.isNotEmpty
                      ? [Container()]
                      : [])
                  ..addAll(getFilters()),
                typeCustomRow: TypeCustomRow.ADD)
          ]
        : [];
  }

  List<Widget> getFilters() {
    return controller.selectModel?.lines.map((e) {
          if (e.enableLineFilter == true &&
              !controller.filterControllers.containsKey(e.key)) {
            if (e.filter != null) {
              if (e.filter is FilterRangeDate) {
                controller.filterControllers[e.key] = SelectRangeDateWidget(
                    SelectRangeDateController(), (dateMin, dateMax) {
                  (e.filter as FilterRangeDate).selectedValueRange =
                      ItemDataFilterRange(start: dateMin, end: dateMax);
                  controller.onColumnFilterChanged();
                });
              } else if (e.filter is FilterSelectItem) {
                controller.filterControllers[e.key] = Observer(builder: (_) {
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
                controller.filterControllers[e.key] = Padding(
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
          return Container(
              height: 48, child: controller.filterControllers[e.key]);
        }).toList() ??
        [];
  }

  Widget _bottomContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        controller.selectModel?.tableBottomBuilder != null
            ? Observer(builder: (_) {
                return Flexible(
                  child: controller.selectModel!.tableBottomBuilder!(
                      CustomBottomBuilderArgs(
                          context,
                          controller.actualFilters,
                          controller.loaded,
                          controller.actualDataSource,
                          controller.list)),
                );
              })
            : SizedBox(),
        Container(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Observer(builder: (_) {
                if (controller.list.isEmpty) return SizedBox();
                int total =
                    ((controller.total) / controller.quantityItensPage!).ceil();

                return Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      total > 0
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Linhas por Pág.',
                                    style: controller
                                        .selectModel!.theme.defaultTextStyle),
                                SizedBox(width: 16),
                                SizedBox(
                                  width: 90,
                                  height: 36,
                                  child: Observer(builder: (_) {
                                    return DropdownButtonFormField<int>(
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    left: 16, right: 16)),
                                        value: controller.quantityItensPage,
                                        onChanged: (item) {
                                          /// Não remover o ??, remover fará com que não funcione corretamente na web/release
                                          controller.quantityItensPage =
                                              item ?? 10;

                                          /// Caso o total de paginas seja menor do que a pagina atuali
                                          if (((controller.total) /
                                                      controller
                                                          .quantityItensPage!)
                                                  .ceil() <
                                              controller.page) {
                                            /// Seta a ultima pagina como pagina atual
                                            controller.page =
                                                ((controller.total) /
                                                        controller
                                                            .quantityItensPage!)
                                                    .ceil();
                                          }
                                          controller.setCorretDataSource();

                                          /// Salva isso no banco
                                          UtilsHive.getInstance()!
                                              .getBox('select_utils')
                                              .then((value) {
                                            value.put(
                                                'quantityItensPage', item);
                                          });
                                        },
                                        items: controller.getNumberItemsPerPage
                                            .map((e) => DropdownMenuItem(
                                                value: e,
                                                child: Text('$e',
                                                    style: controller
                                                        .selectModel!
                                                        .theme
                                                        .defaultTextStyle)))
                                            .toList());
                                  }),
                                ),
                                SizedBox(width: 16)
                              ],
                            )
                          : SizedBox(),
                      SizedBox(width: 24),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            total > 0
                                ? SizedBox(
                                    /// TODO Implementar abordagem com Flexiveis
                                    width: 30 +
                                        ((controller.total.toString().length) *
                                                12)
                                            .toDouble(),
                                    child: Observer(builder: (_) {
                                      return DropdownButtonFormField<int>(
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.all(0)),
                                          icon: SizedBox(),
                                          style: controller.selectModel!.theme
                                                  .defaultTextStyle ??
                                              TextStyle(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1!
                                                      .color),
                                          value: controller.page,
                                          onChanged: (item) {
                                            controller.page = item ?? 1;
                                            controller.setCorretDataSource();
                                          },
                                          items: List<DropdownMenuItem<int>>.generate(
                                              total,
                                              (index) => DropdownMenuItem(
                                                  value: index + 1,
                                                  child: Text(
                                                      '${(controller.quantityItensPage! * index) + 1}-${controller.quantityItensPage! * (index + 1)}',
                                                      style: controller
                                                          .selectModel!
                                                          .theme
                                                          .defaultTextStyle))));
                                    }),
                                  )
                                : SizedBox(),
                            Text('de ${(controller.total)}',
                                style: controller
                                    .selectModel!.theme.defaultTextStyle),
                          ],
                        ),
                      ),
                      SizedBox(width: 24),
                      if (total > 1)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                splashRadius: 24,
                                iconSize: 34,
                                icon: Icon(Icons.first_page),
                                color: controller.selectModel!.theme.tableTheme
                                    .bottomIconsColor,
                                onPressed: controller.page > 1
                                    ? () {
                                        controller.page = 1;
                                        controller.setCorretDataSource();
                                      }
                                    : null),
                            IconButton(
                                splashRadius: 24,
                                iconSize: 36,
                                icon: Icon(Icons.keyboard_arrow_left_rounded),
                                color: controller.selectModel!.theme.tableTheme
                                    .bottomIconsColor,
                                onPressed: controller.page > 1
                                    ? () {
                                        controller.page = controller.page - 1;
                                        controller.setCorretDataSource();
                                      }
                                    : null),
                            IconButton(
                                splashRadius: 24,
                                iconSize: 36,
                                icon: Icon(Icons.keyboard_arrow_right_rounded),
                                color: controller.selectModel!.theme.tableTheme
                                    .bottomIconsColor,
                                onPressed: controller.page < total
                                    ? () {
                                        controller.page = controller.page + 1;
                                        controller.setCorretDataSource();
                                      }
                                    : null),
                            IconButton(
                                splashRadius: 24,
                                iconSize: 34,
                                color: controller.selectModel!.theme.tableTheme
                                    .bottomIconsColor,
                                icon: Icon(Icons.last_page),
                                onPressed: controller.page < total
                                    ? () {
                                        controller.page = total;
                                        controller.setCorretDataSource();
                                      }
                                    : null)
                          ],
                        )
                    ],
                  ),
                );
              }),
            )),
      ],
    );
  }
}
