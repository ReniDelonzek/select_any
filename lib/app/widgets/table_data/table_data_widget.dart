import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:msk_utils/utils/utils_hive.dart';
import 'package:select_any/app/models/models.dart';
import 'package:select_any/app/modules/select_any/select_any_controller.dart';
import 'package:select_any/app/modules/select_any/select_any_page.dart';
import 'package:select_any/app/widgets/falha/falha_widget.dart';
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
    List<Widget> botoes = [];
    if (controller.selectModel.botoes != null) {
      botoes.addAll(controller.selectModel.botoes
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
    return SingleChildScrollView(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: botoes),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: 300,
                                child: TextField(
                                  decoration:
                                      InputDecoration(hintText: 'Pesquisar'),
                                  controller: controller.filter,
                                  onChanged: (text) {
                                    controller.filtroPesquisaModificado();
                                  },
                                )),
                            Icon(Icons.search),

                            /// fonteDadoAtual pode ser null caso o carregarDados seja false
                            if (controller.fonteDadoAtual?.allowExport == true)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 8),
                                  IconButton(
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

              if (subList.isEmpty) {
                return Center(
                    child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Nenhum item encontrado'),
                ));
              }

              List<DataRow> rows = [];
              int i = 0;
              for (var element in subList) {
                rows.add(UtilsWidget.generateDataRow(
                    controller.selectModel,
                    i,
                    element,
                    context,
                    controller.data, (ItemSelect itemSelect, bool b) {
                  if (controller.selectModel.tipoSelecao ==
                      SelectAnyPage.TIPO_SELECAO_SIMPLES) {
                    if (Navigator?.maybeOf(context)?.canPop() == true) {
                      Navigator?.maybeOf(context)?.pop(itemSelect.object);
                    }
                  }
                  if (controller.selectModel.tipoSelecao ==
                      SelectAnyPage.TIPO_SELECAO_ACAO) {
                    /// Gambi para evitar problemas ao usuário clicar em selecionar todos
                    if ((controller.lastClick + 1000) <
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
                    //UtilsWidget.exibirListaAcoes()
                  } else {
                    if (b) {
                      controller.selectedList.add(itemSelect);
                    } else {
                      controller.selectedList.removeWhere(
                          (element) => element.id == itemSelect.id);
                    }
                    itemSelect.isSelected = b;
                  }
                }, controller.reloadData, 2, controller.fonteDadoAtual));
                i++;
              }

              return LayoutBuilder(builder: (context, constraint) {
                return Scrollbar(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints:
                            BoxConstraints(minWidth: constraint.maxWidth),
                        child: DataTable(
                            headingRowColor:
                                MaterialStateColor.resolveWith((states) {
                              return Color(0xFF00823A);
                            }),
                            columns: UtilsWidget.generateDataColumn(
                                controller.selectModel),
                            rows: rows),
                      )),
                );
              });
              //   return SingleChildScrollView(
              //     scrollDirection: Axis.horizontal,
              //     child: DataTable(
              //         columns: UtilsWidget.generateDataColumn(
              //             controller.selectModel),
              //         rows: rows),
              //   );
              // }
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
                                                      controller
                                                          .quantityItensPage)
                                                  .ceil() <
                                              controller.page) {
                                            /// Seta a ultima pagina como pagina atual
                                            controller.page =
                                                ((controller.total ?? 0) /
                                                        controller
                                                            .quantityItensPage)
                                                    .ceil();
                                          }
                                          if (controller.filter.text.isEmpty) {
                                            controller.setDataSource();
                                          } else {
                                            controller.setDataSourceSearch();
                                          }

                                          /// Salva isso no banco
                                          UtilsHive.getInstance()
                                              .getBox('select_utils')
                                              .then((value) {
                                            value.put(
                                                'quantityItensPage', item);
                                          });
                                        },
                                        items: [
                                          DropdownMenuItem(
                                              value: 10, child: Text('10')),
                                          DropdownMenuItem(
                                              value: 15, child: Text('15')),
                                          DropdownMenuItem(
                                              value: 20, child: Text('20'))
                                        ]),
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
                                        if (controller.filter.text.isEmpty) {
                                          controller.setDataSource();
                                        } else {
                                          controller.setDataSourceSearch();
                                        }
                                      },
                                      items:
                                          List<DropdownMenuItem<int>>.generate(
                                              total,
                                              (index) => DropdownMenuItem(
                                                  value: index + 1,
                                                  child: Text(
                                                      (index + 1).toString()))))
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
                                    icon:
                                        Icon(Icons.keyboard_arrow_left_rounded),
                                    onPressed: controller.page > 1
                                        ? () {
                                            controller.page =
                                                controller.page - 1;
                                            if (controller
                                                .filter.text.isEmpty) {
                                              controller.setDataSource();
                                            } else {
                                              controller.setDataSourceSearch();
                                            }
                                          }
                                        : null),
                                IconButton(
                                    iconSize: 36,
                                    icon: Icon(
                                        Icons.keyboard_arrow_right_rounded),
                                    onPressed: controller.page < total
                                        ? () {
                                            controller.page =
                                                controller.page + 1;
                                            if (controller
                                                .filter.text.isEmpty) {
                                              controller.setDataSource();
                                            } else {
                                              controller.setDataSourceSearch();
                                            }
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
        ),
      ),
    );
  }
}
