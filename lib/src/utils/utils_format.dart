import 'package:msk_utils/msk_utils.dart';
import 'package:intl/intl.dart';

class UtilsFormat {
  static String formatMoney(double? value,
      {int maxDecimalDigits = 4,
      int minDecimalDigits = 2,
      String locale = 'pt_BR',
      String symbol = 'R\$'}) {
    if (value == null) {
      return '0';
    }
    value = value.toStringAsFixed(4).toDouble();
    int casasDecimais = value.toString().split('.').last.length;
    if (casasDecimais < minDecimalDigits) {
      casasDecimais = minDecimalDigits;
    }

    /// Limita a 4 casas
    if (casasDecimais > maxDecimalDigits) {
      casasDecimais = maxDecimalDigits;
    }

    return NumberFormat.currency(
            locale: locale, symbol: symbol, decimalDigits: casasDecimais)
        .format(value);
  }
}
