import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/select_any.dart';

void main() {
  testWidgets('Test Snackbar center', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Material(child: Scaffold(
        body: Builder(builder: (context) {
          return InkWell(onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(MySnackBar(
                content: Text('My snack'),
                placement: SnackPlacement.CENTER,
                behavior: SnackBarBehavior.floating));
          });
        }),
      )),
    ));
    InkWell ink = tester.widget(find.byType(InkWell));
    ink.onTap!();
    await tester.pump();
    Row? row = tester.widgetList<Row>(find.byType(Row)).first;
    expect(row, isNotNull);
    expect(row.mainAxisAlignment, MainAxisAlignment.center);
    await tester.pump();
  });
  testWidgets('Test Snackbar left', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Material(child: Scaffold(
        body: Builder(builder: (context) {
          return InkWell(onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(MySnackBar(
                content: Text('My snack'),
                placement: SnackPlacement.LEFT,
                behavior: SnackBarBehavior.floating));
          });
        }),
      )),
    ));
    InkWell ink = tester.widget(find.byType(InkWell));
    ink.onTap!();
    await tester.pump();
    Row row = tester.widgetList<Row>(find.byType(Row)).first;
    expect(row, isNotNull);
    expect(row.mainAxisAlignment, MainAxisAlignment.start);
    await tester.pump();
  });
  testWidgets('Test Snackbar rigth', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Material(child: Scaffold(
        body: Builder(builder: (context) {
          return InkWell(onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(MySnackBar(
                content: Text('My snack'),
                placement: SnackPlacement.RIGHT,
                behavior: SnackBarBehavior.floating));
          });
        }),
      )),
    ));
    InkWell ink = tester.widget(find.byType(InkWell));
    ink.onTap!();
    await tester.pump();
    Row row = tester.widgetList<Row>(find.byType(Row)).first;
    expect(row, isNotNull);
    expect(row.mainAxisAlignment, MainAxisAlignment.end);
    await tester.pump();
  });
}
