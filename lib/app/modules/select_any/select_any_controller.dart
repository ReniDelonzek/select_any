import 'package:diacritic/diacritic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:msk_utils/utils/utils_hive.dart';
import 'package:msk_utils/utils/utils_platform.dart';
import 'package:msk_utils/utils/utils_sentry.dart';

import 'package:select_any/app/models/models.dart';
import 'package:select_any/app/widgets/selecionar_range_data/selecionar_range_data_widget.dart';

part 'select_any_controller.g.dart';

class SelectAnyController = _SelectAnyBase with _$SelectAnyController;

abstract class _SelectAnyBase with Store {
  final TextEditingController filter = new TextEditingController();
  @observable

  /// 1 = List, 2 = Table
  int typeDiplay = UtilsPlatform.isMobile() ? 1 : 2;
  @observable
  String searchText = "";
  String title;
  Map data;
  @computed
  ObservableList<ItemSelectTable> get listaExibida {
    if (searchText.isEmpty) {
      return list;
    }
    ObservableList<ItemSelectTable> tempList = ObservableList();
    String text = removeDiacritics(searchText.toLowerCase());
    for (int i = 0; i < list.length; i++) {
      for (var value in list[i].strings.values) {
        if (value != null) {
          if (removeDiacritics(value.toString())
                  .toLowerCase()
                  ?.contains(text) ==
              true) {
            tempList.add(list[i]);
            break;
          }
        }
      }
    }
    return tempList;
  }

  @observable
  Icon searchIcon = new Icon(Icons.search);
  @observable
  Widget appBarTitle;
  DataSource fonteDadoAtual;

  /// Cria uma nova variavel, pois se usar a do model,
  /// ela mantém as configurações mesmo depois de sair da tela
  @observable
  bool confirmarParaCarregarDados = false;

  /// Indica se a o tipo de tela deve ser trocado de acordo com o tamanho de tela ou não
  final bool tipoTeladinamica;

  SelectModel selectModel;
  @observable
  int page = 1;
  @observable
  int total = 0;
  @observable
  ObservableList<ItemSelectTable> list = ObservableList();
  var error;
  @observable
  bool loading = false;
  bool loaded = false;
  FocusNode focusNodeSearch = FocusNode();

  /// Guarda o time do ultimo clique da acao
  /// Gambi para contornar caso o usuário clique em selecionar todos na tabela
  int lastClick = 0;

  /// Guarda os ids de todos os registros selecionados
  /// Necessário para persistir o estado da seleção
  Set<ItemSelect> selectedList = {};

  /// Indica a quantidade de itens que estaram disponíveis na página
  @observable
  int quantityItensPage = 10;

  /// Indica que mais dados estão sendo carregados
  @observable
  bool loadingMore = false;

  List<int> get getNumberItemsPerPage => [10, 15, 25, 50];

  TypeSearch typeSearch = TypeSearch.CONTAINS;

  Map<String, Widget> filterControllers = Map();

  /// Indica se o input de pesquisa geral deve ser exibido ou não
  @observable
  bool showSearch = true;

  _SelectAnyBase({this.tipoTeladinamica = true});

  init(String title, SelectModel selectModel, Map data) {
    this.selectModel = selectModel;
    this.data = data;
    appBarTitle = Text(title);

    UtilsHive.getInstance().getBox('select_utils').then((value) async {
      int newValue =
          (await value.get('quantityItensPage')) ?? quantityItensPage;
      if (newValue != quantityItensPage &&
          inList(getNumberItemsPerPage, newValue)) {
        quantityItensPage = newValue;
        if (!confirmarParaCarregarDados) {
          setDataSource();
        }
      }
    });
  }

  bool inList(List values, value) {
    return values.any((element) => element == value);
  }

  @action
  void setList(List<ItemSelectTable> list) {
    this.list.addAll(ObservableList.of(list));
  }

  void dispose() {
    list.clear();
    filter.clear();
    fonteDadoAtual?.listData?.clear();
    fonteDadoAtual?.clear();
  }

  setDataSource({int offset, bool refresh = false}) async {
    showSearch = true;
    try {
      loading = true;
      offset ??= (page - 1) * quantityItensPage;
      (await fonteDadoAtual.getList(quantityItensPage, offset, selectModel,
              data: data, refresh: refresh))
          .listen((event) {
        error = null;
        if (filter.text.trim().isEmpty) {
          /// Caso seja -1, não remove nada pois ela deve retornar todos os registros
          if (offset > -1) {
            /// Remove todos os registros que o id não consta no range retornado
            list.removeWhere((element) {
              return element.position <= event.end &&
                  element.position >= event.start &&
                  !event.data.any((e2) {
                    return e2.id == element.id;
                  });
            });
          }

          event.data.forEach((item) {
            bool present = selectedList.any((element) => element.id == item.id);
            if (item.isSelected == true) {
              if (!present) {
                /// Caso o item esteja selecionado e não esteja na lista selectedList
                selectedList.add(item);
              }
            } else {
              item.isSelected = present;
            }
            int index = list.indexWhere((element) => element.id == item.id);
            if (index > -1) {
              list[index] = item;
            } else {
              list.add(item);
            }
          });
          loading = false;
          loadingMore = false;
          total = event.total;
        }
      }, onError: (error) {
        print(error);
        loading = false;
        loadingMore = false;
        this.error = error;
      });
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      print(error);
      loading = false;
      loadingMore = false;
      this.error = error;
    }
  }

  setDataSourceSearch({int offset, bool refresh = false}) async {
    showSearch = true;
    try {
      inicializarFonteDados();
      loading = true;
      String text = removeDiacritics(filter.text.trim()).toLowerCase();
      (await fonteDadoAtual.getListSearch(text, quantityItensPage,
              offset ?? (page - 1) * quantityItensPage, selectModel,
              data: data, refresh: refresh, typeSearch: typeSearch))
          .listen((ResponseData event) {
        error = null;

        /// Só altera se o texto ainda for idêntico ao pesquisado
        if (removeDiacritics(filter.text.trim()).toLowerCase() == text &&
            text == event.filter) {
          /// Remove todos os registros que o id não consta no range retornado
          list.removeWhere((element) {
            return element.position <= event.end &&
                element.position >= event.start &&
                !event.data.any((e2) {
                  return e2.id == element.id;
                });
          });

          event.data.forEach((item) {
            bool present = selectedList.any((element) => element.id == item.id);
            if (item.isSelected == true) {
              if (!present) {
                /// Caso o item esteja selecionado e não esteja na lista selectedList
                selectedList.add(item);
              }
            } else {
              item.isSelected = present;
            }

            int index = list.indexWhere((element) => element.id == item.id);
            if (index > -1) {
              list[index] = item;
            } else {
              list.add(item);
            }
          });
          total = event.total;
          loading =
              !(removeDiacritics(filter.text.trim()).toLowerCase() == text);
        }
      }, onError: (error) {
        print(error);
        loading = false;
        loadingMore = false;
        this.error = error;
      });
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      print(error);
      loading = false;
      loadingMore = false;
      this.error = error;
    }
  }

  setDataSourceFilter({int offset, bool refresh = false}) async {
    showSearch = false;
    try {
      loading = true;
      offset ??= (page - 1) * quantityItensPage;
      (await fonteDadoAtual.getListFilter(
              buildFilterExpression(), quantityItensPage, offset, selectModel,
              data: data, refresh: refresh))
          .listen((ResponseData event) {
        error = null;
        if (buildFilterExpression().filterExps.isNotEmpty) {
          /// Caso seja -1, não remove nada pois ela deve retornar todos os registros
          if (offset > -1) {
            /// Remove todos os registros que o id não consta no range retornado
            list.removeWhere((element) {
              return element.position <= event.end &&
                  element.position >= event.start &&
                  !event.data.any((e2) {
                    return e2.id == element.id;
                  });
            });
          }

          event.data.forEach((item) {
            bool present = selectedList.any((element) => element.id == item.id);
            if (item.isSelected == true) {
              if (!present) {
                /// Caso o item esteja selecionado e não esteja na lista selectedList
                selectedList.add(item);
              }
            } else {
              item.isSelected = present;
            }
            int index = list.indexWhere((element) => element.id == item.id);
            if (index > -1) {
              list[index] = item;
            } else {
              list.add(item);
            }
          });
          loading = false;
          loadingMore = false;
          total = event.total;
        } else {
          showSearch = true;
        }
      }, onError: (error) {
        print(error);
        loading = false;
        loadingMore = false;
        this.error = error;
      });
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
      print(error);
      loading = false;
      loadingMore = false;
      this.error = error;
    }
  }

  /// Caso confirmarParaCarregarDados seja true, inicializada a var fonteDadoAtual com a fonte padrão
  inicializarFonteDados() {
    if (confirmarParaCarregarDados) {
      confirmarParaCarregarDados = false;
      if (fonteDadoAtual == null) {
        fonteDadoAtual = selectModel.fonteDados;
      }
    }
  }

  reloadData() {
    /// Não recarrega os dados caso precise de confirmação
    if (!confirmarParaCarregarDados) {
      setCorretDataSource(offset: typeDiplay == 1 ? -1 : 0, refresh: true);
    }
  }

  removeItem(int id) {
    list.removeWhere((element) => element.id == id);
    --total;
  }

  export() {
    fonteDadoAtual.exportData(selectModel);
  }

  /// Executa a pesquisa caso o texto seja diferente ou reload seja true
  filtroPesquisaModificado({bool reload = false}) {
    if (filter.text.trim() != searchText || reload) {
      searchText = filter.text.trim();
      if (searchText.isEmpty) {
        if (!confirmarParaCarregarDados) {
          list.clear();
          page = 1;
          setDataSource(offset: typeDiplay == 1 ? -1 : 0);
        }
      } else {
        Future.delayed(
            Duration(milliseconds: selectModel.fonteDados.searchDelay ?? 300),
            () {
          /// Só executa a pesquisa se o input não tiver mudado
          if (searchText == filter.text.trim()) {
            list.clear();
            page = 1;
            setDataSourceSearch(offset: typeDiplay == 1 ? -1 : 0);
          }
        });
      }
    }
  }

  updateTypeSearch(TypeSearch newType) {
    if (newType != null && newType != typeSearch) {
      typeSearch = newType;
      if (filter.text.trim().isNotEmpty) {
        filtroPesquisaModificado(reload: true);
      } else if (buildFilterExpression().filterExps.isNotEmpty) {
        setDataSourceFilter();
      }
    }
  }

  GroupFilterExp buildFilterExpression() {
    List<FilterExp> exps = [];
    filterControllers.forEach((key, value) {
      Linha line = selectModel.linhas
          .firstWhere((element) => element.chave == key, orElse: () => null);
      if (line == null) {
        return;
      }
      if (line.filter != null) {
        if (line.filter is FilterRangeDate &&
            ((value as SelecionarRangeDataWidget).controller.dataInicial !=
                    null ||
                (value as SelecionarRangeDataWidget).controller.dataFinal !=
                    null)) {
          exps.add(FilterExpRangeCollun(
              line: line,
              dateStart:
                  (value as SelecionarRangeDataWidget).controller.dataInicial,
              dateEnd:
                  (value as SelecionarRangeDataWidget).controller.dataFinal));
        }
      } else {
        if (value is TextFormField) {
          if (value.controller.text.trim().isNotEmpty) {
            exps.add(FilterExpCollun(
                line: line,
                value: value.controller.text.trim(),
                typeSearch: typeSearch));
          }
        }
      }
    });
    return GroupFilterExp(filterExps: exps, operatorEx: OperatorFilterEx.AND);
  }

  setCorretDataSource({int offset, bool refresh = false}) {
    if (buildFilterExpression().filterExps.isNotEmpty) {
      setDataSourceFilter(offset: offset, refresh: refresh);
    } else {
      if (filter.text.isEmpty) {
        setDataSource(offset: offset, refresh: refresh);
      } else {
        setDataSourceSearch(offset: offset, refresh: refresh);
      }
    }
  }

  clearFilters() {
    filterControllers.forEach((key, value) {
      if (value is SelecionarRangeDataWidget) {
        value.controller.clear();
      } else if (value is TextFormField) {
        value.controller.clear();
      }
    });
    setCorretDataSource();
  }
}
