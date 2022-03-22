import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/src/domain/utils/utils_format.dart';

void main() {
  test('Test UtilsFormat', () {
    // Deixar com o caractere invisível, pois esse é o retorno
    expect(UtilsFormat.formatMoney(20), 'R\$ 20,00');
    expect(UtilsFormat.formatMoney(-42), '-R\$ 42,00');
    expect(UtilsFormat.formatMoney(52.4), 'R\$ 52,40');
    expect(
        UtilsFormat.formatMoney(344.4344, maxDecimalDigits: 2), 'R\$ 344,43');
    expect(
        UtilsFormat.formatMoney(344.4344, maxDecimalDigits: 4), 'R\$ 344,4344');
  });
}
