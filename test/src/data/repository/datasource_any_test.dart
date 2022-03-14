import 'package:flutter_test/flutter_test.dart';
import 'package:msk_utils/msk_utils.dart';
import 'package:select_any/select_any.dart';

void main() {
  // Valores maiores que 99 podem quebrar alguns testes
  final totalLenth = 50;
  List<Map<String, dynamic>> data1 = List.generate(totalLenth, (index) {
    String valueD = index.toString().addZeros(2 - index.toString().length);
    return {
      'id': index,
      'intValue': index,
      'stringValue': 'string$valueD',
      'boolValue': index % 2 == 0,
      'dateStringValue': '2020-01-01 00:00:$valueD',
      'dateIntValue': DateTime.now().millisecondsSinceEpoch,
      'stringValue2': '${valueD}string2$valueD',
    };
  });
  FontDataAny dataSourceAny = FontDataAny((_) async => data1);
  SelectModel selectModel = SelectModel(
      'title', 'id', [Line('intValue')], dataSourceAny, TypeSelect.SIMPLE);
  group('FontDataAny', () {
    test('Test recovery data', () async {
      expect(dataSourceAny.listAll, isNull);
      var result2 = await dataSourceAny.fetchData(10, -1, selectModel);
      expect(dataSourceAny.listAll, result2);
      expect(await dataSourceAny.fontData({}), dataSourceAny.listAll);
    });
  });

  group('DataSourceAny', () {
    test('Test recovery data', () async {
      // Limpar lista
      dataSourceAny.clear();
      expect(dataSourceAny.listAll, isNull);
      ResponseDataDataSource responseDataDataSource =
          await (await dataSourceAny.getList(totalLenth, -1, selectModel))
              .first;
      expect(responseDataDataSource.data.length, totalLenth);
      expect(responseDataDataSource.data.map((e) => e.object).toList(), data1);
      expect(responseDataDataSource.data.map((e) => e.object).toList(),
          dataSourceAny.listAll);
    });
    test('Test applyFilter', () async {
      var result = await dataSourceAny.fetchData(10, -1, selectModel);
      expect(
          dataSourceAny
              .applyFilters(
                  result!,
                  GroupFilterExp(operatorEx: OperatorFilterEx.AND, filterExps: [
                    FilterExpColumn(
                        line: Line('stringValue'),
                        value: 'string10',
                        typeSearch: TypeSearch.CONTAINS)
                  ]))
              .length,
          1);
      expect(
          dataSourceAny
              .applyFilters(
                  result,
                  GroupFilterExp(operatorEx: OperatorFilterEx.AND, filterExps: [
                    FilterExpColumn(
                        line: Line('boolValue'),
                        value: 'true',
                        typeSearch: TypeSearch.CONTAINS)
                  ]))
              .length,

          /// No método de geração de dados, metade dos registros vão ser true
          result.length ~/ 2);
      expect(
          dataSourceAny
              .applyFilters(
                  result,
                  GroupFilterExp(operatorEx: OperatorFilterEx.AND, filterExps: [
                    FilterExpColumn(
                        line: Line('dateStringValue'),
                        value: '2020-01-01 00:00:0',
                        typeSearch: TypeSearch.BEGINSWITH)
                  ]))
              .length,
// resultados que comecem com 00:00:0x
          totalLenth > 10 ? 10 : totalLenth);

      expect(
          dataSourceAny
              .applyFilters(
                  result,
                  GroupFilterExp(operatorEx: OperatorFilterEx.AND, filterExps: [
                    FilterExpColumn(
                        line: Line('dateStringValue'),
                        value: '2020-01-01 00:00:00',
                        typeSearch: TypeSearch.ENDSWITH)
                  ]))
              .length,
          1);
      expect(
          dataSourceAny
              .applyFilters(
                  result,
                  GroupFilterExp(operatorEx: OperatorFilterEx.AND, filterExps: [
                    FilterExpColumn(
                        line: Line('dateStringValue'),
                        value: '2020-01-01 00:00:00',
                        typeSearch: TypeSearch.NOTCONTAINS)
                  ]))
              .length,
          totalLenth - 1);
      // AND TWO columns
      expect(
          dataSourceAny
              .applyFilters(
                  result,
                  GroupFilterExp(operatorEx: OperatorFilterEx.AND, filterExps: [
                    FilterExpColumn(
                        line: Line('stringValue'),
                        value: 'string10',
                        typeSearch: TypeSearch.CONTAINS),
                    FilterExpColumn(
                        line: Line('intValue'),
                        value: '10',
                        typeSearch: TypeSearch.CONTAINS),
                  ]))
              .length,
          1);
      expect(
          dataSourceAny
              .applyFilters(
                  result,
                  GroupFilterExp(operatorEx: OperatorFilterEx.AND, filterExps: [
                    FilterExpColumn(
                        line: Line('stringValue'),
                        value: 'string10',
                        typeSearch: TypeSearch.CONTAINS),
                    FilterExpColumn(
                        line: Line('intValue'),
                        value: '11',
                        typeSearch: TypeSearch.CONTAINS),
                  ]))
              .length,
          0);

      expect(
          dataSourceAny
              .applyFilters(
                  result,
                  GroupFilterExp(operatorEx: OperatorFilterEx.OR, filterExps: [
                    FilterExpColumn(
                        line: Line('stringValue'),
                        value: 'string10',
                        typeSearch: TypeSearch.CONTAINS),
                  ]))
              .length,
          1);

      // Test OR TWO
      expect(
          dataSourceAny
              .applyFilters(
                  result,
                  GroupFilterExp(operatorEx: OperatorFilterEx.OR, filterExps: [
                    FilterExpColumn(
                        line: Line('stringValue'),
                        value: 'string10',
                        typeSearch: TypeSearch.CONTAINS),
                    FilterExpColumn(
                        line: Line('intValue'),
                        value: '11',
                        typeSearch: TypeSearch.CONTAINS),
                  ]))
              .length,
          2);
    });
    test('Test applySort', () {
      // Number
      expect(
          dataSourceAny
              .applySort(
                  ItemSort(
                      typeSort: EnumTypeSort.ASC,
                      line: Line('id', typeData: TDNumber())),
                  'id',
                  new List.from(data1))!
              .first['id'],
          0);
      expect(
          dataSourceAny
              .applySort(
                  ItemSort(
                      typeSort: EnumTypeSort.DESC,
                      line: Line('id', typeData: TDNumber())),
                  'id',
                  new List.from(data1))!
              .first['id'],
          data1.last['id']);
      // String
      expect(
          dataSourceAny
              .applySort(
                  ItemSort(
                      typeSort: EnumTypeSort.ASC,
                      line: Line('stringValue', typeData: TDString())),
                  'stringValue',
                  new List.from(data1))!
              .first['stringValue'],
          data1.first['stringValue']);

      expect(
          dataSourceAny
              .applySort(
                  ItemSort(
                      typeSort: EnumTypeSort.DESC,
                      line: Line('stringValue', typeData: TDString())),
                  'stringValue',
                  new List.from(data1))!
              .first['stringValue'],
          data1.last['stringValue']);
      // Bool
      expect(
          dataSourceAny
              .applySort(
                  ItemSort(
                      typeSort: EnumTypeSort.ASC,
                      line: Line('boolValue', typeData: TDBoolean())),
                  'boolValue',
                  new List.from(data1))!
              .first['boolValue'],
          false);

      expect(
          dataSourceAny
              .applySort(
                  ItemSort(
                      typeSort: EnumTypeSort.DESC,
                      line: Line('boolValue', typeData: TDBoolean())),
                  'boolValue',
                  new List.from(data1))!
              .first['boolValue'],
          true);
      // DateTimeString
      expect(
          dataSourceAny
              .applySort(
                  ItemSort(
                      typeSort: EnumTypeSort.ASC,
                      line: Line('dateStringValue', typeData: TDDateString())),
                  'dateStringValue',
                  new List.from(data1))!
              .first['dateStringValue'],
          data1.first['dateStringValue']);

      expect(
          dataSourceAny
              .applySort(
                  ItemSort(
                      typeSort: EnumTypeSort.DESC,
                      line: Line('dateStringValue', typeData: TDDateString())),
                  'dateStringValue',
                  new List.from(data1))!
              .first['dateStringValue'],
          data1.last['dateStringValue']);
      // DateTime
      expect(
          dataSourceAny
              .applySort(
                  ItemSort(
                      typeSort: EnumTypeSort.ASC,
                      line: Line('dateIntValue', typeData: TDDateTimestamp())),
                  'dateIntValue',
                  new List.from(data1))!
              .first['dateIntValue'],
          data1.first['dateIntValue']);

      expect(
          dataSourceAny
              .applySort(
                  ItemSort(
                      typeSort: EnumTypeSort.DESC,
                      line: Line('dateIntValue', typeData: TDDateTimestamp())),
                  'dateIntValue',
                  new List.from(data1))!
              .first['dateIntValue'],
          data1.last['dateIntValue']);
    });

    test('Test getSubList', () {
      /// Caso offset seja -1, não filtra nada
      expect(dataSourceAny.getSubList(-1, 10, data1).length, data1.length);

      expect(dataSourceAny.getSubList(0, 10, data1).length, 10);

      expect(dataSourceAny.getSubList(0, totalLenth + 10, data1).length,
          totalLenth);
    });

    test('Test applyFilterList', () {
      expect(
          dataSourceAny
              .applyFilterList(TypeSearch.CONTAINS, data1, '00string2')
              .length,
          1);
      expect(
          dataSourceAny
              .applyFilterList(TypeSearch.BEGINSWITH, data1, '00string')
              .length,
          1);
      expect(
          dataSourceAny
              .applyFilterList(TypeSearch.ENDSWITH, data1, 'string00')
              .length,
          1);
      expect(
          dataSourceAny
              .applyFilterList(TypeSearch.NOTCONTAINS, data1, '00string200')
              .length,
          totalLenth - 1);
    });
    test('Test applyGroupFilterExp', () {
      expect(
          dataSourceAny.applyGroupFilterExp(
              GroupFilterExp(operatorEx: OperatorFilterEx.AND, filterExps: [
                FilterExpColumn(line: Line('int'), value: 1),
                FilterExpColumn(line: Line('string'), value: 'aaa')
              ]),
              {'int': 1, 'string': 'aaa'}),
          true);
      expect(
          dataSourceAny.applyGroupFilterExp(
              GroupFilterExp(operatorEx: OperatorFilterEx.AND, filterExps: [
                FilterExpColumn(line: Line('int'), value: 1),
                FilterExpColumn(line: Line('string'), value: 'bbb')
              ]),
              {'int': 1, 'string': 'aaa'}),
          false);

      expect(
          dataSourceAny.applyGroupFilterExp(
              GroupFilterExp(operatorEx: OperatorFilterEx.OR, filterExps: [
                FilterExpColumn(line: Line('int'), value: 1),
                FilterExpColumn(line: Line('string'), value: 'bbb')
              ]),
              {'int': 1, 'string': 'aaa'}),
          true);
      expect(
          dataSourceAny.applyGroupFilterExp(
              GroupFilterExp(operatorEx: OperatorFilterEx.OR, filterExps: [
                FilterExpColumn(line: Line('int'), value: 1),
                FilterExpColumn(line: Line('string'), value: 'aaa')
              ]),
              {'int': 1, 'string': 'aaa'}),
          true);
      expect(
          dataSourceAny.applyGroupFilterExp(
              GroupFilterExp(operatorEx: OperatorFilterEx.OR, filterExps: [
                FilterExpColumn(line: Line('int'), value: 2),
                FilterExpColumn(line: Line('string'), value: 'bbb')
              ]),
              {'int': 1, 'string': 'aaa'}),
          false);
    });

    test('Test getListSearch', () async {
      var res = await (await dataSourceAny.getListSearch(
              '00string2', 100, -1, selectModel))
          .first;
      expect(res.data.length, 1);

      // Teste limit
      res = await (await dataSourceAny.getListSearch(
              'string', 10, 0, selectModel))
          .first;
      expect(res.data.length, 10);

      // Teste not contains
      res = await (await dataSourceAny.getListSearch(
              'string', 10, 0, selectModel,
              typeSearch: TypeSearch.NOTCONTAINS))
          .first;
      expect(res.data.length, 0);
    });
  });
}
