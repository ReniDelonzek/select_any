import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:select_any/app/models/models.dart';
import 'package:select_any/app/modules/select_any/select_any_controller.dart';
import 'package:select_any/app/widgets/falha/falha_widget.dart';
import 'package:select_any/app/widgets/table_data/table_data_widget.dart';
import 'package:select_any/app/widgets/utils_widget.dart';

class SelectAnyPage extends StatefulWidget {
  /// Retorna Map<String, dynamic>
  static const int TIPO_SELECAO_SIMPLES = 0;

  /// Retorna [ItemSelect]
  static const int TIPO_SELECAO_MULTIPLA = 1;

  static const int TIPO_SELECAO_ACAO = 2;

  final SelectModel _selectModel;
  Map data;

  SelectAnyPage(this._selectModel, {this.data});

  @override
  _SelectAnyPageState createState() {
    return _SelectAnyPageState();
  }
}

class _SelectAnyPageState extends State<SelectAnyPage> {
  SelectAnyController controller;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool loaded = false;

  // indica se está sendo usada a fonte alternativa ou nao
  bool fonteAlternativa = false;
  BuildContext buildContext;

  @override
  void initState() {
    controller = SelectAnyController(
        widget._selectModel.titulo, widget._selectModel, widget.data);
    controller.confirmarParaCarregarDados =
        widget._selectModel.confirmarParaCarregarDados;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!controller.confirmarParaCarregarDados && controller.typeDiplay == 1) {
      carregarDados();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Observer(builder: (_) => controller.appBarTitle),
        actions: _getMenuButtons(),
        leading: Observer(builder: (_) {
          if (controller.typeDiplay == 1) {
            return IconButton(
              icon: controller.searchIcon,
              onPressed: _searchPressed,
            );
          } else {
            return SizedBox();
          }
        }),
      ),
      bottomNavigationBar: widget._selectModel.tipoSelecao ==
              SelectAnyPage.TIPO_SELECAO_MULTIPLA
          ? BottomNavigationBar(
              selectedItemColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              onTap: (pos) {
                if (controller.typeDiplay == 1) {
                  Navigator.pop(
                      context,
                      controller.list
                          .where((item) => item.isSelected)
                          .toList());
                } else {
                  Navigator.pop(
                      context,
                      controller.list
                          .where((item) => item.isSelected)
                          .toList());
                }
              },
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: SizedBox(), label: ''),
                BottomNavigationBarItem(
                    icon: Icon(Icons.done), label: 'Concluído'),
              ],
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: _getFloatingActionButtons(),
        ),
      ),
      body: Builder(builder: (buildContext) {
        this.buildContext = buildContext;
        return _getBody();
      }),
    );
  }

  /// Retorna o conteúdo principal da tela
  Widget _getBody() {
    if (controller.tipoTeladinamica) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (MediaQuery.of(context).size.width > 800) {
          if (controller.typeDiplay != 2) {
            controller.typeDiplay = 2;

            _searchPressed();
          }
        } else {
          if (controller.typeDiplay != 1) {
            carregarDados();
            controller.typeDiplay = 1;
          }
        }
      });
    }
    if (controller.typeDiplay == 2) {
      return TableDataWidget(widget._selectModel, controller: controller);
    } else {
      if (!controller.confirmarParaCarregarDados) {
        return _getStreamBody();
      } else {
        return Center(
            child: TextButton.icon(
                icon: Icon(Icons.sync),
                label: Text('Carregar dados'),
                onPressed: () {
                  /// Aqui é vantagem usar o setState, pois toda a tela precisa ser recarregada
                  setState(() {
                    controller.confirmarParaCarregarDados = false;
                    carregarDados();
                  });
                }));
      }
    }
  }

  Widget _getStreamBody() {
    return _getListBuilder(context);
  }

  Widget _getListBuilder(BuildContext context) {
    return Observer(builder: (_) {
      if (controller.loading == true) {
        return new Center(child: new RefreshProgressIndicator());
      }
      if (controller.error != null) {
        if (widget._selectModel.fonteDadosAlternativa != null &&
            controller.fonteDadoAtual !=
                widget._selectModel.fonteDadosAlternativa) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            //usa esse artefato para nao dar problema com o setstate
            loaded = false;
            carregarDados();
            setState(() async {
              controller.fonteDadoAtual =
                  widget._selectModel.fonteDadosAlternativa;
              controller.setDataSource();
              // controller.streamController.addStream((await controller
              //     .fonteDadoAtual
              //     .getList(-1, 0, widget._selectModel)));
            });
          });
          return new Center(child: new RefreshProgressIndicator());
        }
        return FalhaWidget(
          'Houve uma falha ao recuperar os dados',
          error: controller.error,
        );
      }
      //_gerarLista((snapshot.data as ResponseData).data);
      return Observer(builder: (_) {
        if (controller.listaExibida.isEmpty == true)
          return Center(child: new Text('Nenhum registro encontrado'));
        else
          return RefreshIndicator(
            onRefresh: () async {
              loaded = false;
              carregarDados();
            },
            key: _refreshIndicatorKey,
            child: new ListView.builder(
                itemCount: controller.listaExibida.length,
                itemBuilder: (context, index) {
                  return Observer(
                      builder: (_) =>
                          _getItemList(controller.listaExibida[index]));
                }),
          );
      });
    });
  }

  void _searchPressed() {
    if (controller.searchIcon.icon == Icons.search &&
        controller.typeDiplay == 1) {
      controller.searchIcon = new Icon(Icons.close);
      controller.appBarTitle = Container(
        alignment: Alignment.topRight,
        constraints: BoxConstraints(maxWidth: 300),
        child: TextField(
          autofocus: true,
          controller: controller.filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search), hintText: 'Pesquise...'),
        ),
      );
    } else {
      controller.searchIcon = new Icon(Icons.search);
      controller.appBarTitle = new Text(widget._selectModel.titulo);
      controller.searchText = '';
      controller.filter.clear();
    }
  }

  Widget _getItemList(ItemSelect itemSelect) {
    if (itemSelect.strings.length <= 2) {
      return new Padding(
          padding: EdgeInsets.only(left: 5, right: 5),
          child: ListTile(
            leading: widget._selectModel.tipoSelecao == 1
                ? Checkbox(
                    onChanged: (newValue) {
                      itemSelect.isSelected = newValue;
                    },
                    value: itemSelect.isSelected)
                : null,
            title: _getLinha(
                    itemSelect.strings.entries.first, itemSelect.object) ??
                SizedBox(),
            subtitle: (itemSelect.strings.length > 1)
                ? _getLinha(
                    itemSelect.strings.entries.toList()[1], itemSelect.object)
                : null,
            onTap: () async {
              UtilsWidget.tratarOnTap(
                  context, itemSelect, controller.selectModel, controller.data,
                  () {
                loaded = false;
                carregarDados();
              });
            },
            onLongPress: () {
              UtilsWidget.tratarOnLongPres(
                  context, itemSelect, controller.selectModel, controller.data,
                  () {
                loaded = false;
                carregarDados();
              });
            },
          ));
    } else {
      return Card(
        child: InkWell(
          onTap: () {
            UtilsWidget.tratarOnTap(
                context, itemSelect, controller.selectModel, controller.data,
                () {
              loaded = false;
              carregarDados();
            });
          },
          onLongPress: () {
            UtilsWidget.tratarOnLongPres(
                context, itemSelect, controller.selectModel, controller.data,
                () {
              loaded = false;
              carregarDados();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget._selectModel.tipoSelecao == 1
                ? Row(
                    children: [
                      Checkbox(
                        onChanged: (valor) {},
                        value: itemSelect.isSelected,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            _getTexts(itemSelect.strings, itemSelect.object),
                      )),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _getTexts(itemSelect.strings, itemSelect.object),
                  ),
          ),
        ),
      );
    }
  }

  Widget _getLinha(MapEntry item, Map map) {
    Linha linha = widget._selectModel.linhas
        .firstWhere((linha) => linha.chave == item.key, orElse: () => null);
    if (linha == null) {
      return null;
    }
    String valor = (item.value == null || item.value.toString().isEmpty)
        ? (linha.valorPadrao != null ? linha.valorPadrao(map) : '')
        : item.value?.toString();
    if (linha.formatacaoDados != null) {
      valor = linha.formatacaoDados.dadosFormatados(valor);
    }
    if (linha != null &&
        (linha.involucro != null || linha.personalizacao != null)) {
      if (linha.personalizacao != null) {
        return linha.personalizacao(map);
      }
      return Text(linha.involucro.replaceAll('???', valor),
          style: linha.estiloTexto);
    } else {
      return Text(valor, style: linha.estiloTexto);
    }
  }

  List<Widget> _getTexts(Map<String, dynamic> map, Map object) {
    List<Widget> widgets = [];
    for (var item in map.entries) {
      Widget widget = _getLinha(item, object);
      if (widget != null) {
        widgets.add(widget);
      }
    }
    return widgets;
  }

  List<ItemSelect> _gerarLista(List<ItemSelectTable> data) {
    controller.list.clear();
    controller.list.addAll(data);
    return data;
  }

  List<Widget> _getMenuButtons() {
    if ((!kIsWeb) && !Platform.isAndroid) {
      return <Widget>[
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ];
    } else
      return <Widget>[];
  }

  List<Widget> _getFloatingActionButtons() {
    List<Widget> widgets = [];
    // if (!(widget._selectModel.filtros?.isEmpty ?? true)) {
    //   widgets.add(FloatingActionButton(
    //       heroTag: widgets.length,
    //       onPressed: () async {
    //         Map<String, List<String>> s = await Navigator.of(context).push(
    //             new MaterialPageRoute(
    //                 builder: (BuildContext context) =>
    //                     new FiltroPage(widget._selectModel.filtros)));
    //         if (widget.data == null) {
    //           widget.data = Map();
    //         }
    //         widget.data['filtros'] = s;
    //       },
    //       mini: (!(widget._selectModel.acoes?.isEmpty ?? true)),
    //       child: Icon(Icons.filter_list)));
    // }
    if (!(widget._selectModel.botoes?.isEmpty ?? true)) {
      for (Acao acao in widget._selectModel.botoes) {
        widgets.add(FloatingActionButton(
          heroTag: widgets.length,
          mini: widgets.isNotEmpty,
          tooltip: acao.descricao,
          onPressed: () {
            UtilsWidget.onAction(context, null, acao, widget.data, () {
              loaded = false;
              carregarDados();
            });
          },
          child: acao.icon ?? Icon(Icons.add),
        ));
      }
    }
    widgets = widgets.reversed.toList();
    return widgets;
  }

  void carregarDados() async {
    if (controller.typeDiplay == 1 && !loaded) {
      final Map args = ModalRoute.of(context).settings.arguments;
      if (args?.containsKey('data') ?? false) {
        if (widget.data == null) {
          widget.data = Map();
        }
        widget.data.addAll(args['data']);
      }
      controller.fonteDadoAtual = widget._selectModel.fonteDados;
      controller.setDataSource();
      // controller.streamController.addStream((await controller.fonteDadoAtual
      //     .getList(-1, 0, widget._selectModel)));
      loaded = true;
    }
    if (widget._selectModel.abrirPesquisaAutomaticamente == true) {
      _searchPressed();
    }
  }
}
