import 'package:data_table_plus/data_table_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:msk_utils/utils/utils_hive.dart';
import 'package:select_any/src/models/models.dart';
import 'package:select_any/src/modules/select_any/select_any_controller.dart';
import 'package:select_any/src/modules/select_any/select_any_page.dart';
import 'package:select_any/src/widgets/falha/falha_widget.dart';
import 'package:select_any/src/widgets/selecionar_range_data/selecionar_range_data_controller.dart';
import 'package:select_any/src/widgets/selecionar_range_data/selecionar_range_data_widget.dart';
import 'package:select_any/src/widgets/utils_widget.dart';

class TableDataWidget extends StatelessWidget {
  final SelectAnyController controller;

  TableDataWidget(SelectModel selectModel,
      {Key key, @required this.controller, bool carregarDados = true})
      : super(key: key) {
    controller.selectModel = selectModel;
    if (selectModel.preSelected != null) {
      controller.selectedList = selectModel.preSelected.toSet();
    }

    if (carregarDados) {
      controller.fonteDadoAtual = selectModel.fonteDados;
      controller.setDataSource();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: controller.selectModel.theme?.tableTheme?.tablePadding,
      child: SingleChildScrollView(
          child:
              controller.selectModel.theme?.tableTheme?.showTableInCard != false
                  ? Card(child: _buildContent(context))
                  : _buildContent(context)),
    );
  }

  Widget _buildContent(BuildContext context) {
    List<Widget> buttons = [];
    if (controller.selectModel.botoes != null &&
        controller.selectModel.theme?.buttonsPosition ==
            ButtonsPosition.IN_TABLE_AND_BOTTOM) {
      buttons.addAll(controller.selectModel.botoes
          .map((e) => IconButton(
                splashRadius: 24,
                icon: e.icon ?? Icon(Icons.add),
                tooltip: e.descricao,
                onPressed: () {
                  UtilsWidget.onAction(context, null, null, e, controller.data,
                      controller.reloadData, controller.fonteDadoAtual);
                },
              ))
          .toList());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
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
                        IconButton(
                            splashRadius: 24,
                            tooltip: 'Opções de pesquisa',
                            onPressed: () async {
                              var newType =
                                  await UtilsWidget.showDialogChangeTypeSearch(
                                      context, controller.typeSearch);
                              controller.updateTypeSearch(newType);
                            },
                            icon: Icon(Icons.saved_search)),
                        Observer(builder: (_) {
                          if (!controller.showSearch) {
                            return SizedBox();
                          }
                          return Row(mainAxisSize: MainAxisSize.min, children: [
                            SizedBox(width: 8),
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
                            Icon(Icons.search),
                          ]);
                        }),

                        /// fonteDadoAtual pode ser null caso o carregarDados seja false
                        if (controller.fonteDadoAtual?.allowExport == true)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 8),
                              IconButton(
                                  splashRadius: 24,
                                  tooltip: 'Exportar',
                                  icon: Icon(Icons.file_download),
                                  onPressed: () {
                                    controller.export();
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
          if (controller.confirmarParaCarregarDados) {
            return Center(
                child: TextButton.icon(
                    icon: Icon(Icons.sync),
                    label: Text('Carregar dados'),
                    onPressed: () {
                      /// Aqui é vantagem usar o setState, pois toda a tela precisa ser recarregada

                      controller.confirmarParaCarregarDados = false;
                      controller.fonteDadoAtual =
                          controller.selectModel.fonteDados;
                      controller.setDataSource();
                    }));
          }

          if (controller.error != null) {
            return FalhaWidget('Houve uma falha ao carregar os dados',
                error: controller.error);
          }

          /// Codigo para armazenar em variáveis partes do conteúdo

          List<DataRow> rows = [];
          List<ItemSelect> subList = [];
          if (!controller.loading) {
            int start =
                (controller.page - 1).abs() * controller.quantityItensPage;
            int end = controller.page * controller.quantityItensPage;

            subList = controller.list
                .where((element) =>
                    element.position >= start && element.position <= end)
                .toList();

            int i = 0;
            for (var element in subList) {
              rows.add(UtilsWidget.generateDataRow(
                  controller.selectModel, i, element, context, controller.data,
                  (ItemSelect itemSelect, bool b) {
                if (controller.selectModel.tipoSelecao ==
                    SelectAnyPage.TIPO_SELECAO_SIMPLES) {
                  if (Navigator?.maybeOf(context)?.canPop() == true) {
                    Navigator?.maybeOf(context)?.pop(itemSelect.object);
                  }
                }
                if (controller.selectModel.tipoSelecao ==
                    SelectAnyPage.TIPO_SELECAO_ACAO) {
                  /// Gambi para evitar problemas ao usuário clicar em selecionar todos
                  if ((controller.lastClick + 500) <
                      (DateTime.now().millisecondsSinceEpoch)) {
                    controller.lastClick =
                        DateTime.now().millisecondsSinceEpoch;
                    UtilsWidget.tratarOnTap(
                        context,
                        itemSelect,
                        i,
                        controller.selectModel,
                        controller.data,
                        controller.reloadData,
                        controller.fonteDadoAtual);
                  }
                } else {
                  if (b) {
                    controller.selectedList.add(itemSelect);
                  } else {
                    controller.selectedList
                        .removeWhere((element) => element.id == itemSelect.id);
                  }
                  itemSelect.isSelected = b;
                }
              }, controller.reloadData, 2, controller.fonteDadoAtual,
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
                                  controller.selectModel.tipoSelecao ==
                                      SelectAnyPage.TIPO_SELECAO_MULTIPLA,
                              tableColumnsWidth: controller.selectModel.theme
                                  ?.tableTheme?.widthTableColumns,
                              headingRowColor: controller.selectModel.theme
                                          ?.tableTheme?.headerColor !=
                                      null
                                  ? MaterialStateColor.resolveWith((states) {
                                      return controller.selectModel.theme
                                          ?.tableTheme?.headerColor;
                                    })
                                  : null,
                              sortColumnIndex: controller.itemSort?.indexLine,
                              customRows: controller.showLineFilter
                                  ? [
                                      CustomRow(
                                          index: -1,
                                          cells: <Widget>[]
                                            ..addAll(controller.selectModel
                                                            .tipoSelecao ==
                                                        SelectAnyPage
                                                            .TIPO_SELECAO_MULTIPLA &&
                                                    rows.isNotEmpty
                                                ? [Container()]
                                                : [])
                                            ..addAll(controller
                                                .selectModel.linhas
                                                .map((e) {
                                              if (e.enableLineFilter &&
                                                  !controller.filterControllers
                                                      .containsKey(e.chave)) {
                                                if (e.filter != null) {
                                                  if (e.filter
                                                      is FilterRangeDate) {
                                                    controller.filterControllers[
                                                            e.chave] =
                                                        SelecionarRangeDataWidget(
                                                            SelecionarRangeDataController(),
                                                            (dateMin, dateMax) {
                                                      controller
                                                          .onColumnFilterChanged();
                                                    });
                                                  }
                                                } else {
                                                  controller.filterControllers[
                                                      e.chave] = Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            right: 8,
                                                            top: 2,
                                                            bottom: 3),
                                                    child: TextField(
                                                      controller:
                                                          TextEditingController(),
                                                      decoration: InputDecoration(
                                                          hintText:
                                                              '${e.nome ?? e.chave}'),
                                                      onChanged: (text) {
                                                        controller
                                                            .onColumnFilterChanged();
                                                      },
                                                    ),
                                                  );
                                                }
                                              }
                                              return Container(
                                                  height: 48,
                                                  child: controller
                                                          .filterControllers[
                                                      e.chave]);
                                            }).toList()),
                                          typeCustomRow: TypeCustomRow.ADD)
                                    ]
                                  : [],
                              decoration: BoxDecoration(),
                              sortAscending: controller.itemSort?.typeSort !=
                                  EnumTypeSort.DESC,
                              columns: UtilsWidget.generateDataColumn(
                                  controller.selectModel,
                                  generateActions: false,
                                  onSort: (int index, bool sort) {
                                if (controller
                                    .selectModel.linhas[index].enableSorting) {
                                  controller.itemSort = ItemSort(
                                      typeSort: sort
                                          ? EnumTypeSort.ASC
                                          : EnumTypeSort.DESC,
                                      linha:
                                          controller.selectModel.linhas[index],
                                      indexLine: index);
                                  controller.updateSortCollumn();
                                }
                              }),
                              rows: rows),
                        )),
                  );
                })),
                if (controller.selectModel.acoes?.isNotEmpty == true)
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
                                        color: controller.selectModel.theme
                                            ?.tableTheme?.headerColor),
                                    constraints: BoxConstraints(minWidth: 60),
                                    width: controller.selectModel.acoes.length *
                                        50.0,
                                    alignment: Alignment.center,
                                    child: Text('Ações',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white)),
                                  ),
                                ],
                              );
                            } else {
                              return Row(
                                  children:
                                      controller.selectModel.acoes.map((acao) {
                                return Container(
                                  height: 48,
                                  child: IconButton(
                                    splashRadius: 24,
                                    tooltip: acao.descricao,
                                    icon: acao.icon ??
                                        Text(acao.descricao ?? 'Ação'),
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
                                          controller.fonteDadoAtual);
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
        Container(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Observer(builder: (_) {
                if (controller.list.isEmpty) return SizedBox();
                int total =
                    ((controller.total ?? 0) / controller.quantityItensPage)
                        .ceil();

                return Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      total > 0
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Linhas por Pág.'),
                                SizedBox(width: 16),
                                SizedBox(
                                  width: 90,
                                  height: 36,
                                  child: DropdownButtonFormField<int>(
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: const EdgeInsets.only(
                                              left: 16, right: 16)),
                                      value: controller.quantityItensPage,
                                      onChanged: (item) {
                                        controller.quantityItensPage = item;

                                        /// Caso o total de paginas seja menor do que a pagina atuali
                                        if (((controller.total ?? 0) /
                                                    controller
                                                        .quantityItensPage)
                                                .ceil() <
                                            controller.page) {
                                          /// Seta a ultima pagina como pagina atual
                                          controller
                                              .page = ((controller.total ?? 0) /
                                                  controller.quantityItensPage)
                                              .ceil();
                                        }
                                        controller.setCorretDataSource();

                                        /// Salva isso no banco
                                        UtilsHive.getInstance()
                                            .getBox('select_utils')
                                            .then((value) {
                                          value.put('quantityItensPage', item);
                                        });
                                      },
                                      items: controller.getNumberItemsPerPage
                                          .map((e) => DropdownMenuItem(
                                              value: e, child: Text('$e')))
                                          .toList()),
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
                                    child: DropdownButtonFormField<int>(
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.all(0)),
                                        icon: SizedBox(),
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .color),
                                        value: controller.page,
                                        onChanged: (item) {
                                          controller.page = item;
                                          controller.setCorretDataSource();
                                        },
                                        items: List<
                                                DropdownMenuItem<int>>.generate(
                                            total,
                                            (index) => DropdownMenuItem(
                                                value: index + 1,
                                                child: Text(
                                                    '${(controller.quantityItensPage * index) + 1}-${controller.quantityItensPage * (index + 1)}')))),
                                  )
                                : SizedBox(),
                            Text('de ${(controller.total ?? 0)}'),
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
                                onPressed: controller.page < total
                                    ? () {
                                        controller.page = controller.page + 1;
                                        controller.setCorretDataSource();
                                      }
                                    : null),
                            IconButton(
                                splashRadius: 24,
                                iconSize: 34,
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
