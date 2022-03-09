import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/select_any.dart';

void main() {
  testWidgets('Test FailTest', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: FailWidget('Test Fail Message'),
    ));
    expect(find.text('Test Fail Message'), findsOneWidget);
  });

  testWidgets('Test FailTest', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: FailWidget(
        'Test Fail Message',
        error: ErrorDescription('Test error'),
      ),
    ));
    expect(find.text('Test error'), findsOneWidget);
  });
}
