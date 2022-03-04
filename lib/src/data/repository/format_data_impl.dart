import 'package:msk_utils/msk_utils.dart';
import 'package:select_any/select_any.dart';

class FormatDataDate extends FormatData {
  late String inputFormat;
  late String outputFormat;

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
  Function(ObjFormatData) format;
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
      return UtilsFormat.formatMoney(data.data,
          maxDecimalDigits: maxDecimalDigits);
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
