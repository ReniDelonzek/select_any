import 'package:data_table_plus/data_table_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:msk_utils/utils/utils_hive.dart';
import 'package:select_any/app/models/models.dart';
import 'package:select_any/app/modules/select_any/select_any_controller.dart';
import 'package:select_any/app/modules/select_any/select_any_page.dart';
import 'package:select_any/app/widgets/falha/falha_widget.dart';
import 'package:select_any/app/widgets/selecionar_range_data/selecionar_range_data_controller.dart';
import 'package:select_any/app/widgets/selecionar_range_data/selecionar_range_data_widget.dart';
import 'package:select_any/app/widgets/utils_widget.dart';

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
    if (controller.selectModel.botoes != null) {
      buttons.addAll(controller.selectModel.botoes
          .map((e) => IconButton(
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

          /// Codigo para armazenar em variáveis partes do conteúdo
          if (controller.loading) {
            return Center(
                child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Carregando dados')
                      ],
                    )));
          }
          if (controller.error != null) {
            return FalhaWidget('Houve uma falha ao carregar os dados',
                error: controller.error);
          }
          int start =
              (controller.page - 1).abs() * controller.quantityItensPage;
          int end = controller.page * controller.quantityItensPage;

          List<ItemSelect> subList = controller.list
              .where((element) =>
                  element.position >= start && element.position <= end)
              .toList();

          if (subList.isEmpty && !controller.selectModel.showFiltersInput) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Nenhum item encontrado'),
            ));
          }
          List<DataRow> rows = [];

          if (controller.selectModel.showFiltersInput == true) {
            rows.add(DataRow(
                selected: false,
                cells: controller.selectModel.linhas.map((e) {
                  if (!controller.filterControllers.containsKey(e.chave)) {
                    if (e.filter != null) {
                      if (e.filter is FilterRangeDate) {
                        controller.filterControllers[e.chave] =
                            SelecionarRangeDataWidget(
                                SelecionarRangeDataController(),
                                (dateMin, dateMax) {
                          controller.filter.clear();
                          controller.setCorretDataSource();
                        });
                      }
                    } else {
                      controller.filterControllers[e.chave] = TextField(
                        controller: TextEditingController(),
                        decoration: InputDecoration(hintText: 'Filtro'),
                        onChanged: (text) {
                          print(text);
                          controller.filter.clear();
                          controller.setCorretDataSource();
                        },
                      );
                    }
                  }

                  return DataCell(Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: controller.filterControllers[e.chave],
                  ));
                }).toList()));
          }
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
                  controller.lastClick = DateTime.now().millisecondsSinceEpoch;
                  UtilsWidget.tratarOnTap(
                      context,
                      itemSelect,
                      i,
                      controller.selectModel,
                      controller.data,
                      controller.reloadData,
                      controller.fonteDadoAtual);
                }
                //UtilsWidget.exibirListaAcoes()
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
          ScrollController scrollController = ScrollController();
          return Row(children: [
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
                          tableColumnsWidth: controller
                              .selectModel.theme?.tableTheme?.widthTableColumns,
                          headingRowColor: controller.selectModel.theme
                                      ?.tableTheme?.headerColor !=
                                  null
                              ? MaterialStateColor.resolveWith((states) {
                                  return controller.selectModel.theme
                                      ?.tableTheme?.headerColor;
                                })
                              : null,
                          sortColumnIndex: controller.itemSort?.indexLine,
                          sortAscending: controller.itemSort?.typeSort !=
                              EnumTypeSort.DESC,
                          columns: UtilsWidget.generateDataColumn(
                              controller.selectModel,
                              generateActions: false,
                              onSort: (int index, bool sort) {
                            controller.itemSort = ItemSort(
                                typeSort:
                                    sort ? EnumTypeSort.ASC : EnumTypeSort.DESC,
                                linha: controller.selectModel.linhas[index],
                                indexLine: index);
                            controller.updateSortCollumn();
                          }),
                          rows: rows),
                    )),
              );
            })),
            if (controller.selectModel.acoes?.isNotEmpty == true)
              Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(rows.length + 1, (index) {
                      if (index == 0) {
                        return Column(
                          children: [
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                  color: controller.selectModel.theme
                                      ?.tableTheme?.headerColor),
                              constraints: BoxConstraints(minWidth: 60),
                              width: controller.selectModel.acoes.length * 50.0,
                              alignment: Alignment.center,
                              child: Text('Ações',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white)),
                            ),
                          ],
                        );
                      } else if (index == 1 &&
                          controller.selectModel.showFiltersInput) {
                        /// Coluna de filtros
                        return SizedBox(
                          height: 48,
                          child: IconButton(
                            onPressed: () {
                              controller.clearFilters();
                              showSnackMessage(
                                  context, 'Os filtros foram limpos');
                            },
                            icon: Icon(Icons.clear),
                          ),
                        );
                      } else {
                        return Row(
                            children: controller.selectModel.acoes.map((acao) {
                          return Container(
                            height: 48,
                            child: IconButton(
                              tooltip: acao.descricao,
                              icon: acao.icon ?? Text(acao.descricao ?? 'Ação'),
                              onPressed: () {
                                /// Tira 1 do index pois o index 0 é o do header
                                int newIndex = index - 1;
                                if (controller.selectModel.showFiltersInput) {
                                  /// Quando tiver os filtros, precisa tirar mais um
                                  newIndex -= 1;
                                }
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
                    })),
              )
          ]);
        }),
        Container(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Observer(builder: (_) {
                int total =
                    ((controller.total ?? 0) / controller.quantityItensPage)
                        .ceil();
                return Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      total > 0
                          ? Row(
                              children: [
                                Text('Itens por Pag.'),
                                SizedBox(width: 8),
                                DropdownButton<int>(
                                    underline: SizedBox(),
                                    value: controller.quantityItensPage,
                                    onChanged: (item) {
                                      controller.quantityItensPage = item;

                                      /// Caso o total de paginas seja menor do que a pagina atuali
                                      if (((controller.total ?? 0) /
                                                  controller.quantityItensPage)
                                              .ceil() <
                                          controller.page) {
                                        /// Seta a ultima pagina como pagina atual
                                        controller.page = ((controller.total ??
                                                    0) /
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
                                SizedBox(width: 16)
                              ],
                            )
                          : SizedBox(),
                      Row(
                        children: [
                          total > 0
                              ? DropdownButton<int>(
                                  underline: SizedBox(),
                                  value: controller.page,
                                  onChanged: (item) {
                                    controller.page = item;
                                    controller.setCorretDataSource();
                                  },
                                  items: List<DropdownMenuItem<int>>.generate(
                                      total,
                                      (index) => DropdownMenuItem(
                                          value: index + 1,
                                          child: Text((index + 1).toString()))))
                              : SizedBox(),
                          Text(
                              'de ${((controller.total ?? 0) / controller.quantityItensPage).ceil()}'),
                        ],
                      ),
                      if (total > 1)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                iconSize: 36,
                                icon: Icon(Icons.keyboard_arrow_left_rounded),
                                onPressed: controller.page > 1
                                    ? () {
                                        controller.page = controller.page - 1;
                                        controller.setCorretDataSource();
                                      }
                                    : null),
                            IconButton(
                                iconSize: 36,
                                icon: Icon(Icons.keyboard_arrow_right_rounded),
                                onPressed: controller.page < total
                                    ? () {
                                        controller.page = controller.page + 1;
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
