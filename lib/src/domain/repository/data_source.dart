import 'package:diacritic/diacritic.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/msk_utils.dart';
import 'package:select_any/select_any.dart';

part 'data_source.g.dart';

abstract class DataSource = _DataSourceBase with _$DataSource;

abstract class _DataSourceBase with Store {
  /// Indica a chave (id) dessa fonte de dados
  final String? id;

  /// Indica o tempo de delay (em ms) entre a digitação do usuário e a busca dos dados
  /// É util para econimizar banda
  final int searchDelay;

  /// Indica se será permitido exportar dessa fonte ou não
  final bool allowExport;

  /// Indica se a fonte suporta paginação
  bool supportPaginate;

  /// Indica suporte a filtros por coluna
  bool supportSingleLineFilter;

  @observable
  ObservableList<ItemSelectTable> listData = ObservableList();

  _DataSourceBase(
      {this.id,
      this.searchDelay = 300,
      this.allowExport = false,
      this.supportPaginate = false,
      this.supportSingleLineFilter = false});

  Future<Stream<ResponseDataDataSource>> getList(
      int limit, int offset, SelectModel? selectModel,
      {Map? data,
      bool refresh = false,
      ItemSort? itemSort,
      GroupFilterExp? filter});

  Future<Stream<ResponseDataDataSource>> getListSearch(
      String text, int? limit, int offset, SelectModel? selectModel,
      {Map? data,
      bool? refresh,
      TypeSearch typeSearch = TypeSearch.CONTAINS,
      ItemSort? itemSort});

  List<ItemSelectTable> generateList(
      List<Map<String, dynamic>> data, int offset, SelectModel selectModel) {
    ObservableList<ItemSelectTable> lista = ObservableList();
    if (offset < 0) {
      offset = 0;
    }
    String id = this.id ?? selectModel.id;

    /// Apply a filter so that only distinct elements remain
    int oldLength = data.length;
    data = data.distinctBy((e) => e[id]);

    assert(oldLength == data.length,
        'List element marked go must be distinct (no duplicates)');

    for (Map a in data) {
      // ignore: deprecated_member_use_from_same_package
      bool preSelecionado = selectModel.selectedItens != null &&
          // ignore: deprecated_member_use_from_same_package
          selectModel.selectedItens!
              .any((element) => element == a[selectModel.id]);
      if (!preSelecionado) {
        preSelecionado = selectModel.preSelected
                ?.any((element) => element.id == a[selectModel.id]) ==
            true;
      }
      //caso nao seja pré-selecionado ou a regra é exibir os pre-selecionados
      if (preSelecionado == false || selectModel.showPreSelected == true) {
        ItemSelectTable itemSelect = ItemSelectTable();
        for (Line line in selectModel.lines) {
          // caso seja uma lista
          if (line.listKeys != null) {
            String lineValue = "";
            for (Map map2 in a[line.key]) {
              for (Line linha2 in line.listKeys!) {
                var ret = map2.getLineValue(linha2.key);
                lineValue += '$ret, ';
              }
            }
            if (lineValue.isNotEmpty) {
              //remove a ultima virgula
              lineValue = lineValue.substring(0, lineValue.length - 2);
            }
            itemSelect.strings![line.key] = lineValue;
          } else {
            itemSelect.strings![line.key] = a.getLineValue(line.key);
          }
        }

        /// Caso a fonte indique um id, pega dela, se não, pega do modelo
        if (a[id] == null && !UtilsPlatform.isRelease) {
          throw ('Id null ${selectModel.title}');
        }
        itemSelect.id = a[this.id ?? selectModel.id];
        itemSelect.isSelected = preSelecionado;
        itemSelect.object = a;
        itemSelect.position = offset++;

        lista.add(itemSelect);
      }
    }
    return lista;
  }

  Future exportData(SelectModel selectModel, bool onlyFiltered,
      GroupFilterExp filter, String text, TypeSearch typeSearch);

  Future clear();

  bool filterTypeSearch(TypeSearch typeSearch, dynamic value, dynamic text) {
    if (!(text is String)) {
      text = text?.toString() ?? '';
    }
    text = removeDiacritics(text);
    if (typeSearch == TypeSearch.CONTAINS) {
      return removeDiacritics(value.toString()).toLowerCase().contains(text) ==
          true;
    } else if (typeSearch == TypeSearch.BEGINSWITH) {
      return removeDiacritics(value.toString())
              .toLowerCase()
              .startsWith(text) ==
          true;
    } else if (typeSearch == TypeSearch.ENDSWITH) {
      return removeDiacritics(value.toString()).toLowerCase().endsWith(text) ==
          true;
    } else if (typeSearch == TypeSearch.NOTCONTAINS) {
      return removeDiacritics(value.toString()).toLowerCase().contains(text) !=
          true;
    }
    return false;
  }

  GroupFilterExp? convertFiltersToLowerCase(GroupFilterExp? filter) {
    if (filter != null) {
      for (var group in filter.filterExps) {
        if (group is GroupFilterExp) {
          group = convertFiltersToLowerCase(group)!;
        } else if (group is FilterExpColumn) {
          if (group.value is String) {
            group.value = group.value.toString().toLowerCase();
          }
        }
      }
    }
    return filter;
  }
}
