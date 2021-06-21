// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select_fk_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SelectFKController on _SelectFKBase, Store {
  final _$inFocusAtom = Atom(name: '_SelectFKBase.inFocus');

  @override
  bool get inFocus {
    _$inFocusAtom.context.enforceReadPolicy(_$inFocusAtom);
    _$inFocusAtom.reportObserved();
    return super.inFocus;
  }

  @override
  set inFocus(bool value) {
    _$inFocusAtom.context.conditionallyRunInAction(() {
      super.inFocus = value;
      _$inFocusAtom.reportChanged();
    }, _$inFocusAtom, name: '${_$inFocusAtom.name}_set');
  }

  final _$objAtom = Atom(name: '_SelectFKBase.obj');

  @override
  Map<String, dynamic> get obj {
    _$objAtom.context.enforceReadPolicy(_$objAtom);
    _$objAtom.reportObserved();
    return super.obj;
  }

  @override
  set obj(Map<String, dynamic> value) {
    _$objAtom.context.conditionallyRunInAction(() {
      super.obj = value;
      _$objAtom.reportChanged();
    }, _$objAtom, name: '${_$objAtom.name}_set');
  }

  final _$showClearIconAtom = Atom(name: '_SelectFKBase.showClearIcon');

  @override
  bool get showClearIcon {
    _$showClearIconAtom.context.enforceReadPolicy(_$showClearIconAtom);
    _$showClearIconAtom.reportObserved();
    return super.showClearIcon;
  }

  @override
  set showClearIcon(bool value) {
    _$showClearIconAtom.context.conditionallyRunInAction(() {
      super.showClearIcon = value;
      _$showClearIconAtom.reportChanged();
    }, _$showClearIconAtom, name: '${_$showClearIconAtom.name}_set');
  }
}
