import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/select_any.dart';

void main() {
  List<Map<String, dynamic>> data = List.generate(
    45,
    (index) => {'key': 'key$index', 'id': index},
  );
  DataSource dataSource = FontDataAny((_) async => data);

  testWidgets('Test selectFK', (tester) async {
    SelectFKController ctlSelect = SelectFKController();

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child:
            SelectFKWidget('title', 'id', [Line('key')], ctlSelect, dataSource),
      ),
    ));
    expect(find.text('title'), findsOneWidget);
    expect(find.text('Toque para selecionar'), findsOneWidget);
  });
  // customTextTitle
  testWidgets('Test selectFK customTitle', (tester) async {
    SelectFKController ctlSelect = SelectFKController();

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SelectFKWidget(
            'title', 'id', [Line('key')], ctlSelect, dataSource,
            customTitle: Text('My custom title')),
      ),
    ));
    expect(find.text('title'), findsNothing);
    expect(find.text('My custom title'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SelectFKWidget(
            'title', 'id', [Line('key')], ctlSelect, dataSource,
            defaultLabel: 'My default label'),
      ),
    ));
    expect(find.text('title'), findsNothing);
    expect(find.text('My default label'), findsOneWidget);
  });

  testWidgets('Test selectFK selected obj', (tester) async {
    SelectFKController ctlSelect = SelectFKController();

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child:
            SelectFKWidget('title', 'id', [Line('key')], ctlSelect, dataSource),
      ),
    ));
    ctlSelect.obj = {'key': 'Test value'};
    await tester.pump();
    expect(find.text('Test value'), findsOneWidget);
    ctlSelect.obj = {'key': 'Test value 2'};
    await tester.pump();
    expect(find.text('Test value 2'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SelectFKWidget(
            'title',
            'id',
            [Line('key', customLine: (data) => Text('customValue'))],
            ctlSelect,
            dataSource),
      ),
    ));
    ctlSelect.obj = {'key': 'Test value'};
    await tester.pump();
    expect(find.text('Test value'), findsNothing);
    expect(find.text('customValue'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SelectFKWidget(
            'title',
            'id',
            [Line('key', defaultValue: ((data) => 'My default value'))],
            ctlSelect,
            dataSource),
      ),
    ));
    ctlSelect.obj = {'key': null};
    await tester.pump();
    expect(find.text('Test value'), findsNothing);
    expect(find.text('My default value'), findsOneWidget);

    ctlSelect.obj = {'key': 'Test value'};
    await tester.pump();
    expect(find.text('Test value'), findsOneWidget);
    expect(find.text('My default value'), findsNothing);

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child:
            SelectFKWidget('title', 'id', [Line('key')], ctlSelect, dataSource),
      ),
    ));
    ctlSelect.obj = {'key': null};
    await tester.pump();
    expect(find.text('Linha vazia'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SelectFKWidget('title', 'id',
            [Line('key', enclosure: 'Value: ???')], ctlSelect, dataSource),
      ),
    ));
    ctlSelect.obj = {'key': 'Test value'};
    await tester.pump();
    expect(find.text('Value: Test value'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SelectFKWidget(
            'title',
            'id',
            [Line('key', textStyle: (p0) => TextStyle(color: Colors.red))],
            ctlSelect,
            dataSource),
      ),
    ));
    ctlSelect.obj = {'key': 'Test value'};
    ctlSelect.inFocus = false;
    await tester.pump();
    expect(find.text('Test value'), findsOneWidget);
    expect((tester.widget(find.text('Test value')) as Text).style?.color?.value,
        Colors.red.value);
    ctlSelect.inFocus = true;
    await tester.pump();
    expect((tester.widget(find.text('Test value')) as Text).style?.color?.value,
        isNot(Colors.red.value));
  });

  /// RadioList
  testWidgets('Test selectFK radioList', (tester) async {
    SelectFKController ctlSelect = SelectFKController();

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SingleChildScrollView(
          child: SelectFKWidget(
              'title', 'id', [Line('key')], ctlSelect, dataSource,
              typeView: TypeView.radioList),
        ),
      ),
    ));
    expect(find.text('key1'), findsOneWidget);
    expect(find.byType(Radio), findsNWidgets(data.length));

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SingleChildScrollView(
          child: SelectFKWidget('title', 'id', [Line('key')], ctlSelect,
              FontDataAny((_) async => []),
              typeView: TypeView.radioList),
        ),
      ),
    ));
    expect(find.text('Lista vazia'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SingleChildScrollView(
          child: SelectFKWidget(
            'title',
            'id',
            [Line('key')],
            ctlSelect,
            FontDataAny((_) async => []),
            typeView: TypeView.radioList,
            customEmptyList: Text('List is Empty'),
          ),
        ),
      ),
    ));
    await Future.delayed(Duration(seconds: 2));
    expect(find.text('List is Empty'), findsOneWidget);
  });
}
