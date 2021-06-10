import 'package:diacritic/diacritic.dart';
import 'package:msk_utils/extensions/date.dart';
import 'package:msk_utils/extensions/list.dart';
import 'package:msk_utils/utils/utils_sentry.dart';
import 'package:select_any/app/utils/utils_file.dart';
import 'package:select_any/select_any.dart';

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
      listAll = applySortFilters(itemSort, selectModel.id, listAll);
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
      TypeSearch typeSearch = TypeSearch.CONTAINS,
      ItemSort itemSort}) async {
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

    tempList = applySortFilters(itemSort, selectModel.id, tempList);

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

  List<Map<String, dynamic>> applySortFilters(
      ItemSort itemSort, String keyId, List<Map<String, dynamic>> list) {
    _actualySort = itemSort;
    try {
      if (itemSort != null && list.isNotEmpty) {
        //DateTime datetime = DateTime.now();

        /// Maintain a consistent order for the list
        var temp = list.sortedBy((e) => e[keyId]);
        TypeData typeData = itemSort.linha.typeData;
        if (typeData == null) {
          /// If you have at least one string, consider everything as a string
          /// The other types of data require that they all have the same type
          if (list.any((element) => element[itemSort.linha.chave] is String)) {
            typeData = TDString();
          } else if (list
              .every((element) => element[itemSort.linha.chave] is int)) {
            typeData = TDNumber();
          } else if (list
              .every((element) => element[itemSort.linha.chave] is bool)) {
            typeData = TDBoolean();
          } else {
            typeData = TDNotString();
          }

          // Save the data type so you don't need to scroll through the list again
          itemSort.linha.typeData = typeData;
        }

        if (typeData is TDString || typeData is TDNotString) {
          list = _sort(temp, itemSort, '', typeData: typeData);
        } else if (typeData is TDNumber) {
          list = _sort(temp, itemSort, 0);
        } else if (typeData is TDBoolean) {
          list = _sort(temp, itemSort, false);
        } else if (typeData is TDDateTimestamp) {
          list = _sort(temp, itemSort, 0);
        } else if (typeData is TDDateString) {
          list = _sort(temp, itemSort, '');
        } else {
          list = _sort(temp, itemSort, null);
        }
        //debugPrint(
        //    'Sort in: ${DateTime.now().difference(datetime).inMilliseconds}');
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return list;
  }

  static List<Map<String, dynamic>> _sort(
      List<Map<String, dynamic>> temp, ItemSort itemSort, dynamic defaultValue,
      {TypeData typeData}) {
    // Apply special string formatting
    if (typeData is TDString || typeData is TDNotString) {
      if (itemSort.typeSort == EnumTypeSort.ASC) {
        return temp.sortedBy((e) =>
            e[itemSort.linha.chave]?.toString()?.toLowerCase()?.trim() ??
            defaultValue);
      } else {
        return temp.sortedByDesc((e) =>
            e[itemSort.linha.chave]?.toString()?.toLowerCase()?.trim() ??
            defaultValue);
      }
    }
    if (itemSort.typeSort == EnumTypeSort.ASC) {
      return temp.sortedBy((e) => e[itemSort.linha.chave] ?? defaultValue);
    } else {
      return temp.sortedByDesc((e) => e[itemSort.linha.chave] ?? defaultValue);
    }
  }
}
