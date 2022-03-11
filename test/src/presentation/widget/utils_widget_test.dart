import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/select_any.dart';

void main() {
  List<Map<String, dynamic>> data = List.generate(
    45,
    (index) => {
      'id': index,
      'key': 'key$index',
      'key1': 'key1$index',
      'key2': 'key2$index',
      'key3': 'key3$index',
      'key4': 'key4$index',
      'key5': 'key5$index',
      'key6': 'key6$index',
      'nullValue': null,
      'emptyValue': '',
      'dateValue': DateTime(2020, 01, 01).millisecondsSinceEpoch
    },
  );
  FontDataAny dataSource = FontDataAny((_) async => data);
  testWidgets('Test generateDaraRow', (tester) async {
    SelectModel selectModel = SelectModel(
        'title', 'id', [Line('key')], dataSource, TypeSelect.ACTION);
    List<ItemSelectTable> items =
        dataSource.generateList(data, -1, selectModel);
    await tester.pumpWidget(MaterialApp(
      home: Material(child: Builder(builder: (context) {
        return Scaffold(
          body: DataTable(
            columns: items.first.strings!.keys
                .map((e) => DataColumn(label: Text(e)))
                .toList(),
            rows: [
              UtilsWidget.generateDataRow(selectModel, 0, items.first, context,
                  {}, (item, _, b) {}, () {}, 1, dataSource)
            ],
          ),
        );
      })),
    ));
    DataTable dataTable = tester.widget(find.byType(DataTable));
    expect(dataTable.rows, isNotEmpty);

    expect(dataTable.rows.first.cells.length, selectModel.lines.length);
    expect(dataTable.rows.first.cells.first.child.runtimeType, SelectableText);
  });

  testWidgets('Test generateDataRow with actions', (tester) async {
    SelectModel selectModel = SelectModel(
        'title', 'id', [Line('key')], dataSource, TypeSelect.ACTION,
        actions: [
          ActionSelect(description: 'Test action', icon: Icon(Icons.edit))
        ]);
    List<ItemSelectTable> items =
        dataSource.generateList(data, -1, selectModel);
    await tester.pumpWidget(MaterialApp(
      home: Material(child: Builder(builder: (context) {
        return Scaffold(
          body: DataTable(
            columns: items.first.strings!.keys
                .map((e) => DataColumn(label: Text(e)))
                .toList()
              ..addAll((selectModel.actions
                      ?.map((e) => DataColumn(label: Text(e.description ?? '')))
                      .toList() ??
                  [])),
            rows: [
              UtilsWidget.generateDataRow(selectModel, 0, items.first, context,
                  {}, (item, _, b) {}, () {}, 1, dataSource)
            ],
          ),
        );
      })),
    ));
    DataTable dataTable = tester.widget(find.byType(DataTable));
    expect(dataTable.rows, isNotEmpty);

    expect(dataTable.rows.first.cells.length,
        selectModel.lines.length + (selectModel.actions?.length ?? 0));
    expect(dataTable.rows.first.cells.first.child.runtimeType, SelectableText);
    expect(dataTable.rows.first.cells.last.child.runtimeType, Row);
    for (int i = 0;
        i < (dataTable.rows.first.cells.last.child as Row).children.length;
        i++) {
      Widget element =
          (dataTable.rows.first.cells.last.child as Row).children[i];
      expect(element.runtimeType, IconButton);
      expect(
          (element as IconButton).tooltip, selectModel.actions![i].description);
      expect(element.icon, selectModel.actions![i].icon);
    }
  });
  testWidgets('Test generateDataRow without actions', (tester) async {
    SelectModel selectModel = SelectModel(
        'title', 'id', [Line('key')], dataSource, TypeSelect.ACTION,
        actions: [
          ActionSelect(description: 'Test action', icon: Icon(Icons.edit))
        ]);
    List<ItemSelectTable> items =
        dataSource.generateList(data, -1, selectModel);

    /// Não gerar actions
    await tester.pumpWidget(MaterialApp(
      home: Material(child: Builder(builder: (context) {
        return Scaffold(
          body: DataTable(
            columns: items.first.strings!.keys
                .map((e) => DataColumn(label: Text(e)))
                .toList(),
            rows: [
              UtilsWidget.generateDataRow(selectModel, 0, items.first, context,
                  {}, (item, _, b) {}, () {}, 1, dataSource,
                  generateActions: false)
            ],
          ),
        );
      })),
    ));
    DataTable dataTable = tester.widget(find.byType(DataTable));
    expect(dataTable.rows.first.cells.last.child.runtimeType, isNot(Row));
  });

  test('Test generateDataColumn', () {
    void checkElements(SelectModel selectModel, List<DataColumn> columns) {
      expect(columns.length,
          selectModel.lines.length + (selectModel.actions?.length ?? 0));
      for (int i = 0; i < columns.length; i++) {
        if (i < selectModel.lines.length) {
          expect((columns[i].label as Text).data, selectModel.lines[i].name);
          expect(columns[i].tooltip, selectModel.lines[i].tableTooltip);
          expect((columns[i].label as Text).style,
              selectModel.theme.tableTheme.headerTextStyle);
        } else {
          expect(columns[i].label.runtimeType, Text);
          expect((columns[i].label as Text).data, 'Ações');
          expect((columns[i].label as Text).style,
              selectModel.theme.tableTheme.headerActionsTextStyle);
        }
      }
    }

    SelectModel selectModel = SelectModel(
        'title',
        'id',
        [
          Line('key'),
          Line('key2', tableTooltip: 'Custom tooltip'),
        ],
        dataSource,
        TypeSelect.ACTION);
    List<DataColumn> columns = UtilsWidget.generateDataColumn(selectModel);
    SelectModel selectModelWithActions = SelectModel(
        'title',
        'id',
        [
          Line('key'),
          Line('key2', tableTooltip: 'Custom tooltip'),
        ],
        dataSource,
        TypeSelect.ACTION,
        actions: [
          ActionSelect(description: 'Test action', icon: Icon(Icons.add))
        ]);
    List<DataColumn> columnsWithActions =
        UtilsWidget.generateDataColumn(selectModelWithActions);
    checkElements(selectModel, columns);
    checkElements(selectModelWithActions, columnsWithActions);
  });

  testWidgets('Test getWidgetLine', (tester) async {
    List<Line> lines = [
      Line('key'),
      Line('key1', customLine: (data) => Text('Custom ${data.data['key1']}')),
      Line('key2',
          formatData: FormatDataAny(((data) => 'Format ${data.data}'))),
      Line('nullValue', defaultValue: ((data) => 'Undefined')),
      Line('emptyValue', defaultValue: ((data) => 'Undefined')),
      Line('dateValue', typeData: TDDateTimestamp()),
      Line('key3', alwaysShowTextTableInScroll: true)
    ];
    SelectModel selectModel =
        SelectModel('title', 'id', lines, dataSource, TypeSelect.ACTION);
    expect(
        UtilsWidget.getWidgetLine(
                selectModel, MapEntry('falseKey', 1), data.first, 1, () {})
            .runtimeType,
        SizedBox);
    expect(
        UtilsWidget.getWidgetLine(selectModel, data.first.entries.toList()[1],
                data.first, 1, () {})
            .runtimeType,
        SelectableText);
    expect(
        (UtilsWidget.getWidgetLine(selectModel, data.first.entries.toList()[1],
                data.first, 1, () {}) as SelectableText)
            .data,
        data.first.entries.toList()[1].value);
    // CustomLine
    expect(
        UtilsWidget.getWidgetLine(selectModel, data.first.entries.toList()[2],
                data.first, 1, () {})
            .runtimeType,
        Text);
    expect(
        (UtilsWidget.getWidgetLine(selectModel, data.first.entries.toList()[2],
                data.first, 1, () {}) as Text)
            .data,
        'Custom ${data.first.entries.toList()[2].value}');

    // FormatData
    expect(
        UtilsWidget.getWidgetLine(selectModel, data.first.entries.toList()[3],
                data.first, 1, () {})
            .runtimeType,
        SelectableText);
    expect(
        (UtilsWidget.getWidgetLine(selectModel, data.first.entries.toList()[3],
                data.first, 1, () {}) as SelectableText)
            .data,
        'Format ${data.first.entries.toList()[3].value}');

    //defaultValue
    expect(
        (UtilsWidget.getWidgetLine(
                selectModel,
                data.first.entries
                    .toList()
                    .firstWhere((element) => element.key == 'nullValue'),
                data.first,
                1,
                () {}) as SelectableText)
            .data,
        'Undefined');
    expect(
        (UtilsWidget.getWidgetLine(
                selectModel,
                data.first.entries
                    .toList()
                    .firstWhere((element) => element.key == 'emptyValue'),
                data.first,
                1,
                () {}) as SelectableText)
            .data,
        'Undefined');

    /// DateTime
    expect(
        (UtilsWidget.getWidgetLine(
                selectModel,
                data.first.entries
                    .toList()
                    .firstWhere((element) => element.key == 'dateValue'),
                data.first,
                1,
                () {}) as SelectableText)
            .data,
        '01/01/2020');

    /// Text in SingleChildScrollView
    expect(
        UtilsWidget.getWidgetLine(
                selectModel,
                data.first.entries
                    .toList()
                    .firstWhere((element) => element.key == 'key3'),
                data.first,
                1,
                () {})
            .runtimeType,
        SingleChildScrollView);
  });

  testWidgets('Test showDialogChangeTypeSearch', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return Material(
            child: ElevatedButton(
          onPressed: () async {
            TypeSearch? typeSearch;
            UtilsWidget.showDialogChangeTypeSearch(context, TypeSearch.CONTAINS)
                .then((value) {
              typeSearch = value;
            });
            await tester.pump();
            expect(find.text('Seleciona um tipo de pesquisa'), findsOneWidget);
            expect(find.text('Contém'), findsOneWidget);
            expect(find.text('Inicia com'), findsOneWidget);
            expect(find.text('Termina com'), findsOneWidget);
            expect(find.text('Não contém'), findsOneWidget);
            ListTile listTile = tester.widget(find.ancestor(
                of: find.text('Termina com'), matching: find.byType(ListTile)));
            listTile.onTap!();
            await tester.pump();
            expect(typeSearch, TypeSearch.ENDSWITH);
          },
          child: Text('Button'),
        ));
      }),
    ));
    (tester.widget(find.byType(ElevatedButton)) as ElevatedButton).onPressed!();
  });
}
