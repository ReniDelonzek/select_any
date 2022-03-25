import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/src/presentation/widgets/utils_snack.dart';

void main() {
  testWidgets('Test Snackbar left', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Material(child: Scaffold(
        body: Builder(builder: (context) {
          return InkWell(onTap: () {
            showSnackMessage(context, 'Test Message');
          });
        }),
      )),
    ));
    InkWell ink = tester.widget(find.byType(InkWell));
    ink.onTap!();
    await tester.pump();
    expect(find.text('Test Message'), findsOneWidget);
  });
}
