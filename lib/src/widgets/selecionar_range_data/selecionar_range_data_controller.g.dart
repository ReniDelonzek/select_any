// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selecionar_range_data_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SelecionarRangeDataController on _SelecionarRangeDataController, Store {
  Computed<String> _$dataComputed;

  @override
  String get data =>
      (_$dataComputed ??= Computed<String>(() => super.data)).value;

  final _$dataInicialAtom =
      Atom(name: '_SelecionarRangeDataController.dataInicial');

  @override
  DateTime get dataInicial {
    _$dataInicialAtom.context.enforceReadPolicy(_$dataInicialAtom);
    _$dataInicialAtom.reportObserved();
    return super.dataInicial;
  }

  @override
  set dataInicial(DateTime value) {
    _$dataInicialAtom.context.conditionallyRunInAction(() {
      super.dataInicial = value;
      _$dataInicialAtom.reportChanged();
    }, _$dataInicialAtom, name: '${_$dataInicialAtom.name}_set');
  }

  final _$dataFinalAtom =
      Atom(name: '_SelecionarRangeDataController.dataFinal');

  @override
  DateTime get dataFinal {
    _$dataFinalAtom.context.enforceReadPolicy(_$dataFinalAtom);
    _$dataFinalAtom.reportObserved();
    return super.dataFinal;
  }

  @override
  set dataFinal(DateTime value) {
    _$dataFinalAtom.context.conditionallyRunInAction(() {
      super.dataFinal = value;
      _$dataFinalAtom.reportChanged();
    }, _$dataFinalAtom, name: '${_$dataFinalAtom.name}_set');
  }

  final _$periodoAtom = Atom(name: '_SelecionarRangeDataController.periodo');

  @override
  DatePeriod get periodo {
    _$periodoAtom.context.enforceReadPolicy(_$periodoAtom);
    _$periodoAtom.reportObserved();
    return super.periodo;
  }

  @override
  set periodo(DatePeriod value) {
    _$periodoAtom.context.conditionallyRunInAction(() {
      super.periodo = value;
      _$periodoAtom.reportChanged();
    }, _$periodoAtom, name: '${_$periodoAtom.name}_set');
  }
}
