// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_base.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$FilterBase on _FilterBaseBase, Store {
  final _$selectedValueAtom = Atom(name: '_FilterBaseBase.selectedValue');

  @override
  ItemDataFilter? get selectedValue {
    _$selectedValueAtom.reportRead();
    return super.selectedValue;
  }

  @override
  set selectedValue(ItemDataFilter? value) {
    _$selectedValueAtom.reportWrite(value, super.selectedValue, () {
      super.selectedValue = value;
    });
  }

  @override
  String toString() {
    return '''
selectedValue: ${selectedValue}
    ''';
  }
}
