import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/select_any.dart';

void main() {
  List<Map<String, dynamic>> data = List.generate(
    45,
    (index) => {'key': 'key$index', 'id': index},
  );
  DataSource dataSource = FontDataAny((_) async => data);
  SelectModel model =
      SelectModel('Test', 'id', [Line('key')], dataSource, TypeSelect.SIMPLE);

  SelectAnyController controller = SelectAnyController();

  testWidgets('Test TableData', (tester) async {
    tester.binding.window.physicalSizeTestValue = Size(2000, 1000);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // resets the screen to its original size after the test end
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    await tester.pumpWidget(MaterialApp(
        home: Material(child: TableDataWidget(model, controller: controller))));
    //expect(find.text('Test'), findsOneWidget);
  });

  // testWidgets('Test TableData', (tester) async {
  //   await tester.pumpWidget(TableDataWidget(
  //       SelectModel('Test', 'id', [Line('key')], dataSource, TypeSelect.SIMPLE,
  //           theme: SelectModelTheme(
  //               tableTheme: SelectModelThemeTable(showTableInCard: true))),
  //       controller: controller));
  //   expect(find.byType(Card), findsOneWidget);

  //   await tester.pumpWidget(TableDataWidget(
  //       SelectModel('Test', 'id', [Line('key')], dataSource, TypeSelect.SIMPLE,
  //           theme: SelectModelTheme(
  //               tableTheme: SelectModelThemeTable(showTableInCard: false))),
  //       controller: controller));
  //   expect(find.byType(Card), findsNothing);
  // });
}
