import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/select_any.dart';

void main() {
  group('SelectModel', () {
    test('Test SelectModel constructor', () {
      /// Teste show in card
      SelectModel selectModel = SelectModel(
          'title',
          'id',
          [
            Line('line1'),
            Line('line2'),
            Line('line3'),
          ],
          FontDataAny((_) async => []),
          TypeSelect.SIMPLE);

      /// Deve ser exibida em cards pois tem + 2 linhas
      expect(selectModel.showInCards, true);

      SelectModel selectModel2 = SelectModel(
          'title',
          'id',
          [
            Line('line1'),
            Line('line2'),
            Line('line3'),
          ],
          FontDataAny((_) async => []),
          TypeSelect.SIMPLE,
          showInCards: false);

      /// Não deve ser exibido em cards pois o parametro foi passado como false
      expect(selectModel2.showInCards, false);

      /// Teste buttons
      SelectModel selectModel3 = SelectModel(
          'title',
          'id',
          [
            Line('line1'),
            Line('line2'),
            Line('line3'),
          ],
          FontDataAny((_) async => []),
          TypeSelect.SIMPLE,
          showInCards: false,
          buttons: [
            ActionSelect(),
            ActionSelect(),
            ActionSelect(),
          ]);

      /// Como existem 3 botões, 2 deles devem ser do tipo mini
      expect(
          selectModel3.buttons!
              .where((element) =>
                  (element as ActionSelect).floatingActionButtonMini == true)
              .length,
          2);
    });
  });

  group('Line', () {
    test('Test Line constructor', () {
      // Types filter and formatData
      Line dateLine = Line('date', typeData: TDDateTimestamp());
      expect(dateLine.filter.runtimeType, FilterRangeDate);
      expect(dateLine.formatData.runtimeType, FormatDataTimestamp);
      Line line = Line('key');
      expect(line.filter.runtimeType, FilterText);

      // enableLineFilter
      expect(line.enableLineFilter, true);
      expect(Line('key', customLine: (p0) => Text('')).enableLineFilter, false);

      // Name
      expect(line.name, 'Key');
      expect(Line('personName').name, 'Person Name');

      // Enclosure
      expect(Line('name', enclosure: 'Name').enclosure, 'Name: ???');
      expect(Line('name', enclosure: "??? is person's Name").enclosure,
          "??? is person's Name");
    });
  });
}
