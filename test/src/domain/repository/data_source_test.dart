import 'package:flutter_test/flutter_test.dart';
import 'package:msk_utils/msk_utils.dart';
import 'package:select_any/select_any.dart';

void main() {
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
  DataSource dataSourceAny = FontDataAny((_) async => data1);

  test('Test filterByTypeSearch', () {
    expect(
        dataSourceAny.filterByTypeSearch(TypeSearch.CONTAINS, 'folder', 'fol'),
        true);
    expect(
        dataSourceAny.filterByTypeSearch(
            TypeSearch.NOTCONTAINS, 'folder', 'folder'),
        false);
    expect(
        dataSourceAny.filterByTypeSearch(
            TypeSearch.BEGINSWITH, '10 folders', 10),
        true);
    expect(
        dataSourceAny.filterByTypeSearch(
            TypeSearch.BEGINSWITH, '10 folders', 'fol'),
        false);
    expect(
        dataSourceAny.filterByTypeSearch(TypeSearch.ENDSWITH, '10 folders', 10),
        false);
    expect(
        dataSourceAny.filterByTypeSearch(
            TypeSearch.ENDSWITH, '10 folders', 'ers'),
        true);
  });

  group('Test generateList', () {
    test('Test generateList', () {
      List<ItemSelectTable> list = dataSourceAny.generateList(
          data1,
          0,
          SelectModel('title', 'id', [Line('intValue')], dataSourceAny,
              TypeSelect.SIMPLE));
      expect(list.length, data1.length);
      expect(list.first.strings.length, 1);

      /// Todos os objetos são iguais
      expect(
          list.every((element) =>
              element.object ==
              data1.firstWhere((e2) => e2['id'] == element.id)),
          true);

      /// Teste offset
      List<ItemSelectTable> list2 = dataSourceAny.generateList(
          data1,
          10,
          SelectModel('title', 'id', [Line('intValue')], dataSourceAny,
              TypeSelect.SIMPLE));
      expect(list2.any((element) => element.position! < 10), false);

      /// Teste preSelected
      /// showPreSelected true
      List<ItemSelectTable> list3 = dataSourceAny.generateList(
          data1,
          10,
          SelectModel('title', 'id', [Line('intValue')], dataSourceAny,
              TypeSelect.SIMPLE,
              preSelected: [
                ItemSelect(id: 1),
                ItemSelect(id: 2),
                ItemSelect(id: 3),
              ],
              showPreSelected: true));
      expect(list3.where((element) => element.isSelected).length, 3);

      // showPreSelected false
      List<ItemSelectTable> list4 = dataSourceAny.generateList(
          data1,
          10,
          SelectModel('title', 'id', [Line('intValue')], dataSourceAny,
              TypeSelect.SIMPLE,
              preSelected: [
                ItemSelect(id: 1),
                ItemSelect(id: 2),
                ItemSelect(id: 3),
              ],
              showPreSelected: false));
      expect(list4.where((element) => element.isSelected).length, 0);

      /// selectedItens
      List<ItemSelectTable> list5 = dataSourceAny.generateList(
          data1,
          10,
          SelectModel('title', 'id', [Line('intValue')], dataSourceAny,
              TypeSelect.SIMPLE,
              selectedItens: [1, 2, 3], showPreSelected: true));
      expect(list5.where((element) => element.isSelected).length, 3);
    });

    test('Test extract data with /', () {
      ///
      List<ItemSelectTable> list5 = dataSourceAny.generateList(
          List.generate(
              10,
              (index) => {
                    'id': index,
                    'object': {'name': 'Test$index'}
                  }),
          0,
          SelectModel('title', 'id', [Line('object/name')], dataSourceAny,
              TypeSelect.SIMPLE));
      expect(list5.first.strings.values.first, 'Test0');
    });
    test('Test extract list data', () {
      ///
      List<ItemSelectTable> list5 = dataSourceAny.generateList(
          List.generate(
              10,
              (index) => {
                    'id': index,
                    'object': List.generate(
                      3,
                      (index2) => {'name': 'Name$index2'},
                    ),
                    'object2': List.generate(
                      3,
                      (index2) => {
                        'person': {'name': 'PersonName$index2'}
                      },
                    )
                  }),
          0,
          SelectModel(
            'title',
            'id',
            [
              Line('object', listKeys: [Line('name')]),
              Line('object2', listKeys: [Line('person/name')]),
            ],
            dataSourceAny,
            TypeSelect.SIMPLE,
          ));

      /// Teste lista
      expect(list5.first.strings.values.first, 'Name0, Name1, Name2');
      // Teste lista com objeto
      expect(list5.first.strings['object2'],
          'PersonName0, PersonName1, PersonName2');
    });
  });

  test('Test convertFiltersToLowerCase', () {
    expect(dataSourceAny.convertFiltersToLowerCase(null), null);
    expect(
        (dataSourceAny
                .convertFiltersToLowerCase(GroupFilterExp(
                    operatorEx: OperatorFilterEx.AND,
                    filterExps: [
                      FilterExpColumn(line: Line('key'), value: 'STRING')
                    ]))!
                .filterExps
                .first as FilterExpColumn)
            .value,
        'string');
    expect(
        (dataSourceAny
                .convertFiltersToLowerCase(GroupFilterExp(
                    operatorEx: OperatorFilterEx.AND,
                    filterExps: [
                      FilterExpColumn(line: Line('key'), value: 'StRiNg')
                    ]))!
                .filterExps
                .first as FilterExpColumn)
            .value,
        'string');
    expect(
        (dataSourceAny
                .convertFiltersToLowerCase(GroupFilterExp(
                    operatorEx: OperatorFilterEx.AND,
                    filterExps: [
                      FilterExpColumn(line: Line('key'), value: 1)
                    ]))!
                .filterExps
                .first as FilterExpColumn)
            .value,
        1);
  });
}
