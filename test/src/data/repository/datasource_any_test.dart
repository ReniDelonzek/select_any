import 'package:flutter_test/flutter_test.dart';
import 'package:msk_utils/extensions/string.dart';
import 'package:select_any/select_any.dart';

void main() {
  group('FontDataAny', () {
    final totalLenth = 50;
    List<Map<String, dynamic>> data1 = List.generate(
        totalLenth,
        (index) => {
              'id': index,
              'intValue': index,
              'stringValue': 'string$index',
              'boolValue': index % 2 == 0,
              'dateStringValue':
                  '2020-01-01 00:00:${index.toString().addZeros(2 - index.toString().length)}',
              'dateIntValue': DateTime.now().millisecondsSinceEpoch
            });
    FontDataAny dataSourceAny = FontDataAny((_) async => data1);
    SelectModel selectModel = SelectModel(
        'title', 'id', [Line('intValue')], dataSourceAny, TypeSelect.SIMPLE);
    test('Teste recuperação dados', () async {
      // Lista deve ficar vazia no início
      expect(dataSourceAny.listAll, isNull);
      ResponseDataDataSource responseDataDataSource =
          await (await dataSourceAny.getList(totalLenth, -1, selectModel))
              .first;
      expect(responseDataDataSource.data.length, totalLenth);
      expect(responseDataDataSource.data.map((e) => e.object).toList(), data1);
      expect(responseDataDataSource.data.map((e) => e.object).toList(),
          dataSourceAny.listAll);
      dataSourceAny.clear();
      expect(dataSourceAny.listAll, isNull);
      var result2 = await dataSourceAny.fetchData(10, -1, selectModel);
      expect(dataSourceAny.listAll, result2);
      expect(await dataSourceAny.fontData({}), dataSourceAny.listAll);
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
  });
}
