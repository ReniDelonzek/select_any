import 'package:diacritic/diacritic.dart';
import 'package:msk_utils/msk_utils.dart';
import 'package:msk_utils/utils/utils_sentry.dart';
import 'package:select_any/src/utils/utils_file.dart';
import 'package:select_any/select_any.dart';

abstract class DataSourceAny extends DataSource {
  List<Map<String, dynamic>> listAll;
  ItemSort _actualySort;

  DataSourceAny(
      {String id, bool allowExport = true, bool supportSingleLineFilter = true})
      : super(
            id: id,
            allowExport: allowExport,
            supportSingleLineFilter: supportSingleLineFilter);

  @override
  Future<Stream<ResponseData>> getList(
    int limit,
    int offset,
    SelectModel selectModel, {
    Map data,
    bool refresh = false,
    ItemSort itemSort,
    GroupFilterExp filter,
  }) async {
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

    filter = convertFiltersToLowerCase(filter);

    List<Map<String, dynamic>> tempList = [];
    if (filter != null && filter.filterExps.isNotEmpty) {
      for (int i = 0; i < listAll.length; i++) {
        if (applyGroupFilterExp(filter, listAll[i])) {
          tempList.add(listAll[i]);
        }
      }
    } else {
      tempList = listAll;
    }

    List<Map<String, dynamic>> subList = getSubList(offset, limit, tempList);

    return Stream.value(ResponseData(
        total: tempList?.length ?? 0,
        data: generateList(subList, offset, selectModel),
        start: offset,
        end: offset + limit));
  }

  List<Map<String, dynamic>> getSubList(
      int offset, int limit, List<Map<String, dynamic>> tempList) {
    List<Map<String, dynamic>> subList = [];
    if (tempList == null) return subList;
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
    List<Map<String, dynamic>> tempList =
        applyFilterList(typeSearch, listAll, text);

    tempList = applySortFilters(itemSort, selectModel.id, tempList);

    List<Map<String, dynamic>> subList = getSubList(offset, limit, tempList);
    return Stream.value(ResponseData(
        total: tempList.length,
        data: generateList(subList, offset, selectModel),
        start: offset,
        end: offset + limit,
        filter: text));
  }

  List<Map<String, dynamic>> applyFilterList(
      TypeSearch typeSearch, List<Map<String, dynamic>> list, String text) {
    List<Map<String, dynamic>> tempList = [];
    for (int i = 0; i < list.length; i++) {
      if (typeSearch == TypeSearch.NOTCONTAINS) {
        bool contains = false;
        for (var value in listAll[i].values) {
          if (value != null) {
            if (removeDiacritics(value.toString())
                .toLowerCase()
                .contains(text)) {
              contains = true;
              break;
            }
          }
        }
        if (!contains) {
          tempList.add(listAll[i]);
        }
      } else {
        for (var value in listAll[i].values) {
          if (value != null) {
            if (filterTypeSearch(typeSearch, value, text)) {
              tempList.add(listAll[i]);
              break;
            }
          }
        }
      }
    }
    return tempList;
  }

  Future exportData(SelectModel selectModel) async {
    StringBuffer stringBuffer = StringBuffer();
    if (listAll.isNotEmpty) {
      for (var key in listAll.first.keys) {
        stringBuffer
          ..write(key)
          ..write(';');
      }
      stringBuffer.write('\n');
    }
    for (var item in listAll) {
      for (var value in item.values) {
        stringBuffer
          ..write(value)
          ..write(';');
      }
      stringBuffer.write('\n');
    }
    UtilsFile.saveFileString(stringBuffer.toString(),
        dirComplementar: '${selectModel.title}',
        fileName: '${DateTime.now().string('dd-MM-yyyy HH-mm-ss')}.csv');
    return;
  }

  Future fetchData(int limit, int offset, SelectModel selectModel, {Map data});

  @override
  Future clear() async {
    listAll = null;
    return;
  }

  bool applyGroupFilterExp(
      GroupFilterExp groupFilterExp, Map<String, dynamic> map) {
    bool filterAndOk;
    for (var filter in groupFilterExp.filterExps) {
      if (groupFilterExp.operatorEx == OperatorFilterEx.OR) {
        /// Como é uma expressão or, caso esse filtro seja verdadeiro sempre retorna true

        if (filter is FilterExpColumn) {
          var value = map[filter.line.key];
          if (filter.line.formatData != null) {
            value = filter.line.formatData
                .formatData(ObjFormatData(data: value, map: map));
          }
          if (filterTypeSearch(filter.typeSearch, value, filter.value)) {
            return true;
          }
        } else if (filter is FilterSelectColumn) {
          var value = map[filter.line.key];
          if (filter.line.formatData != null) {
            value = filter.line.formatData
                .formatData(ObjFormatData(data: value, map: map));
          }
          if (filterTypeSearch(filter.typeSearch, value, filter.value)) {
            return true;
          }
        } else if (filter is FilterExpRangeCollun) {
          if (map[filter.line.key] != null &&
              map[filter.line.key] >
                  (filter.dateStart?.millisecondsSinceEpoch ?? 0) &&
              map[filter.line.key] <
                  (filter.dateEnd?.millisecondsSinceEpoch ??
                      double.maxFinite.toInt())) {
            return true;
          } else {
            return false;
          }
        } else if (filter is GroupFilterExp) {
          if (applyGroupFilterExp(filter, map)) {
            return true;
          }
        }
      } else if (groupFilterExp.operatorEx == OperatorFilterEx.AND) {
        /// Expressão AND seta filterAndOk = true caso seja true, caso seja falso retorna false na função,
        if (filter is FilterExpColumn) {
          var value = map[filter.line.key];
          if (filter.line.formatData != null) {
            value = filter.line.formatData
                .formatData(ObjFormatData(data: value, map: map));
          }
          if (filterTypeSearch(filter.typeSearch, value, filter.value)) {
            filterAndOk = true;
          } else {
            return false;
          }
        } else if (filter is FilterSelectColumn) {
          var value = map[filter.line.key];
          if (filter.line.formatData != null) {
            value = filter.line.formatData
                .formatData(ObjFormatData(data: value, map: map));
          }
          if (filterTypeSearch(filter.typeSearch, value, filter.value)) {
            filterAndOk = true;
          } else {
            return false;
          }
        } else if (filter is GroupFilterExp) {
          if (applyGroupFilterExp(filter, map)) {
            filterAndOk = true;
          } else {
            return false;
          }
        } else if (filter is FilterExpRangeCollun) {
          if (map[filter.line.key] != null &&
              map[filter.line.key] >
                  (filter.dateStart?.millisecondsSinceEpoch ?? 0) &&
              map[filter.line.key] <
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

  List<Map<String, dynamic>> applySortFilters(
      ItemSort itemSort, String keyId, List<Map<String, dynamic>> list) {
    _actualySort = itemSort;
    try {
      if (itemSort != null && list.isNotEmpty) {
        /// Maintain a consistent order for the list
        var temp = list.sortedBy((e) => e[keyId]);
        TypeData typeData = itemSort.line.typeData;
        if (typeData == null) {
          /// If you have at least one string, consider everything as a string
          /// The other types of data require that they all have the same type
          if (list.any((element) => element[itemSort.line.key] is String)) {
            typeData = TDString();
          } else if (list
              .every((element) => element[itemSort.line.key] is num)) {
            typeData = TDNumber();
          } else if (list
              .every((element) => element[itemSort.line.key] is bool)) {
            typeData = TDBoolean();
          } else {
            typeData = TDNotString();
          }

          // Save the data type so you don't need to scroll through the list again
          itemSort.line.typeData = typeData;
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
      if (itemSort.line.defaultValue != null) {
        if (itemSort.typeSort == EnumTypeSort.ASC) {
          return temp.sortedBy((e) {
            String v = e[itemSort.line.key]?.toString()?.toLowerCase()?.trim();
            if (v.isNullOrEmpty) {
              return itemSort.line.defaultValue(e) ?? defaultValue;
            } else
              return v;
          });
        } else {
          return temp.sortedByDesc((e) {
            String v = e[itemSort.line.key]?.toString()?.toLowerCase()?.trim();
            if (v.isNullOrEmpty) {
              return itemSort.line.defaultValue(e) ?? defaultValue;
            } else
              return v;
          });
        }
      } else {
        if (itemSort.typeSort == EnumTypeSort.ASC) {
          return temp.sortedBy((e) =>
              e[itemSort.line.key]?.toString()?.toLowerCase()?.trim() ??
              defaultValue);
        } else {
          return temp.sortedByDesc((e) =>
              e[itemSort.line.key]?.toString()?.toLowerCase()?.trim() ??
              defaultValue);
        }
      }
    }
    if (itemSort.line.defaultValue != null) {
      if (itemSort.typeSort == EnumTypeSort.ASC) {
        return temp.sortedBy((e) =>
            e[itemSort.line.key] ??
            itemSort.line.defaultValue(e) ??
            defaultValue);
      } else {
        return temp.sortedByDesc((e) =>
            e[itemSort.line.key] ??
            itemSort.line.defaultValue(e) ??
            defaultValue);
      }
    } else {
      if (itemSort.typeSort == EnumTypeSort.ASC) {
        return temp.sortedBy((e) => e[itemSort.line.key] ?? defaultValue);
      } else {
        return temp.sortedByDesc((e) => e[itemSort.line.key] ?? defaultValue);
      }
    }
  }
}

typedef FontDataAnyInterface = Future<List<Map>> Function(dynamic data);

class FontDataAny extends DataSourceAny {
  FontDataAnyInterface fontData;
  FontDataAny(this.fontData, {supportSingleLineFilter = true})
      : super(supportSingleLineFilter: supportSingleLineFilter);

  @override
  Future fetchData(int limit, int offset, SelectModel selectModel,
      {Map data}) async {
    listAll = await fontData(data);
    return;
  }
}
