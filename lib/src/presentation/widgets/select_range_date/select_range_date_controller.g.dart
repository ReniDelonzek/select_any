// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select_range_date_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SelectRangeDateController on _SelectRangeDateController, Store {
  Computed<String>? _$dataComputed;

  @override
  String get data => (_$dataComputed ??= Computed<String>(() => super.data,
          name: '_SelectRangeDateController.data'))
      .value;

  final _$initialDateAtom =
      Atom(name: '_SelectRangeDateController.initialDate');

  @override
  DateTime? get initialDate {
    _$initialDateAtom.reportRead();
    return super.initialDate;
  }

  @override
  set initialDate(DateTime? value) {
    _$initialDateAtom.reportWrite(value, super.initialDate, () {
      super.initialDate = value;
    });
  }

  final _$finalDateAtom = Atom(name: '_SelectRangeDateController.finalDate');

  @override
  DateTime? get finalDate {
    _$finalDateAtom.reportRead();
    return super.finalDate;
  }

  @override
  set finalDate(DateTime? value) {
    _$finalDateAtom.reportWrite(value, super.finalDate, () {
      super.finalDate = value;
    });
  }

  final _$periodAtom = Atom(name: '_SelectRangeDateController.period');

  @override
  DatePeriod? get period {
    _$periodAtom.reportRead();
    return super.period;
  }

  @override
  set period(DatePeriod? value) {
    _$periodAtom.reportWrite(value, super.period, () {
      super.period = value;
    });
  }

  @override
  String toString() {
    return '''
initialDate: ${initialDate},
finalDate: ${finalDate},
period: ${period},
data: ${data}
    ''';
  }
}
