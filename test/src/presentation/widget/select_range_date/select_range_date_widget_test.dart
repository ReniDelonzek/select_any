import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/select_any.dart';

void main() {
  testWidgets('Test select_range_date', (tester) async {
    SelectRangeDateController controller = SelectRangeDateController();
    await tester.pumpWidget(MaterialApp(
        home: Material(
      child: SelectRangeDateWidget(
          controller, (DateTime? start, DateTime? end) {}),
    )));
    expect(find.text('Toque aqui para selecionar'), findsOneWidget);

    DateTime dateTime = DateTime(2020, 1, 1);
    controller.initialDate = dateTime;
    controller.finalDate = dateTime.add(Duration(days: 1));
    await tester.pump();
    expect(controller.data, '01/01/2020 - 02/01/2020');
    expect(find.text(controller.data), findsOneWidget);
  });
}
