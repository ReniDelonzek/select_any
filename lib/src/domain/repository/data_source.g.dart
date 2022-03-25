// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_source.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$DataSource on _DataSourceBase, Store {
  final _$listDataAtom = Atom(name: '_DataSourceBase.listData');

  @override
  ObservableList<ItemSelectTable> get listData {
    _$listDataAtom.reportRead();
    return super.listData;
  }

  @override
  set listData(ObservableList<ItemSelectTable> value) {
    _$listDataAtom.reportWrite(value, super.listData, () {
      super.listData = value;
    });
  }

  @override
  String toString() {
    return '''
listData: ${listData}
    ''';
  }
}
