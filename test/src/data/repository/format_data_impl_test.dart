import 'package:flutter_test/flutter_test.dart';
import 'package:msk_utils/msk_utils.dart';
import 'package:select_any/select_any.dart';

void main() {
  test('Test FormatDataDate', () {
    FormatDataDate formatDataDate =
        FormatDataDate(inputFormat: 'yyyy-MM-dd', outputFormat: 'dd/MM/yyyy');
    expect(formatDataDate.formatData(ObjFormatData(data: '2020-01-01')),
        '01/01/2020');
  });
  test('Test FormatDataTimestamp', () {
    FormatDataTimestamp formatDataDate = FormatDataTimestamp('dd/MM/yyyy');
    DateTime dateTime = DateTime.now();
    expect(
        formatDataDate
            .formatData(ObjFormatData(data: dateTime.millisecondsSinceEpoch)),
        dateTime.string('dd/MM/yyyy'));
  });
  test('Test FormatDataAny', () {
    FormatDataAny formatDataDate = FormatDataAny((data) => data.data);
    expect(formatDataDate.formatData(ObjFormatData(data: 'any input')),
        'any input');
  });
  test('Test FormatDataMoney', () {
    FormatDataMoney formatData = FormatDataMoney();
    // Deixar com o caractere invisível, pois esse é o retorno
    expect(formatData.formatData(ObjFormatData(data: '20')), 'R\$ 20,00');
    expect(formatData.formatData(ObjFormatData(data: 40)), 'R\$ 40,00');
    expect(formatData.formatData(ObjFormatData(data: 52.4)), 'R\$ 52,40');
    expect(formatData.formatData(ObjFormatData(data: 344.4344)), 'R\$ 344,43');
  });

  test('Test FormatDataBool', () {
    FormatDataBool formatData =
        FormatDataBool(textTrue: 'Yes', textFalse: 'Not');
    expect(formatData.formatData(ObjFormatData(data: true)), 'Yes');
    expect(formatData.formatData(ObjFormatData(data: false)), 'Not');
  });

  test('Test FormatDataBoolInt', () {
    FormatDataBoolInt formatData =
        FormatDataBoolInt(textTrue: 'Yes', textFalse: 'Not');
    expect(formatData.formatData(ObjFormatData(data: 1)), 'Yes');
    expect(formatData.formatData(ObjFormatData(data: 0)), 'Not');
  });
}
