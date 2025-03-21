// ignore_for_file: unused_element

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/msk_utils.dart';
import 'package:select_any/select_any.dart';
import 'package:select_any/src/presentation/widgets/select_range_date/select_range_date_widget.dart';

part 'select_any_controller.g.dart';

class SelectAnyController = _SelectAnyBase with _$SelectAnyController;

abstract class _SelectAnyBase with Store {
  final TextEditingController filter = new TextEditingController();
  @observable

  /// 1 = List, 2 = Table
  int typeDiplay = UtilsPlatform.isMobile ? 1 : 2;
  @observable
  String searchText = "";
  String? title;
  Map? data;
  @computed
  ObservableList<ItemSelectTable> get showList => list;

  @observable
  Icon searchIcon = Icon(Icons.search);
  @observable
  Widget? appBarTitle;
  DataSource? actualDataSource;

  /// Cria uma nova variavel, pois se usar a do model,
  /// ela mantém as configurações mesmo depois de sair da tela
  @observable
  bool confirmToLoadData = false;

  /// Indica se a o tipo de tela deve ser trocado de acordo com o tamanho de tela ou não
  final bool dynamicScreen;

  SelectModel? selectModel;
  @observable
  int page = 1;
  @observable
  int total = 0;
  @observable
  ObservableList<ItemSelectTable> list = ObservableList();
  var error;
  @observable
  bool loading = false;
  @observable
  bool loaded = false;
  FocusNode focusNodeSearch = FocusNode();

  /// Guarda o time do ultimo clique da acao
  /// Gambi para contornar caso o usuário clique em selecionar todos na tabela
  int lastClick = 0;

  /// Guarda os ids de todos os registros selecionados
  /// Necessário para persistir o estado da seleção
  Set<ItemSelect> selectedList = {};

  /// Indica a quantidade de itens que estarão disponíveis na página
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

  bool get showLineFilter =>
      selectModel!.showFiltersInput == true &&
      actualDataSource?.supportSingleLineFilter != false;

  ItemSort? itemSort;
  @observable
  GroupFilterExp? actualFilters;

  bool _hasSearchedAlready = false;

  _SelectAnyBase({this.dynamicScreen = true});

  init(String title, SelectModel selectModel, Map? data) async {
    this.selectModel = selectModel;
    this.data = data;
    appBarTitle = Text(title);
    if (selectModel.preSelected != null) {
      selectedList.addAll(selectModel.preSelected!);
    }
    var box = await UtilsHive.getInstance()!.getBox('select_utils');
    int newValue = (await box.get('quantityItensPage')) ?? quantityItensPage;
    if (newValue != quantityItensPage &&
        inList(getNumberItemsPerPage, newValue)) {
      quantityItensPage = newValue;
      if (!confirmToLoadData) {
        reloadData();
      }
    }
    if (selectModel.initialFilter != null) {
      Line? value = await selectModel.initialFilter!(selectModel.lines);
      if (value != null) {
        if (!confirmToLoadData) {
          onColumnFilterChanged();
        }
      }
    }
  }

  bool inList(List values, value) {
    return values.any((element) => element == value);
  }

  void dispose() {
    list.clear();
    filter.clear();
    searchText = '';
    actualDataSource?.listData.clear();
    actualDataSource?.clear();
    loaded = false;
    clearFilters(callDataSource: false);
    filterControllers.clear();
    page = 1;
  }

  void setDataSource(
      {int? offset, bool refresh = false, bool loadMore = false}) async {
    try {
      initializeDataSource();
      GroupFilterExp groupFilterExp = buildFilterExpression();
      showSearch = groupFilterExp.filterExps.isEmpty;
      if (loadMore) {
        loadingMore = true;
      } else {
        loading = true;
      }
      offset ??= (page - 1) * quantityItensPage;
      (await actualDataSource!.getList(quantityItensPage, offset, selectModel,
              data: data,
              refresh: refresh,
              itemSort: itemSort,
              filter: groupFilterExp))
          .listen((event) {
        error = null;
        if (filter.text.trim().isEmpty) {
          if (!loadMore) {
            list.clear();
          }

          /// Não aplica no debug/profile para captura de erros
          if (UtilsPlatform.isRelease) {
            event.data = event.data.distinctBy((e) => e.id);
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
            list.add(item);
          });
          list = ObservableList.of(list.sortedBy((e) => e.position!));
          loading = false;
          loadingMore = false;
          loaded = true;
          total = event.total ?? 0;
          setDataType();
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

  setDataSourceSearch(
      {int? offset, bool refresh = false, bool loadMore = false}) async {
    showSearch = true;
    try {
      initializeDataSourceAndConfirmData();
      if (loadMore) {
        loadingMore = true;
      } else {
        loading = true;
      }
      String text = removeDiacritics(filter.text.trim()).toLowerCase();
      (await actualDataSource!.getListSearch(text, quantityItensPage,
              offset ?? (page - 1) * quantityItensPage, selectModel,
              data: data,
              refresh: refresh,
              typeSearch: typeSearch,
              itemSort: itemSort))
          .listen((ResponseDataDataSource event) {
        error = null;

        /// Só altera se o texto ainda for idêntico ao pesquisado
        if (removeDiacritics(filter.text.trim()).toLowerCase() == text &&
            text == event.filter) {
          if (!loadMore) {
            list.clear();
          }

          /// Não aplica no debug/profile para captura de erros
          if (UtilsPlatform.isRelease) {
            event.data = event.data.distinctBy((e) => e.id);
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
            list.add(item);
          });
          list = ObservableList.of(list.sortedBy((e) => e.position!));
          total = event.total ?? 0;
          loading =
              !(removeDiacritics(filter.text.trim()).toLowerCase() == text);
          loaded = true;
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
  void initializeDataSourceAndConfirmData() {
    if (confirmToLoadData) {
      confirmToLoadData = false;
      initializeDataSource();
    }
  }

  void initializeDataSource() {
    if (actualDataSource == null) {
      actualDataSource = selectModel!.dataSource;
    }
  }

  /// Limpa a lista e busca novamente os dados
  /// Usar refresh = false ao atualizar a ordenação da lista
  reloadData({bool refresh = true}) {
    /// Não recarrega os dados caso precise de confirmação
    if (!confirmToLoadData) {
      list.clear();
      setCorretDataSource(offset: getOffSet, refresh: refresh);
    }
  }

  updateSortCollumn() {
    list.clear();
    setCorretDataSource(offset: getOffSet, refresh: false);
  }

  removeItem(int id) {
    list.removeWhere((element) => element.id == id);
    --total;
  }

  int get getOffSet => typeDiplay == 1 ? -1 : (page - 1) * quantityItensPage;

  void export(BuildContext context) {
    showDialog(
        context: context,
        builder: (alertContext) => AlertDialog(
                content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                    title: Text('Lista inteira'),
                    onTap: () {
                      Navigator.pop(alertContext);
                      actualDataSource!.exportData(selectModel!, false,
                          buildFilterExpression(), searchText, typeSearch);
                    }),
                ListTile(
                    title: Text('Lista filtrada'),
                    onTap: () {
                      Navigator.pop(alertContext);
                      actualDataSource!.exportData(selectModel!, true,
                          buildFilterExpression(), searchText, typeSearch);
                    })
              ],
            )));
  }

  /// Executa a pesquisa caso o texto seja diferente ou reload seja true
  filterChanged({bool reload = false}) {
    if (filter.text.trim() != searchText || reload) {
      searchText = filter.text.trim();
      if (searchText.isEmpty) {
        if (!confirmToLoadData) {
          list.clear();
          page = 1;
          setDataSource(offset: typeDiplay == 1 ? -1 : 0);
        }
      } else {
        /// Usa para guardar o valor original
        String tempSearchText = searchText;
        // Altera valor para false porque se o [onSubmittedSearch] não for chamado antes do delay a pesquisa por esta função será efetuada.
        _hasSearchedAlready = false;
        Future.delayed(
            Duration(milliseconds: selectModel!.dataSource.searchDelay), () {
          /// Só executa a pesquisa se o input não tiver mudado e já não tenha sido executada
          if (tempSearchText == filter.text.trim() && !_hasSearchedAlready) {
            list.clear();
            page = 1;
            setDataSourceSearch(
                offset: selectModel!.dataSource.supportPaginate
                    ? null
                    : typeDiplay == 1
                        ? -1
                        : 0);
            // Altera para true após fazer a pesquisa evitando que seja feita novamente caso o [onSubmittedSearch] seja chamado e
            //não tenha sido mudado o input [filter.text].
            _hasSearchedAlready = true;
          }
        });
      }
    }
  }

  /// Executa a pesquisa caso não tenha sido feita na chamada de [filterChanged]
  void onSubmittedSearch() {
    // Verifica se a pesquisa já não foi feita, como quando [filterChanged] é chamado.
    if (!_hasSearchedAlready) {
      searchText = filter.text.trim();
      list.clear();
      page = 1;
      setDataSourceSearch(
          offset: selectModel!.dataSource.supportPaginate
              ? null
              : typeDiplay == 1
                  ? -1
                  : 0);
      // Altera para true após fazer a pesquisa evitando que seja feita novamente caso o [filterChanged]
      //tente fazer a pesquisa após o delay.
      _hasSearchedAlready = true;
    }
  }

  updateTypeSearch(TypeSearch? newType) {
    if (newType != null && newType != typeSearch) {
      page = 1;
      typeSearch = newType;
      if (filter.text.trim().isNotEmpty) {
        filterChanged(reload: true);
      } else {
        setDataSource();
      }
    }
  }

  GroupFilterExp buildFilterExpression() {
    List<FilterExp> exps = [];
    selectModel?.lines.forEach((line) {
      if (line.filter != null) {
        if (line.filter is FilterRangeDate) {
          if (((line.filter as FilterRangeDate).selectedValueRange?.start !=
                  null ||
              (line.filter as FilterRangeDate).selectedValueRange?.end !=
                  null)) {
            exps.add(FilterExpRangeCollun(
                line: line,
                dateStart:
                    (line.filter as FilterRangeDate).selectedValueRange?.start,
                dateEnd:
                    (line.filter as FilterRangeDate).selectedValueRange?.end));
          }
        } else if (line.filter!.selectedValue != null) {
          if (line.filter is FilterSelectItem) {
            exps.add(FilterSelectColumn(
                line: line,
                value: (line.filter as FilterSelectItem)
                    .selectedValue!
                    .value
                    ?.toString()
                    .toLowerCase(),
                customKey: (line.filter as FilterSelectItem).keyFilterId,
                valueId:
                    (line.filter as FilterSelectItem).selectedValue!.idValue,
                typeSearch: TypeSearch.CONTAINS));
          } else if (line.filter is FilterText &&
              line.filter!.selectedValue!.value.toString().isNotEmpty) {
            exps.add(FilterExpColumn(
                line: line,
                value: line.filter!.selectedValue!.value,
                typeSearch: typeSearch));
          }
        }
      }
    });
    actualFilters =
        GroupFilterExp(filterExps: exps, operatorEx: OperatorFilterEx.AND);
    return actualFilters!;
  }

  setCorretDataSource({int? offset, bool refresh = false}) {
    if (filter.text.isEmpty) {
      setDataSource(offset: offset, refresh: refresh);
    } else {
      setDataSourceSearch(offset: offset, refresh: refresh);
    }
  }

  clearFilters({bool callDataSource = true}) {
    filterControllers.forEach((key, value) {
      if (value is SelectRangeDateWidget) {
        value.controller.clear();
      } else if (value is Padding) {
        if (value.child is TextField) {
          (value.child as TextField).controller!.clear();
        }
      }
    });
    selectModel?.lines.forEach((e) {
      e.filter?.selectedValue = null;
    });
    if (callDataSource) {
      setCorretDataSource();
    }
  }

  onColumnFilterChanged() {
    resetOnFiltersChanged();
    setCorretDataSource(offset: getOffSet);
  }

  /// Limpa o texto da barra de pesquisa e zera a pagina
  resetOnFiltersChanged() {
    if (page != 1) {
      page = 1;
    }
    filter.clear();
  }

  /// Seta o tipo das colunas onde ele estiver null
  void setDataType() {
    if (list.isNotEmpty) {
      selectModel?.lines.forEach((line) {
        TypeData? typeData = line.typeData;
        if (typeData == null) {
          /// If you have at least one string, consider everything as a string
          /// The other types of data require that they all have the same type
          if (list.any((element) => element.object[line.key] is String)) {
            typeData = TDString();
          } else if (list.every((element) => element.object[line.key] is num)) {
            typeData = TDNumber();
          } else if (list
              .every((element) => element.object[line.key] is bool)) {
            typeData = TDBoolean();
          } else {
            typeData = TDNotString();
          }

          // Save the data type so you don't need to scroll through the list again
          line.typeData = typeData;
        }
      });
    }
  }

  void updateSelectItem(ItemSelect item, bool newValue) {
    if (newValue) {
      selectedList.add(item);
    } else {
      selectedList.removeWhere((element) => element.id == item.id);
    }
    list.forEach((element) {
      if (element.id == item.id) {
        element.isSelected = newValue;
      }
    });
    showList.forEach((element) {
      if (element.id == item.id) {
        element.isSelected = newValue;
      }
    });
  }
}
