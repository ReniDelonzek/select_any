import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:select_any/app/models/models.dart';
import 'package:select_any/app/modules/select_any/select_any_page.dart';
import 'package:select_any/app/modules/select_any_expanded/select_any_expanded_controller.dart';

// ignore: must_be_immutable
class SelectAnyExpandedPage extends StatefulWidget {
  final SelectModel _selectModel;
  final ObservableList<ItemSelectExpanded> itens;
  Map data;

  SelectAnyExpandedPage(this._selectModel, this.itens, {this.data});

  @override
  _SelectAnyExpandedPageState createState() {
    return _SelectAnyExpandedPageState(_selectModel.titulo, itens);
  }
}

class _SelectAnyExpandedPageState extends State<SelectAnyExpandedPage> {
  SelectAnyExpandedController controller;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool loaded = false;

  // indica se está sendo usada a fonte alternativa ou nao
  bool fonteAlternativa = false;
  BuildContext buildContext;

  _SelectAnyExpandedPageState(
      String title, ObservableList<ItemSelectExpanded> itens) {
    controller = SelectAnyExpandedController(title, itens);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //widget._selectModel.fonteDados.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Observer(builder: (_) => controller.appBarTitle),
      ),
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
    if (controller.listaExibida.isEmpty == true)
      return Center(child: new Text('Nenhum registro encontrado'));
    else
      return RefreshIndicator(
        onRefresh: () async {},
        key: _refreshIndicatorKey,
        child: new ListView.builder(
            itemCount: controller.listaExibida.length,
            itemBuilder: (context, index) {
              return Observer(
                  builder: (_) => _getItemList(controller.listaExibida[index]));
            }),
      );
  }

  Widget _getItemList(ItemSelectExpanded itemSelect) {
    return Card(
      child: InkWell(
        onTap: () {
          if (itemSelect.items?.isNotEmpty != true) {
            _tratarOnTap(itemSelect);
          } else {
            itemSelect.isExpanded = !itemSelect.isExpanded;
          }
        },
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _getTexts(itemSelect.strings, itemSelect.object),
                    )),
                    if (itemSelect.items?.isNotEmpty == true)
                      IconButton(
                          icon: Icon(Icons.expand_more),
                          onPressed: () {
                            itemSelect.isExpanded = !itemSelect.isExpanded;
                          })
                  ],
                ),
                Observer(builder: (_) {
                  if (itemSelect.isExpanded) {
                    return Column(
                        children: itemSelect.items
                            .map((element) => _getItemList(element))
                            .toList());
                  } else {
                    return SizedBox();
                  }
                })
              ],
            )),
      ),
    );
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
        return linha.personalizacao(CustomLineData(data: map));
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

  void _onAction(ItemSelect itemSelect, Acao acao) async {
    if (acao.funcao != null) {
      if (acao.fecharTela) {
        Navigator.pop(context);
      }
      acao.funcao(DataFunction(data: itemSelect, context: context));
    }
    if (acao.funcaoAtt != null) {
      if (acao.fecharTela) {
        Navigator.pop(context);
      }

      var res = await acao.funcaoAtt(data: itemSelect, context: buildContext);
      if (res == true) {
        loaded = false;
      }
    } else if (acao.route != null || acao.page != null) {
      Map<String, dynamic> dados = Map();
      if (acao.chaves?.entries != null) {
        for (MapEntry dado in acao.chaves.entries) {
          if (itemSelect != null &&
              (itemSelect.object as Map).containsKey(dado.key)) {
            dados.addAll({dado.value: itemSelect.object[dado.key]});
          } else if (widget.data.containsKey(dado.key)) {
            dados.addAll({dado.value: widget.data[dado.key]});
          }
        }
      }

      RouteSettings settings = (itemSelect != null || dados.isNotEmpty)
          ? RouteSettings(arguments: {
              'cod_obj': itemSelect?.id,
              'obj': itemSelect?.object,
              'data': dados,
              //'fromServer': fromServer
            })

          ///TODO resolver isso ..addAll({'fromServer': controller.fonteDadoAtual.url != null})
          : RouteSettings();

      var res = await Navigator.of(context).push(acao.route != null
          ? acao.route
          : new MaterialPageRoute(
              builder: (_) => acao.page, settings: settings));
      if (acao.fecharTela) {
        if (res != null) {
          if (res is Map &&
              res['dados'] != null &&
              res['dados'] is Map &&
              res['dados'].isNotEmpty) {
            Navigator.pop(context, res['dados']);
          }
          if (res is Map &&
              res['data'] != null &&
              res['data'] is Map &&
              res['data'].isNotEmpty) {
            Navigator.pop(context, res['data']);
          } else {
            Navigator.pop(context, res);
          }
        }
      }
    }
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
            _onAction(null, acao);
          },
          child: acao.icon ?? Icon(Icons.add),
        ));
      }
    }
    widgets = widgets.reversed.toList();
    return widgets;
  }

  void _exibirListaAcoes(ItemSelect itemSelect) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: widget._selectModel.acoes
                  .map((acao) => new ListTile(
                      title: new Text(acao.descricao),
                      onTap: () {
                        Navigator.pop(context);
                        _onAction(itemSelect, acao);
                      }))
                  .toList(),
            ),
          );
        });
  }

  void _tratarOnTap(ItemSelect itemSelect) {
    if (widget._selectModel.tipoSelecao == SelectAnyPage.TIPO_SELECAO_ACAO &&
        widget._selectModel.acoes != null) {
      if (widget._selectModel.acoes.length > 1) {
        _exibirListaAcoes(itemSelect);
      } else if (widget._selectModel.acoes.isNotEmpty) {
        Acao acao = widget._selectModel.acoes?.first;
        if (acao != null) {
          _onAction(itemSelect, acao);
        }
      }
    } else if (widget._selectModel.tipoSelecao ==
        SelectAnyPage.TIPO_SELECAO_SIMPLES) {
      Navigator.pop(context, itemSelect.object);
    } else if (widget._selectModel.tipoSelecao ==
        SelectAnyPage.TIPO_SELECAO_MULTIPLA) {
      itemSelect.isSelected = !itemSelect.isSelected;
    }
  }
}
