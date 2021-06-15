import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:msk_utils/utils/utils_platform.dart';
import 'package:select_any/app/models/models.dart';
import 'package:select_any/app/modules/select_any/select_any_controller.dart';
import 'package:select_any/app/widgets/falha/falha_widget.dart';
import 'package:select_any/app/widgets/table_data/table_data_widget.dart';
import 'package:select_any/app/widgets/utils_widget.dart';
import 'package:msk_utils/extensions/date.dart';

class InsertIntent extends Intent {
  const InsertIntent();
}

class SearchIntent extends Intent {
  const SearchIntent();
}

class ExportIntent extends Intent {
  const ExportIntent();
}

class DoneIntent extends Intent {
  const DoneIntent();
}

// ignore: must_be_immutable
class SelectAnyPage extends StatefulWidget {
  /// Retorna Map<String, dynamic>
  static const int TIPO_SELECAO_SIMPLES = 0;

  /// Retorna [ItemSelect]
  static const int TIPO_SELECAO_MULTIPLA = 1;

  static const int TIPO_SELECAO_ACAO = 2;

  final SelectModel _selectModel;
  Map data;
  SelectAnyController controller;
  final bool showBackButton;

  SelectAnyPage(this._selectModel,
      {this.data, this.controller, this.showBackButton = true}) {
    if (controller == null) {
      controller = SelectAnyController();
    }
    controller.init(_selectModel.titulo, _selectModel, data);
    controller.confirmarParaCarregarDados =
        _selectModel.confirmarParaCarregarDados;
    controller.typeDiplay = UtilsPlatform.isMobile ? 1 : 2;
  }

  @override
  _SelectAnyPageState createState() {
    return _SelectAnyPageState();
  }
}

class _SelectAnyPageState extends State<SelectAnyPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  // indica se está sendo usada a fonte alternativa ou nao
  bool fonteAlternativa = false;
  BuildContext buildContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.tipoTeladinamica) {
      //WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (MediaQuery.of(context).size.width > 800) {
        if (widget.controller.typeDiplay != 2) {
          widget.controller.typeDiplay = 2;
          _searchPressed();
        }
      } else {
        if (widget.controller.typeDiplay != 1) {
          widget.controller.typeDiplay = 1;
          if (!(widget.controller.fonteDadoAtual?.supportPaginate ?? false) &&
              widget.controller.loaded) {
            /// Caso a fonte nao suporte paginação, recarrega os dados
            /// Pois os dados carregados na tabela não são completos
            widget.controller.setCorretDataSource(offset: -1);
          }
        }
      }
      //});
    }
    if (!widget.controller.confirmarParaCarregarDados) {
      carregarDados();
    }
    return Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyI):
              const InsertIntent(),
          LogicalKeySet(LogicalKeyboardKey.insert): const InsertIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
              const SearchIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyL):
              const SearchIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyD):
              const ExportIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
              const DoneIntent()
        },
        child: Actions(
            actions: <Type, Action<Intent>>{
              DismissIntent: CallbackAction<DismissIntent>(
                  onInvoke: (DismissIntent intent) {
                Navigator.pop(context);
                return;
              }),
              InsertIntent:
                  CallbackAction<InsertIntent>(onInvoke: (InsertIntent intent) {
                if (widget._selectModel.botoes?.isNotEmpty == true) {
                  UtilsWidget.onAction(
                      context,
                      null,
                      null,
                      widget._selectModel.botoes.first,
                      widget.data,
                      widget.controller.reloadData,
                      widget.controller.fonteDadoAtual);
                }
                return;
              }),
              SearchIntent:
                  CallbackAction<SearchIntent>(onInvoke: (SearchIntent intent) {
                if (widget.controller.typeDiplay == 1) {
                  _searchPressed();
                }
                widget.controller.focusNodeSearch.requestFocus();

                return;
              }),
              ExportIntent:
                  CallbackAction<ExportIntent>(onInvoke: (ExportIntent intent) {
                if (widget.controller.fonteDadoAtual?.allowExport == true) {
                  widget.controller.export();
                }
                return;
              }),
              DoneIntent:
                  CallbackAction<DoneIntent>(onInvoke: (DoneIntent intent) {
                onDone();
                return;
              })
            },
            child: Focus(
                autofocus: true,
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: widget
                        .controller.selectModel.theme?.appBarBackgroundColor,
                    centerTitle:
                        widget.controller.selectModel.theme?.centerTitle,
                    title:
                        Observer(builder: (_) => widget.controller.appBarTitle),
                    actions: [
                      Observer(builder: (_) {
                        if (widget.controller.typeDiplay == 1) {
                          return Row(children: [
                            IconButton(
                                onPressed: () {
                                  showDialogSorts(context);
                                },
                                icon: Icon(Icons.sort)),
                            IconButton(
                              icon: widget.controller.searchIcon,
                              onPressed: _searchPressed,
                            )
                          ]);
                        } else {
                          return Row(children: _buildIconButtons());
                        }
                      })
                    ],
                    automaticallyImplyLeading: false,
                    leading: _getMenuButton(),
                  ),
                  bottomNavigationBar: widget._selectModel.tipoSelecao ==
                          SelectAnyPage.TIPO_SELECAO_MULTIPLA
                      ? BottomNavigationBar(
                          selectedItemColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                          onTap: (pos) {
                            onDone();
                          },
                          items: <BottomNavigationBarItem>[
                            BottomNavigationBarItem(
                                icon: SizedBox(), label: ''),
                            BottomNavigationBarItem(
                                icon: Icon(Icons.done), label: 'Concluído'),
                          ],
                        )
                      : null,
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.endDocked,
                  floatingActionButton: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Observer(
                      builder: (_) => (widget.controller.typeDiplay == 2)
                          ? SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: _getFloatingActionButtons(),
                            ),
                    ),
                  ),
                  backgroundColor:
                      widget.controller.selectModel.theme?.backgroundColor,
                  body: Builder(builder: (buildContext) {
                    this.buildContext = buildContext;
                    return _getBody();
                  }),
                ))));
  }

  void onDone() {
    if (widget.controller.typeDiplay == 1) {
      Navigator.pop(context,
          widget.controller.list.where((item) => item.isSelected).toList());
    } else {
      Navigator.pop(context,
          widget.controller.list.where((item) => item.isSelected).toList());
    }
  }

  List<Widget> _buildIconButtons() {
    List<Widget> buttons = [];
    if (widget.controller.selectModel.botoes != null &&
        widget.controller.selectModel.theme?.buttonsPosition ==
            ButtonsPosition.APPBAR) {
      buttons.addAll(widget.controller.selectModel.botoes
          .map((e) => IconButton(
                icon: e.icon ?? Icon(Icons.add),
                tooltip: e.descricao,
                onPressed: () {
                  UtilsWidget.onAction(
                      context,
                      null,
                      null,
                      e,
                      widget.controller.data,
                      widget.controller.reloadData,
                      widget.controller.fonteDadoAtual);
                },
              ))
          .toList());
    }
    return buttons;
  }

  /// Retorna o conteúdo principal da tela
  Widget _getBody() {
    return Observer(builder: (_) {
      if (widget.controller.typeDiplay == 2) {
        return TableDataWidget(widget._selectModel,
            controller: widget.controller, carregarDados: false);
      } else {
        if (!widget.controller.confirmarParaCarregarDados) {
          return _getStreamBody();
        } else {
          return Center(
              child: TextButton.icon(
                  icon: Icon(Icons.sync),
                  label: Text('Carregar dados'),
                  onPressed: () {
                    /// Aqui é vantagem usar o setState, pois toda a tela precisa ser recarregada
                    setState(() {
                      widget.controller.confirmarParaCarregarDados = false;
                      carregarDados();
                    });
                  }));
        }
      }
    });
  }

  Widget _getStreamBody() {
    return _getListBuilder(context);
  }

  Widget _getListBuilder(BuildContext context) {
    return Observer(builder: (_) {
      if (widget.controller.loading == true) {
        return new Center(child: new RefreshProgressIndicator());
      }
      if (widget.controller.error != null) {
        if (widget._selectModel.fonteDadosAlternativa != null &&
            widget.controller.fonteDadoAtual !=
                widget._selectModel.fonteDadosAlternativa) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            //usa esse artefato para nao dar problema com o setstate
            widget.controller.loaded = false;

            setState(() async {
              widget.controller.fonteDadoAtual =
                  widget._selectModel.fonteDadosAlternativa;
              widget.controller.setDataSource(
                  offset: widget.controller.typeDiplay == 1 ? -1 : 0);
              carregarDados();
            });
          });
          return new Center(child: new RefreshProgressIndicator());
        }
        return FalhaWidget(
          'Houve uma falha ao recuperar os dados',
          error: widget.controller.error,
        );
      }
      //_gerarLista((snapshot.data as ResponseData).data);
      return Observer(builder: (_) {
        if (widget.controller.listaExibida.isEmpty == true)
          return Center(child: new Text('Nenhum registro encontrado'));
        else {
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    widget.controller.reloadData();
                  },
                  key: _refreshIndicatorKey,
                  child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        /// não é necessário nenhuma ação caso não suporte paginação, pois os dados já estaram completos na tela
                        if (widget.controller.fonteDadoAtual.supportPaginate) {
                          if (scrollInfo is ScrollEndNotification &&
                              scrollInfo.metrics.extentAfter == 0) {
                            if (widget.controller.total == 0 ||
                                widget.controller.page *
                                        widget.controller.quantityItensPage <=
                                    widget.controller.total) {
                              if (widget.controller.searchText.isEmpty) {
                                widget.controller.loadingMore = true;
                                widget.controller.page++;
                                widget.controller.setDataSource();
                              } else {
                                widget.controller.loadingMore = true;
                                widget.controller.page++;
                                widget.controller.setDataSourceSearch();
                              }
                              print('Carregar mais dados');
                            } else {
                              widget.controller.loadingMore = false;
                              print('Não carregar mais');
                              print(widget.controller.list.length);
                            }
                          }
                        }
                        return true;
                      },
                      child: ListView.builder(
                          itemCount: widget.controller.listaExibida.length,
                          itemBuilder: (context, index) {
                            return Observer(
                                builder: (_) => _getItemList(
                                    widget.controller.listaExibida[index],
                                    index));
                          })),
                ),
              ),
              Observer(builder: (_) {
                if (widget.controller.loadingMore) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  );
                }
                return SizedBox();
              }),
            ],
          );
        }
      });
    });
  }

  void _searchPressed() {
    if (widget.controller.searchIcon.icon == Icons.search &&
        widget.controller.typeDiplay == 1) {
      widget.controller.searchIcon = new Icon(Icons.close);
      widget.controller.appBarTitle = Container(
        alignment: Alignment.topRight,
        constraints: BoxConstraints(maxWidth: 300),
        child: TextField(
          focusNode: widget.controller.focusNodeSearch..requestFocus(),
          controller: widget.controller.filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search), hintText: 'Pesquise...'),
          onChanged: (text) {
            widget.controller.filtroPesquisaModificado();
          },
        ),
      );
    } else {
      widget.controller.searchIcon = new Icon(Icons.search);
      widget.controller.appBarTitle = new Text(widget._selectModel.titulo);
      if (widget.controller.filter.text.isNotEmpty) {
        widget.controller.searchText = '';
        widget.controller.filter.clear();
        widget.controller.filtroPesquisaModificado(reload: true);
      }
    }
  }

  Widget _getItemList(ItemSelect itemSelect, int index) {
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
                  context,
                  itemSelect,
                  index,
                  widget.controller.selectModel,
                  widget.controller.data,
                  widget.controller.reloadData,
                  widget.controller.fonteDadoAtual);
            },
            onLongPress: () {
              UtilsWidget.tratarOnLongPres(
                  context,
                  itemSelect,
                  index,
                  widget.controller.selectModel,
                  widget.controller.data,
                  widget.controller.reloadData,
                  widget.controller.fonteDadoAtual);
            },
          ));
    } else {
      return Card(
        child: InkWell(
          onTap: () {
            UtilsWidget.tratarOnTap(
                context,
                itemSelect,
                index,
                widget.controller.selectModel,
                widget.controller.data,
                widget.controller.reloadData,
                widget.controller.fonteDadoAtual);
          },
          onLongPress: () {
            UtilsWidget.tratarOnLongPres(
                context,
                itemSelect,
                index,
                widget.controller.selectModel,
                widget.controller.data,
                widget.controller.reloadData,
                widget.controller.fonteDadoAtual);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget._selectModel.tipoSelecao == 1
                ? Row(
                    children: [
                      Checkbox(
                        onChanged: (valor) {
                          itemSelect.isSelected = valor;
                        },
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
    dynamic valor = (item.value == null || item.value.toString().isEmpty)
        ? (linha.valorPadrao != null ? linha.valorPadrao(map) : item.value)
        : item.value;

    if (linha.formatData != null) {
      valor = linha.formatData.formatData(ObjFormatData(data: valor));
    } else if (linha.typeData is TDDateTimestamp &&
        linha.personalizacao == null) {
      try {
        valor = DateTime.fromMillisecondsSinceEpoch(int.tryParse(valor))
            .string((linha.typeData as TDDateTimestamp).outputFormat);
        if (linha.involucro == null) {
          linha.involucro = '${linha.nome}: ???';
        }
      } catch (_) {}
    }

    if ((linha.involucro != null || linha.personalizacao != null)) {
      if (linha.personalizacao != null) {
        return linha.personalizacao(CustomLineData(
            data: map, typeScreen: widget.controller.typeDiplay));
      }
      return Text(linha.involucro.replaceAll('???', valor ?? ''),
          style: linha.estiloTexto);
    } else {
      if ((valor == null || valor.toString().isEmpty) &&
          linha.showSizedBoxWhenEmpty == true) {
        return SizedBox();
      }
      return Text(valor?.toString(), style: linha.estiloTexto);
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

  Widget _getMenuButton() {
    if (widget.showBackButton && (!kIsWeb) && !Platform.isAndroid) {
      return IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
    } else
      return null;
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
            UtilsWidget.onAction(context, null, null, acao, widget.data,
                widget.controller.reloadData, widget.controller.fonteDadoAtual);
          },
          child: acao.icon ?? Icon(Icons.add),
        ));
      }
    }
    widgets = widgets.reversed.toList();
    return widgets;
  }

  void carregarDados() async {
    if (!widget.controller.loaded) {
      final Map args = ModalRoute.of(context).settings.arguments;
      if (args?.containsKey('data') ?? false) {
        if (widget.data == null) {
          widget.data = Map();
        }
        widget.data.addAll(args['data']);
      }
      widget.controller.data = widget.data;
      widget.controller.fonteDadoAtual = widget._selectModel.fonteDados;
      widget.controller
          .setDataSource(offset: widget.controller.typeDiplay == 1 ? -1 : 0);
      widget.controller.loaded = true;
    }
    if (widget._selectModel.abrirPesquisaAutomaticamente == true) {
      _searchPressed();
    }
  }

  void showDialogSorts(BuildContext context) {
    showDialog(
        context: context,
        builder: (alertContext) => AlertDialog(
              title: Text('Ordenar por'),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.controller.selectModel.linhas
                      .map((e) => ListTile(
                            onTap: () {
                              EnumTypeSort typeSort = EnumTypeSort.ASC;
                              if (widget.controller.itemSort != null &&
                                  widget.controller.itemSort.linha.chave ==
                                      e.chave) {
                                if (widget.controller.itemSort.typeSort ==
                                    EnumTypeSort.ASC) {
                                  typeSort = EnumTypeSort.DESC;
                                }
                              }
                              widget.controller.itemSort = ItemSort(
                                  indexLine: widget
                                      .controller.selectModel.linhas
                                      .indexWhere((element) =>
                                          element.chave == e.chave),
                                  linha: e,
                                  typeSort: typeSort);

                              widget.controller.updateSortCollumn();
                              Navigator.pop(alertContext);
                            },
                            title: Text(e.nome ?? e.chave),
                            leading: widget.controller.itemSort?.linha?.chave ==
                                    e.chave
                                ? (widget.controller.itemSort.typeSort ==
                                        EnumTypeSort.ASC
                                    ? Icon(Icons.arrow_upward)
                                    : Icon(Icons.arrow_downward))
                                : null,
                          ))
                      .toList()),
            ));
  }
}
