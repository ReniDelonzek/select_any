// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select_range_date_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SelectRangeDateController on _SelectRangeDateController, Store {
  Computed<String> _$dataComputed;

  @override
  String get data =>
      (_$dataComputed ??= Computed<String>(() => super.data)).value;

  final _$initialDateAtom =
      Atom(name: '_SelectRangeDateController.initialDate');

  @override
  DateTime get initialDate {
    _$initialDateAtom.context.enforceReadPolicy(_$initialDateAtom);
    _$initialDateAtom.reportObserved();
    return super.initialDate;
  }

  @override
  set initialDate(DateTime value) {
    _$initialDateAtom.context.conditionallyRunInAction(() {
      super.initialDate = value;
      _$initialDateAtom.reportChanged();
    }, _$initialDateAtom, name: '${_$initialDateAtom.name}_set');
  }

  final _$finalDateAtom = Atom(name: '_SelectRangeDateController.finalDate');

  @override
  DateTime get finalDate {
    _$finalDateAtom.context.enforceReadPolicy(_$finalDateAtom);
    _$finalDateAtom.reportObserved();
    return super.finalDate;
  }

  @override
  set finalDate(DateTime value) {
    _$finalDateAtom.context.conditionallyRunInAction(() {
      super.finalDate = value;
      _$finalDateAtom.reportChanged();
    }, _$finalDateAtom, name: '${_$finalDateAtom.name}_set');
  }

  final _$periodAtom = Atom(name: '_SelectRangeDateController.period');

  @override
  DatePeriod get period {
    _$periodAtom.context.enforceReadPolicy(_$periodAtom);
    _$periodAtom.reportObserved();
    return super.period;
  }

  @override
  set period(DatePeriod value) {
    _$periodAtom.context.conditionallyRunInAction(() {
      super.period = value;
      _$periodAtom.reportChanged();
    }, _$periodAtom, name: '${_$periodAtom.name}_set');
  }
}
