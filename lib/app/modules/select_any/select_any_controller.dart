import 'package:diacritic/diacritic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:msk_utils/utils/utils_hive.dart';
import 'package:msk_utils/utils/utils_platform.dart';
import 'package:msk_utils/utils/utils_sentry.dart';
import 'package:select_any/app/models/models.dart';

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

  _SelectAnyBase({this.tipoTeladinamica = true});

  init(String title, SelectModel selectModel, Map data) {
    this.selectModel = selectModel;
    this.data = data;
    appBarTitle = Text(title);

    UtilsHive.getInstance().getBox('select_utils').then((value) async {
      int newValue =
          (await value.get('quantityItensPage')) ?? quantityItensPage;
      if (newValue != quantityItensPage) {
        quantityItensPage = newValue;
        if (!confirmarParaCarregarDados) {
          setDataSource();
        }
      }
    });
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
    /// Somente busca os dados caso eles ainda não esteja na lista
    /// Abordagem com problemas, pois a lista pode conter registros de outros ranges
    //if ((page - 1) * quantityItensPage >= list.length) {
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
    //}
  }

  setDataSourceSearch({int offset, bool refresh = false}) async {
    try {
      inicializarFonteDados();
      loading = true;
      String text = removeDiacritics(filter.text.trim()).toLowerCase();
      (await fonteDadoAtual.getListSearch(text, quantityItensPage,
              offset ?? (page - 1) * quantityItensPage, selectModel,
              data: data, refresh: refresh))
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

  /// Caso confirmarParaCarregarDados seja true, inicializada a var fonteDadoAtual com a fonte padrão
  inicializarFonteDados() {
    if (confirmarParaCarregarDados) {
      confirmarParaCarregarDados = false;
      fonteDadoAtual = selectModel.fonteDados;
    }
  }

  reloadData() {
    /// Não recarrega os dados caso precise de confirmação
    if (!confirmarParaCarregarDados) {
      list.clear();
      if (filter.text.trim().isEmpty) {
        setDataSource(refresh: true);
      } else {
        setDataSourceSearch(refresh: true);
      }
    }
  }

  removeItem(int id) {
    list.removeWhere((element) => element.id == id);
    --total;
  }

  export() {
    fonteDadoAtual.exportData(selectModel);
  }

  filtroPesquisaModificado() {
    if (filter.text.trim() != searchText) {
      searchText = filter.text.trim();
      if (searchText.isEmpty) {
        if (!confirmarParaCarregarDados) {
          list.clear();
          page = 1;
          setDataSource();
        }
      } else {
        Future.delayed(
            Duration(milliseconds: selectModel.fonteDados.searchDelay ?? 300),
            () {
          /// Só executa a pesquisa se o input não tiver mudado
          if (searchText == filter.text.trim()) {
            list.clear();
            page = 1;
            setDataSourceSearch();
          }
        });
      }
    }
  }
}
