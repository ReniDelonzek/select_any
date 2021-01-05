import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:select_any/app/models/models.dart';
import 'package:select_any/app/widgets/falha/falha_widget.dart';

import 'table_data_controller.dart';

class TableDataWidget extends StatelessWidget {
  final TableDataController controller;

  final int quantityItems;

  TableDataWidget(SelectModel selectModel,
      {Key key, @required this.controller, this.quantityItems = 10})
      : super(key: key) {
    controller.selectModel = selectModel;
    if (selectModel.preSelected != null) {
      controller.selectedList = selectModel.preSelected.toSet();
    }
    controller.setDataSource();
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
                  if (e.funcao != null) {
                    e.funcao();
                  }
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
                                  controller: controller.ctlSearch,
                                  onChanged: (text) {
                                    String text =
                                        controller.ctlSearch.text.trim();
                                    if (text.isEmpty) {
                                      controller.list.clear();
                                      controller.page = 1;
                                      controller.setDataSource();
                                    } else {
                                      Future.delayed(
                                          Duration(
                                              milliseconds: controller
                                                      .selectModel
                                                      .fonteDados
                                                      .searchDelay ??
                                                  300), () {
                                        /// Só executa a pesquisa se o input não tiver mudado
                                        if (text ==
                                            controller.ctlSearch.text.trim()) {
                                          controller.list.clear();
                                          controller.page = 1;
                                          controller.setDataSourceSearch();
                                        }
                                      });
                                    }
                                  },
                                )),
                            Icon(Icons.search),
                          ],
                        )),
                  ),
                ],
              ),
            ),
            Observer(builder: (_) {
              /// Codigo para armazenar em variáveis partes do conteúdo
              if (controller.loading) {
                return Center(child: CircularProgressIndicator());
              }
              if (controller.error != null) {
                return FalhaWidget('Houve uma falha ao carregar os dados',
                    error: controller.error);
              }
              int start = (controller.page - 1).abs() * 10;
              int end = controller.page * 10;

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

              /// Deixa dentro de uma row para deixar como largura máxima
              /// Verificar aborgagens mais eficientes
              return Row(
                children: [
                  Expanded(
                    child: DataTable(
                        columns: controller.generateDataColumn(),
                        rows: subList
                            .map((element) =>
                                controller.generateDataRow(element, context))
                            .toList()),
                  ),
                ],
              );
            }),
            Container(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Observer(builder: (_) {
                    int total =
                        ((controller.total ?? 0) / quantityItems).ceil();
                    return Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              total > 0
                                  ? DropdownButton<int>(
                                      underline: SizedBox(),
                                      value: controller.page,
                                      onChanged: (item) {
                                        controller.page = item;
                                        if (controller.ctlSearch.text.isEmpty) {
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
                                  'de ${((controller.total ?? 0) / quantityItems).ceil()}'),
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
                                                .ctlSearch.text.isEmpty) {
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
                                                .ctlSearch.text.isEmpty) {
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
