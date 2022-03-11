import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/select_any.dart';

void main() {
  testWidgets('Test ButtonChip', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.dark(secondary: Colors.blue)),
      home: Material(
        child: ButtonChip('Test Title'),
      ),
    ));
    expect(find.text('Test Title'), findsOneWidget);
    Container? c = tester.firstWidget(find.byType(Container)) as Container?;
    expect(c, isNotNull);

    expect((c!.decoration as BoxDecoration?)?.color?.value, Colors.white.value);

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.dark(secondary: Colors.blue)),
      home: Material(
        child: ButtonChip('Test Title', isSelected: true),
      ),
    ));
    Text? text = tester.widget(find.text('Test Title')) as Text?;
    expect(text, isNotNull);
    expect(text!.style?.color?.value, Colors.white.value);
    Container? c2 = tester.firstWidget(find.byType(Container)) as Container?;
    expect(c2, isNotNull);

    /// O blue foi definido logo acima
    expect((c2!.decoration as BoxDecoration?)?.color?.value, Colors.blue.value);
  });
}
