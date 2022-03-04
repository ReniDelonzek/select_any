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
    int decimalPlaces = value.toString().split('.').last.length;
    if (decimalPlaces < minDecimalDigits) {
      decimalPlaces = minDecimalDigits;
    }

    /// Limita a 4 casas
    if (decimalPlaces > maxDecimalDigits) {
      decimalPlaces = maxDecimalDigits;
    }

    return NumberFormat.currency(
            locale: locale, symbol: symbol, decimalDigits: decimalPlaces)
        .format(value);
  }
}
