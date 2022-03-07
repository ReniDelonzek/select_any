import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/select_any.dart';

void main() {
  group('Test UtilsFilter', () {
    test('Test throw', () {
      expect(
          () => UtilsFilter.addFilterToSQL(
              'select 1 from table',
              GroupFilterExp(operatorEx: OperatorFilterEx.AND, filterExps: [
                FilterExpColumn(line: Line('key'), value: '1'),
                FilterExpColumn(line: Line('key2'), value: '2'),
              ])),
          throwsAssertionError);
      // Keys duplicadas
      expect(
          () => UtilsFilter.addFilterToSQL(
              'select 1 from table where 1 = 1',
              GroupFilterExp(operatorEx: OperatorFilterEx.AND, filterExps: [
                FilterExpColumn(line: Line('key'), value: '1'),
                FilterExpColumn(line: Line('key'), value: '2'),
              ])),
          throwsAssertionError);
    });
    var res = UtilsFilter.addFilterToSQL(
        'select 1 from table where 1 = 1',
        GroupFilterExp(operatorEx: OperatorFilterEx.AND, filterExps: [
          FilterExpColumn(line: Line('key'), value: '1'),
          FilterExpColumn(line: Line('key2'), value: '2'),
        ]));
    test('Test AND', () {
      expect(res.query.contains('key LIKE \$1 AND key2 LIKE \$2'), true);
      expect(res.query.contains('key LIKE \$1 OR key2 LIKE \$2'), false);
      expect(res.args, ['%1%', '%2%']);
    });

    test('Test OR', () {
      // OR
      res = UtilsFilter.addFilterToSQL(
          'select 1 from table where 1 = 1',
          GroupFilterExp(operatorEx: OperatorFilterEx.OR, filterExps: [
            FilterExpColumn(line: Line('key'), value: '1'),
            FilterExpColumn(line: Line('key2'), value: '2'),
          ]));
      expect(res.query.contains('key LIKE \$1 AND key2 LIKE \$2'), false);
      expect(res.query.contains('key LIKE \$1 OR key2 LIKE \$2'), true);
      expect(res.args, ['%1%', '%2%']);
    });

    test('Test many args', () {
      // OR
      res = UtilsFilter.addFilterToSQL(
          'select 1 from table where 1 = 1',
          GroupFilterExp(operatorEx: OperatorFilterEx.AND, filterExps: [
            FilterExpColumn(line: Line('key'), value: '1'),
            FilterExpColumn(line: Line('key2'), value: 2),
            FilterExpColumn(line: Line('key3'), value: 'test'),
            FilterExpColumn(line: Line('key4'), value: 'false'),
          ]));
      print(res.query);
      expect(
          res.query.contains(
              'key LIKE \$1 AND key2 LIKE \$2 AND key3 LIKE \$3 AND key4 LIKE \$4'),
          true);
      expect(res.args, ['%1%', '%2%', '%test%', '%false%']);
    });

    test('Test OR', () {
      // OR
      res = UtilsFilter.addFilterToSQL(
          'select 1 from table where 1 = 1',
          GroupFilterExp(operatorEx: OperatorFilterEx.OR, filterExps: [
            FilterExpColumn(
                line: Line('key'), value: '1', typeSearch: TypeSearch.CONTAINS),
            FilterExpColumn(
                line: Line('key2'),
                value: '2',
                typeSearch: TypeSearch.BEGINSWITH),
            FilterExpColumn(
                line: Line('key3'),
                value: '3',
                typeSearch: TypeSearch.ENDSWITH),
            FilterExpColumn(
                line: Line('key4'),
                value: '4',
                typeSearch: TypeSearch.NOTCONTAINS),
          ]));
      print(res.args);
      expect(
          res.query.contains(
              'key LIKE \$1 OR key2 LIKE \$2 OR key3 LIKE \$3 OR key4 != \$4'),
          true);
      expect(res.args, ['%1%', '2%', '%3', '4']);
    });
  });
}
