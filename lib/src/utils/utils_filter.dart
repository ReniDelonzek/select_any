import 'package:msk_utils/extensions/string.dart';
import 'package:select_any/select_any.dart';

class SqlFilter {
  String query;
  List args;
  SqlFilter({
    this.query,
    this.args,
  });
}

class UtilsFilter {
  static SqlFilter addFilterToSQL(String query, GroupFilterExp groupFilterExp) {
    /// Usa toString para criar uma nova string
    query = query.toString().toUpperCase();

    SqlFilter sqfFilterWhere =
        _getSQLFromGroupFilter(groupFilterExp, false, []);
    query = query.replaceAll('WHERE', 'WHERE ${sqfFilterWhere.query} AND ');

    SqlFilter sqfFilterGroupBy =
        _getSQLFromGroupFilter(groupFilterExp, true, sqfFilterWhere.args);
    query = query.replaceAll('\$HAVING', 'HAVING ${sqfFilterGroupBy.query} ');

    return SqlFilter(query: query, args: sqfFilterGroupBy.args);
  }

  static SqlFilter _getSQLFromGroupFilter(
      GroupFilterExp groupFilterExp, bool isAgregate, List args) {
    if (groupFilterExp.filterExps
        .where((element) => isAgregate == element.line.isAgregate)
        .isEmpty) {
      args.add(1);
      return SqlFilter(query: '1 = \$${args.length}', args: args);
    }

    SqlFilter filter = SqlFilter(args: args, query: '');
    switch (groupFilterExp.operatorEx) {
      case OperatorFilterEx.AND:
        groupFilterExp.filterExps
            .where((element) => isAgregate == element.line.isAgregate)
            .forEach((element) {
          SqlFilter local = _getSQLWhereFromFilter(element, filter.args);
          filter.args = local.args;
          if (filter.query.isNotEmpty) {
            filter.query += ' AND ';
          }
          filter.query += local.query;
        });
        break;
      case OperatorFilterEx.OR:
        groupFilterExp.filterExps
            .where((element) => !element.line.isAgregate)
            .forEach((element) {
          SqlFilter local = _getSQLWhereFromFilter(element, filter.args);
          filter.args = local.args;
          if (filter.query.isNotEmpty) {
            filter.query += ' OR ';
          }
          filter.query += local.query;
        });
        break;
    }
    return filter;
  }

  static SqlFilter _getSQLWhereFromFilter(FilterExp filterExp, List args) {
    if (filterExp is GroupFilterExp) {
      return _getSQLWhereFromFilter(filterExp, args);
    } else if (filterExp is FilterSelectColumn) {
      if (filterExp.customKey != null) {
        String key = filterExp.customKey;
        switch (filterExp.typeSearch) {
          case TypeSearch.CONTAINS:
            args.add('${filterExp.valueId}');
            return SqlFilter(query: '$key = \$${args.length}', args: args);

          case TypeSearch.BEGINSWITH:
            args.add('${filterExp.valueId}');
            //return SqlFilter(query: , args: args);
            return SqlFilter(query: '$key = \$${args.length}', args: args);

          case TypeSearch.ENDSWITH:
            args.add('${filterExp.valueId}');
            return SqlFilter(query: '$key = \$${args.length}', args: args);

          case TypeSearch.NOTCONTAINS:
            args.add('${filterExp.valueId}');
            return SqlFilter(query: '$key != \$${args.length}', args: args);
        }
      } else {
        switch (filterExp.typeSearch) {
          case TypeSearch.CONTAINS:
            args.add('${filterExp.value}');
            return SqlFilter(
                query:
                    '${filterExp.line.key} = \$${args.length} COLLATE NOCASE ',
                args: args);
          case TypeSearch.BEGINSWITH:
            args.add('${filterExp.value}%');
            return SqlFilter(
                query:
                    '${filterExp.line.key} LIKE \$${args.length} COLLATE NOCASE ',
                args: args);
            break;
          case TypeSearch.ENDSWITH:
            args.add('%${filterExp.value}');
            return SqlFilter(
                query:
                    '${filterExp.line.key} LIKE \$${args.length} COLLATE NOCASE ',
                args: args);
            break;
          case TypeSearch.NOTCONTAINS:
            args.add('${filterExp.value}');
            return SqlFilter(
                query:
                    '${filterExp.line.key} != \$${args.length} COLLATE NOCASE ',
                args: args);
            break;
        }
      }
    } else if (filterExp is FilterExpColumn) {
      if (filterExp.line.typeData is TDNumber) {
        /// Excepcionalmente aqui, passar o valor diretamente na query,
        /// deixar para passar o valor por parâmetro faz a query não funcionar corretamente
        /// Não tem problema de injeção de dependência pois o valor é num
        ///
        /// Faz um parse para int/double para garantir que n seja uma string
        String v = filterExp.value.toString().replaceAll(',', '.');
        if (v.contains('.')) {
          v = '"%${v.toDouble()}%"';
        } else {
          v = '"%${v.toInt()}%"';
        }
        return SqlFilter(
            query: 'CAST(${filterExp.line.key} AS TEXT) LIKE $v', args: args);
      } else
        switch (filterExp.typeSearch) {
          case TypeSearch.CONTAINS:
            args.add('%${filterExp.value}%');
            return SqlFilter(
                query: '${filterExp.line.key} LIKE \$${args.length}',
                args: args);
          case TypeSearch.BEGINSWITH:
            args.add('${filterExp.value}%');
            return SqlFilter(
                query: '${filterExp.line.key} LIKE \$${args.length}',
                args: args);
          case TypeSearch.ENDSWITH:
            args.add('%${filterExp.value}');
            return SqlFilter(
                query: '${filterExp.line.key} LIKE \$${args.length}',
                args: args);
          case TypeSearch.NOTCONTAINS:
            args.add('${filterExp.value}');
            return SqlFilter(
                query: '${filterExp.line.key} != \$${args.length}', args: args);
        }
    } else if (filterExp is FilterExpRangeCollun) {
      args.add(filterExp.dateStart?.millisecondsSinceEpoch ?? 0);
      args.add(filterExp.dateEnd?.millisecondsSinceEpoch ??
          double.maxFinite.toInt());
      return SqlFilter(
          query:
              '${filterExp.line.key} BETWEEN \$${args.length - 1} AND \$${args.length}',
          args: args);
    }
    args.add(1);
    return SqlFilter(query: '1 = \$${args.length}', args: args);
  }
}
