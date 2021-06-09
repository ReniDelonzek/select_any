import 'package:select_any/app/utils/utils_file.dart';
import 'package:select_any/select_any.dart';

import 'package:diacritic/diacritic.dart';
import 'package:msk_utils/extensions/date.dart';

import 'package:msk_utils/extensions/list.dart';

abstract class DataSourceAny extends DataSource {
  List<Map<String, dynamic>> listAll;
  ItemSort _actualySort;

  DataSourceAny({String id, bool allowExport = true})
      : super(id: id, allowExport: allowExport);

  @override
  Future<Stream<ResponseData>> getList(
      int limit, int offset, SelectModel selectModel,
      {Map data, bool refresh = false, ItemSort itemSort}) async {
    if (listAll == null ||
        listAll.isEmpty ||
        refresh == true ||
        // Caso o itemSort tenha sido anulado, atualiza a lista para restaurar a formatação padrão
        (itemSort == null && _actualySort != null)) {
      listAll?.clear();
      await fetchData(limit, offset, selectModel, data: data);
    }
    if (itemSort != _actualySort) {
      applySortFilters(itemSort, selectModel.id);
    }

    List<Map<String, dynamic>> subList = getSubList(offset, limit, listAll);

    return Stream.value(ResponseData(
        total: listAll.length,
        data: generateList(subList, offset, selectModel),
        start: offset,
        end: offset + limit));
  }

  List<Map<String, dynamic>> getSubList(
      int offset, int limit, List<Map<String, dynamic>> tempList) {
    List<Map<String, dynamic>> subList = [];
    if (offset == -1) {
      subList = tempList;
    } else if (limit > 0 && limit + offset < tempList.length) {
      subList = tempList.sublist(offset, limit + offset);
    } else if (offset < tempList.length) {
      subList = tempList.sublist(offset);
    } else {
      subList = tempList;
    }
    return subList;
  }

  @override
  Future<Stream<ResponseData>> getListSearch(
      String text, int limit, int offset, SelectModel selectModel,
      {Map data,
      bool refresh = false,
      TypeSearch typeSearch = TypeSearch.CONTAINS}) async {
    if (listAll == null || listAll.isEmpty || refresh == true) {
      await fetchData(limit, offset, selectModel, data: data);
    }
    List<Map<String, dynamic>> tempList = [];
    for (int i = 0; i < listAll.length; i++) {
      for (var value in listAll[i].values) {
        if (value != null) {
          if (filterTypeSearch(typeSearch, value, text)) {
            tempList.add(listAll[i]);
            break;
          }
        }
      }
    }

    List<Map<String, dynamic>> subList = getSubList(offset, limit, tempList);
    return Stream.value(ResponseData(
        total: tempList.length,
        data: generateList(subList, offset, selectModel),
        start: offset,
        end: offset + limit,
        filter: text));
  }

  Future exportData(SelectModel selectModel) async {
    StringBuffer stringBuffer = StringBuffer();
    if (listAll.isNotEmpty) {
      for (var key in listAll.first.keys) {
        stringBuffer..write(key)..write(';');
      }
      stringBuffer.write('\n');
    }
    for (var item in listAll) {
      for (var value in item.values) {
        stringBuffer..write(value)..write(';');
      }
      stringBuffer.write('\n');
    }
    UtilsFile.saveFileString(stringBuffer.toString(),
        dirComplementar: '${selectModel.titulo}',
        fileName: '${DateTime.now().string('dd-MM-yyyy HH-mm-ss')}.csv');
    return;
  }

  Future fetchData(int limit, int offset, SelectModel selectModel, {Map data});

  @override
  Future clear() async {
    listAll = null;
    return;
  }

  bool filterTypeSearch(TypeSearch typeSearch, dynamic value, String text) {
    if (typeSearch == TypeSearch.CONTAINS) {
      return removeDiacritics(value.toString()).toLowerCase()?.contains(text) ==
          true;
    } else if (typeSearch == TypeSearch.BEGINSWITH) {
      return removeDiacritics(value.toString())
              .toLowerCase()
              ?.startsWith(text) ==
          true;
    } else if (typeSearch == TypeSearch.ENDSWITH) {
      return removeDiacritics(value.toString()).toLowerCase()?.endsWith(text) ==
          true;
    }
    return false;
  }

  bool applyFilter(GroupFilterExp groupFilterExp, Map<String, dynamic> map) {
    bool filterAndOk;
    for (var filter in groupFilterExp.filterExps) {
      if (groupFilterExp.operatorEx == OperatorFilterEx.OR) {
        /// Como é uma expressão or, caso esse filtro seja verdadeiro sempre retorna true
        if (filter is FilterExpCollun) {
          if (filterTypeSearch(
              filter.typeSearch, map[filter.line.chave], filter.value)) {
            return true;
          }
        } else if (filter is GroupFilterExp) {
          if (applyFilter(filter, map)) {
            return true;
          }
        }
      } else if (groupFilterExp.operatorEx == OperatorFilterEx.AND) {
        /// Expressão AND seta filterAndOk = true caso seja true, caso seja falso retorna false na função,
        if (filter is FilterExpCollun) {
          if (filterTypeSearch(
              filter.typeSearch, map[filter.line.chave], filter.value)) {
            filterAndOk = true;
          } else {
            return false;
          }
        } else if (filter is GroupFilterExp) {
          if (applyFilter(filter, map)) {
            filterAndOk = true;
          } else {
            return false;
          }
        } else if (filter is FilterExpRangeCollun) {
          if (map[filter.line.chave] >
                  (filter.dateStart?.millisecondsSinceEpoch ?? 0) &&
              map[filter.line.chave] <
                  (filter.dateEnd?.millisecondsSinceEpoch ??
                      double.maxFinite.toInt())) {
            filterAndOk = true;
          } else {
            return false;
          }
        }
      }
    }
    return filterAndOk ?? false;
  }

  bool compareValues(value1, value2) {
    return removeDiacritics(value1.toString())
            .toLowerCase()
            ?.contains(value2) ==
        true;
  }

  @override
  Future<Stream<ResponseData>> getListFilter(
      GroupFilterExp filter, int limit, int offset, SelectModel selectModel,
      {Map data, bool refresh = false}) async {
    if (listAll == null || listAll.isEmpty || refresh == true) {
      await fetchData(limit, offset, selectModel, data: data);
    }
    List<Map<String, dynamic>> tempList = [];

    for (int i = 0; i < listAll.length; i++) {
      if (applyFilter(filter, listAll[i])) {
        tempList.add(listAll[i]);
      }
    }
    List<Map<String, dynamic>> subList = getSubList(offset, limit, tempList);
    return Stream.value(ResponseData(
        total: tempList.length,
        data: generateList(subList, offset, selectModel),
        start: offset,
        end: offset + limit));
  }

  bool applySortFilters(ItemSort itemSort, String keyId) {
    _actualySort = itemSort;
    if (itemSort != null) {
      /// Maintain a consistent order for the list
      var temp = listAll.sortedBy((e) => e[keyId]);

      temp = listAll.sortedBy((e) => e[itemSort.linha.chave]);
      if (itemSort.typeSort == EnumTypeSort.DESC) {
        listAll = temp.toList().reversed.toList();
      } else {
        listAll = temp;
      }
    }

    return true;
  }
}
