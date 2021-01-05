import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:msk_utils/utils/utils_platform.dart';
import 'package:select_any/app/models/models.dart';
import 'package:select_any/app/modules/select_any/select_any_controller.dart';
import 'package:select_any/app/widgets/falha/falha_widget.dart';
import 'package:select_any/app/widgets/table_data/table_data_controller.dart';
import 'package:select_any/app/widgets/table_data/table_data_widget.dart';

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
    return _SelectAnyPageState(_selectModel.titulo);
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

  _SelectAnyPageState(String title) {
    controller = SelectAnyController(title);
  }

  @override
  void initState() {
    controller.confirmarParaCarregarDados =
        widget._selectModel.confirmarParaCarregarDados;
    super.initState();
  }

  @override
  void dispose() {
    //widget._selectModel.fonteDados.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!controller.confirmarParaCarregarDados) {
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
                      controller.listaOriginal
                          .where((item) => item.isSelected)
                          .toList());
                } else {
                  Navigator.pop(
                      context,
                      controller.listaOriginal
                          .where((item) => item.isSelected)
                          .toList());
                }
              },
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.done), title: Text('Concluído')),
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
    if (!UtilsPlatform.isMobile() &&
        MediaQuery.of(buildContext).size.width > 800) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.typeDiplay = 2;
      });
      return TableDataWidget(widget._selectModel,
          controller: controller.tableController);
    } else {
      if (controller.typeDiplay != 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.typeDiplay = 1;
          loaded = false;
          carregarDados();
        });
      }

      if (!controller.confirmarParaCarregarDados) {
        return _getStreamBody();
      } else {
        return Center(
            child: FlatButton.icon(
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
    return Observer(
      builder: (_) => StreamBuilder(
        stream: controller.stream,
        builder: (_, AsyncSnapshot snap) {
          return _getListBuilder(context, snap);
        },
      ),
    );
  }

  Widget _getListBuilder(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return new Center(child: new RefreshProgressIndicator());
      case ConnectionState.none:
        return new Center(child: new RefreshProgressIndicator());
      default:
        if (snapshot.hasError) {
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
                controller.stream = await controller.fonteDadoAtual
                    .getList(-1, 0, widget._selectModel);

                // await controller.fonteDadoAtual
                //     .getMapStream(data: widget.data);
              });
            });
            return new Center(child: new RefreshProgressIndicator());
          }
          return FalhaWidget(
            'Houve uma falha ao recuperar os dados',
            error: snapshot.error,
          );
        }
        if (snapshot.data == null) {
          return new Center(child: new RefreshProgressIndicator());
        }
        _gerarLista((snapshot.data as ResponseData).data);
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
    }
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
      controller.listaExibida.clear();
      controller.listaExibida.addAll(controller.listaOriginal);
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
              _tratarOnTap(itemSelect);
            },
            onLongPress: () {
              _tratarOnLongPres(itemSelect);
            },
          ));
    } else {
      return Card(
        child: InkWell(
          onTap: () {
            _tratarOnTap(itemSelect);
          },
          onLongPress: () {
            _tratarOnLongPres(itemSelect);
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
    controller.listaOriginal.clear();
    controller.listaExibida.clear();
    controller.listaOriginal.addAll(data);
    controller.listaExibida.addAll(data);
    return data;
  }

  void _onAction(ItemSelect itemSelect, Acao acao) async {
    if (acao.funcao != null) {
      if (acao.fecharTela) {
        Navigator.pop(context);
      }
      acao.funcao(data: itemSelect);
    }
    if (acao.funcaoAtt != null) {
      if (acao.fecharTela) {
        Navigator.pop(context);
      }

      var res = await acao.funcaoAtt(data: itemSelect, context: buildContext);
      if (res == true) {
        loaded = false;
        carregarDados();
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

  void _tratarOnLongPres(ItemSelect itemSelect) {
    if (widget._selectModel.acoes != null) {
      if (widget._selectModel.acoes.length > 1) {
        _exibirListaAcoes(itemSelect);
      } else {
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
    } else {
      //case seja do tipo acao, mas n tenha nenhuma acao
      Navigator.pop(context, itemSelect.object);
    }
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
      controller.stream =
          await controller.fonteDadoAtual.getList(-1, 0, widget._selectModel);
      loaded = true;
    }
    if (widget._selectModel.abrirPesquisaAutomaticamente == true) {
      _searchPressed();
    }
  }
}
