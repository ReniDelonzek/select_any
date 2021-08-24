import 'package:select_any/select_any.dart';

class UtilsFilter {
  static getSQLWhereFromGroupFilter(GroupFilterExp groupFilterExp,
      {bool includeAndOperatorIfNotEmpty = false}) {
    if (groupFilterExp.filterExps.isEmpty) return '';
    switch (groupFilterExp.operatorEx) {
      case OperatorFilterEx.AND:
        return '${includeAndOperatorIfNotEmpty ? ' AND ' : ''}(${groupFilterExp.filterExps.map((e) => '${_getSQLWhereFromFilter(e)}').toList().join(' AND ')})';
        break;
      case OperatorFilterEx.OR:
        return '${includeAndOperatorIfNotEmpty ? ' AND ' : ''}(${groupFilterExp.filterExps.map((e) => '${_getSQLWhereFromFilter(e)}').toList().join(' OR ')})';
        break;
    }
  }

  static _getSQLWhereFromFilter(FilterExp filterExp) {
    if (filterExp is GroupFilterExp) {
      return _getSQLWhereFromFilter(filterExp);
    } else if (filterExp is FilterSelectColumn) {
      if (filterExp.customKey != null) {
        String key = filterExp.customKey;
        switch (filterExp.typeSearch) {
          case TypeSearch.CONTAINS:
            return '$key = ${filterExp.valueId}';
          case TypeSearch.BEGINSWITH:
            return '$key = ${filterExp.valueId}';
            break;
          case TypeSearch.ENDSWITH:
            return '$key = ${filterExp.valueId}';
            break;
          case TypeSearch.NOTCONTAINS:
            return '$key != ${filterExp.valueId}';
            break;
        }
      } else {
        switch (filterExp.typeSearch) {
          case TypeSearch.CONTAINS:
            return '${filterExp.line.key} = "${filterExp.value}" COLLATE NOCASE ';
          case TypeSearch.BEGINSWITH:
            return '${filterExp.line.key} LIKE "${filterExp.value}%"';
            break;
          case TypeSearch.ENDSWITH:
            return '${filterExp.line.key} LIKE "%${filterExp.value}"';
            break;
          case TypeSearch.NOTCONTAINS:
            return '${filterExp.line.key} != "${filterExp.value}" COLLATE NOCASE ';
            break;
        }
      }
    } else if (filterExp is FilterExpColumn) {
      switch (filterExp.typeSearch) {
        case TypeSearch.CONTAINS:
          return '${filterExp.line.key} LIKE "%${filterExp.value}%"';
        case TypeSearch.BEGINSWITH:
          return '${filterExp.line.key} LIKE "${filterExp.value}%"';
          break;
        case TypeSearch.ENDSWITH:
          return '${filterExp.line.key} LIKE "%${filterExp.value}"';
          break;
        case TypeSearch.NOTCONTAINS:
          return '${filterExp.line.key} != "${filterExp.value}"';
          break;
      }
    } else if (filterExp is FilterExpRangeCollun) {
      return '${filterExp.line.key} BETWEN ${filterExp.dateStart?.millisecondsSinceEpoch ?? 0} AND ${filterExp.dateEnd?.millisecondsSinceEpoch ?? double.maxFinite.toInt()}';
    }
  }
}
