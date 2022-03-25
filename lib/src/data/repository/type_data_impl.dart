import 'package:select_any/select_any.dart';

abstract class TDDate extends TypeData {
  String outputFormat;

  TDDate({this.outputFormat = 'dd/MM/yyyy'});
}

class TDDateString extends TDDate {
  TDDateString({String outputFormat = 'dd/MM/yyyy'})
      : super(outputFormat: outputFormat);
}

class TDDateTimestamp extends TDDate {
  TDDateTimestamp({String outputFormat = 'dd/MM/yyyy'})
      : super(outputFormat: outputFormat);
}

class TDMoney extends TypeData {}

class TDString extends TypeData {}

class TDNumber extends TypeData {}

class TDBoolean extends TypeData {}

/// Generic class that represents a non-string value, do not use outside the app
class TDNotString extends TypeData {}
