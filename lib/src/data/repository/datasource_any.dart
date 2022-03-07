import 'package:diacritic/diacritic.dart';
import 'package:msk_utils/msk_utils.dart';
import 'package:select_any/select_any.dart';

abstract class DataSourceAny extends DataSource {
  List<Map<String, dynamic>>? listAll;
  ItemSort? _currentSort;

  DataSourceAny(
      {String? id,
      bool allowExport = true,
      bool supportSingleLineFilter = true})
      : super(
            id: id,
            allowExport: allowExport,
            supportSingleLineFilter: supportSingleLineFilter);

  @override
  Future<Stream<ResponseDataDataSource>> getList(
    int limit,
    int offset,
    SelectModel? selectModel, {
    Map? data,
    bool refresh = false,
    ItemSort? itemSort,
    GroupFilterExp? filter,
  }) async {
    if (listAll == null ||
        listAll!.isEmpty ||
        refresh == true ||
        // Caso o itemSort tenha sido anulado, atualiza a lista para restaurar a formatação padrão
        (itemSort == null && _currentSort != null)) {
      listAll?.clear();
      listAll = await fetchData(limit, offset, selectModel, data: data);
    }

    if (itemSort != _currentSort) {
      listAll = applySort(itemSort, selectModel!.id, listAll);
    }

    List<Map<String, dynamic>> tempList = applyFilters(listAll!, filter);
    List<Map<String, dynamic>> subList = getSubList(offset, limit, tempList);
    return Stream.value(ResponseDataDataSource(
        total: tempList.length,
        data: generateList(subList, offset, selectModel!),
        start: offset,
        end: offset + limit));
  }

  List<Map<String, dynamic>> applyFilters(
      List<Map<String, dynamic>> listAll, GroupFilterExp? filter) {
    List<Map<String, dynamic>> tempList = [];
    filter = convertFiltersToLowerCase(filter);
    if (filter != null && filter.filterExps.isNotEmpty) {
      for (int i = 0; i < listAll.length; i++) {
        if (applyGroupFilterExp(filter, listAll[i])) {
          tempList.add(listAll[i]);
        }
      }
    } else {
      tempList = listAll;
    }
    return tempList;
  }

  List<Map<String, dynamic>> getSubList(
      int offset, int limit, List<Map<String, dynamic>>? tempList) {
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
  Future<Stream<ResponseDataDataSource>> getListSearch(
      String text, int limit, int offset, SelectModel? selectModel,
      {Map? data,
      bool? refresh = false,
      TypeSearch typeSearch = TypeSearch.CONTAINS,
      ItemSort? itemSort}) async {
    if (listAll == null || listAll!.isEmpty || refresh == true) {
      listAll = await fetchData(limit, offset, selectModel, data: data);
    }
    List<Map<String, dynamic>>? tempList =
        applyFilterList(typeSearch, listAll!, text);

    tempList = applySort(itemSort, selectModel!.id, tempList);

    List<Map<String, dynamic>> subList = getSubList(offset, limit, tempList);
    return Stream.value(ResponseDataDataSource(
        total: tempList!.length,
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
        for (var value in list[i].values) {
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
          tempList.add(list[i]);
        }
      } else {
        for (var value in list[i].values) {
          if (value != null) {
            if (filterByTypeSearch(typeSearch, value, text)) {
              tempList.add(list[i]);
              break;
            }
          }
        }
      }
    }
    return tempList;
  }

  Future exportData(SelectModel? selectModel, bool onlyFiltered,
      GroupFilterExp filter, String textSearch, TypeSearch typeSearch) async {
    StringBuffer stringBuffer = StringBuffer();
    List<Map<String, dynamic>> data = listAll!;
    if (onlyFiltered) {
      if (!textSearch.isNullOrBlank) {
        data = applyFilterList(typeSearch, listAll!, textSearch);
      }
      data = applyFilters(data, filter);
    }
    if (data.isNotEmpty) {
      for (var key in data.first.keys) {
        stringBuffer
          ..write(key)
          ..write(';');
      }
      stringBuffer.write('\n');
    }
    for (var item in data) {
      for (MapEntry entry in item.entries) {
        Line? line = selectModel?.lines
            .firstWhereOrNull((element) => element.key == entry.key);
        var value = entry.value;
        if (line != null && line.formatData != null) {
          value = line.formatData!
              .formatData(ObjFormatData(data: value, map: item));
        }
        stringBuffer
          ..write(value)
          ..write(';');
      }
      stringBuffer.write('\n');
    }
    UtilsFile.saveFileString(stringBuffer.toString(),
        dirComplementar: '${selectModel!.title}',
        fileName: '${DateTime.now().string('dd-MM-yyyy HH-mm-ss')}.csv');
    return;
  }

  Future<List<Map<String, dynamic>>?> fetchData(
      int? limit, int offset, SelectModel? selectModel,
      {Map? data});

  @override
  Future clear() async {
    listAll = null;
    return;
  }

  bool applyGroupFilterExp(
      GroupFilterExp groupFilterExp, Map<String, dynamic> map) {
    bool? filterAndOk;
    for (var filter in groupFilterExp.filterExps) {
      if (groupFilterExp.operatorEx == OperatorFilterEx.OR) {
        /// Como é uma expressão or, caso esse filtro seja verdadeiro sempre retorna true

        if (filter is FilterExpColumn) {
          var value = map[filter.line!.key];
          if (filter.line!.formatData != null) {
            value = filter.line!.formatData!
                .formatData(ObjFormatData(data: value, map: map));
          }
          if (filterByTypeSearch(filter.typeSearch, value, filter.value)) {
            return true;
          }
        } else if (filter is FilterSelectColumn) {
          var value = map[filter.line!.key];
          if (filter.line!.formatData != null) {
            value = filter.line!.formatData!
                .formatData(ObjFormatData(data: value, map: map));
          }
          if (filterByTypeSearch(filter.typeSearch, value, filter.value)) {
            return true;
          }
        } else if (filter is FilterExpRangeCollun) {
          if (map[filter.line!.key] != null &&
              map[filter.line!.key] >
                  (filter.dateStart?.millisecondsSinceEpoch ?? 0) &&
              map[filter.line!.key] <
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
          var value = map[filter.line!.key];
          if (filter.line!.formatData != null) {
            value = filter.line!.formatData!
                .formatData(ObjFormatData(data: value, map: map));
          }
          if (filterByTypeSearch(filter.typeSearch, value, filter.value)) {
            filterAndOk = true;
          } else {
            return false;
          }
        } else if (filter is FilterSelectColumn) {
          var value = map[filter.line!.key];
          if (filter.line!.formatData != null) {
            value = filter.line!.formatData!
                .formatData(ObjFormatData(data: value, map: map));
          }
          if (filterByTypeSearch(filter.typeSearch, value, filter.value)) {
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
          if (map[filter.line!.key] != null &&
              map[filter.line!.key] >
                  (filter.dateStart?.millisecondsSinceEpoch ?? 0) &&
              map[filter.line!.key] <
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

  List<Map<String, dynamic>>? applySort(
      ItemSort? itemSort, String keyId, List<Map<String, dynamic>>? list) {
    _currentSort = itemSort;
    try {
      if (itemSort != null && list != null && list.isNotEmpty) {
        final TypeData? typeData = itemSort.line?.typeData;

        /// Maintain a consistent order for the list
        Iterable<Map<String, dynamic>> temp;
        if (typeData is TDBoolean) {
          temp = list.sortedBy((e) => e![keyId] == true ? 1 : 0);
        } else {
          temp = list.sortedBy((e) => e![keyId]);
        }

        if (typeData is TDString || typeData is TDNotString) {
          list = _sort(temp as List<Map<String, dynamic>>, itemSort, '',
              typeData: typeData);
        } else if (typeData is TDNumber) {
          list = _sort(temp as List<Map<String, dynamic>>, itemSort, 0,
              typeData: typeData);
        } else if (typeData is TDBoolean) {
          list = _sort(temp as List<Map<String, dynamic>>, itemSort, false,
              typeData: typeData);
        } else if (typeData is TDDateTimestamp) {
          list = _sort(temp as List<Map<String, dynamic>>, itemSort, 0,
              typeData: typeData);
        } else if (typeData is TDDateString) {
          list = _sort(temp as List<Map<String, dynamic>>, itemSort, '',
              typeData: typeData);
        } else {
          list = _sort(temp as List<Map<String, dynamic>>, itemSort, null,
              typeData: typeData);
        }
      }
    } catch (error, stackTrace) {
      UtilsSentry.reportError(error, stackTrace);
    }
    return list;
  }

  static List<Map<String, dynamic>> _sort(
      List<Map<String, dynamic>> temp, ItemSort itemSort, dynamic defaultValue,
      {TypeData? typeData}) {
    // Apply special string formatting
    if (typeData is TDString || typeData is TDNotString) {
      if (itemSort.line!.defaultValue != null) {
        if (itemSort.typeSort == EnumTypeSort.ASC) {
          return temp.sortedBy((e) {
            String? v = e![itemSort.line!.key]?.toString().toLowerCase().trim();
            if (v.isNullOrEmpty) {
              return itemSort.line!.defaultValue!(e);
            } else
              return v;
          }) as List<Map<String, dynamic>>;
        } else {
          return temp.sortedByDesc((e) {
            String? v = e![itemSort.line!.key]?.toString().toLowerCase().trim();
            if (v.isNullOrEmpty) {
              return itemSort.line!.defaultValue!(e);
            } else
              return v;
          }) as List<Map<String, dynamic>>;
        }
      } else {
        if (itemSort.typeSort == EnumTypeSort.ASC) {
          return temp.sortedBy((e) =>
              e![itemSort.line!.key]?.toString().toLowerCase().trim() ??
              defaultValue) as List<Map<String, dynamic>>;
        } else {
          return temp.sortedByDesc((e) =>
              e![itemSort.line!.key]?.toString().toLowerCase().trim() ??
              defaultValue) as List<Map<String, dynamic>>;
        }
      }
    } else {
      if (typeData is TDBoolean) {
        if (itemSort.typeSort == EnumTypeSort.ASC) {
          return temp.sortedBy((e) => (e![itemSort.line!.key] ??
                      itemSort.line!.defaultValue?.call(e) ??
                      defaultValue) ==
                  true
              ? 1
              : 0) as List<Map<String, dynamic>>;
        } else {
          return temp.sortedByDesc((e) => (e![itemSort.line!.key] ??
                      itemSort.line!.defaultValue?.call(e) ??
                      defaultValue) ==
                  true
              ? 1
              : 0) as List<Map<String, dynamic>>;
        }
      } else {
        if (itemSort.typeSort == EnumTypeSort.ASC) {
          return temp.sortedBy((e) =>
              e![itemSort.line!.key] ??
              itemSort.line!.defaultValue?.call(e) ??
              defaultValue) as List<Map<String, dynamic>>;
        } else {
          return temp.sortedByDesc((e) =>
              e![itemSort.line!.key] ??
              itemSort.line!.defaultValue?.call(e) ??
              defaultValue) as List<Map<String, dynamic>>;
        }
      }
    }
  }
}

typedef FontDataAnyInterface = Future<List<Map<String, dynamic>>> Function(
    dynamic data);

class FontDataAny extends DataSourceAny {
  FontDataAnyInterface fontData;
  FontDataAny(this.fontData,
      {bool supportSingleLineFilter = true, bool allowExport = true})
      : super(
            supportSingleLineFilter: supportSingleLineFilter,
            allowExport: allowExport);

  @override
  Future<List<Map<String, dynamic>>?> fetchData(
      int? limit, int offset, SelectModel? selectModel,
      {Map? data}) async {
    listAll = await fontData(data);
    return listAll;
  }
}
