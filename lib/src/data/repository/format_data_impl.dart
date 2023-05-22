import 'package:msk_utils/msk_utils.dart';

import 'package:select_any/select_any.dart';

class FormatDataDate extends FormatData {
  String inputFormat;
  String outputFormat;

  FormatDataDate({
    required this.inputFormat,
    required this.outputFormat,
  });

  @override
  String formatData(ObjFormatData obj) {
    try {
      String? data;
      if (obj.data is String) {
        data = obj.data;
      } else {
        data = obj.data?.toString();
      }
      return data.toDate(inputFormat).string(outputFormat);
    } catch (error, _) {
      // UtilsSentry.reportError(error, stackTrace);
    }
    return defaultValue;
  }
}

class FormatDataTimestamp extends FormatData {
  String outputFormat;

  FormatDataTimestamp(this.outputFormat, {String defaultValue = ''})
      : super(defaultValue: defaultValue);

  @override
  String formatData(ObjFormatData data) {
    try {
      if (data.data == null) return defaultValue;
      return DateTime.fromMillisecondsSinceEpoch(data.data.toString().toInt())
          .string(outputFormat);
    } catch (error, _) {
      // UtilsSentry.reportError(error, stackTrace);
    }
    return defaultValue;
  }
}

class FormatDataAny extends FormatData {
  String Function(ObjFormatData) format;
  FormatDataAny(this.format);

  @override
  String formatData(ObjFormatData data) {
    return format(data);
  }
}

class FormatDataMoney extends FormatData {
  String? locale;
  String? symbol;
  int maxDecimalDigits;

  FormatDataMoney({this.locale, this.symbol, this.maxDecimalDigits = 2});

  @override
  String formatData(ObjFormatData data) {
    try {
      double value;
      if (data.data is double) {
        value = data.data;
      } else {
        value = data.data.toString().toDouble();
      }
      return UtilsFormat.formatMoney(value, maxDecimalDigits: maxDecimalDigits);
    } catch (error, _) {}
    return defaultValue;
  }
}

class FormatDataBool extends FormatData {
  final String textTrue, textFalse;
  FormatDataBool({this.textTrue = 'Sim', this.textFalse = 'Não'});

  @override
  String formatData(ObjFormatData data) {
    return data.data == true ? textTrue : textFalse;
  }
}

class FormatDataBoolInt extends FormatData {
  final String textTrue, textFalse;
  FormatDataBoolInt({this.textTrue = 'Sim', this.textFalse = 'Não'});

  @override
  String formatData(ObjFormatData data) {
    return data.data == 1 ? textTrue : textFalse;
  }
}
