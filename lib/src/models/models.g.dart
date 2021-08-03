// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$DataSource on _DataSourceBase, Store {
  final _$listDataAtom = Atom(name: '_DataSourceBase.listData');

  @override
  ObservableList<ItemSelect<dynamic>> get listData {
    _$listDataAtom.reportRead();
    return super.listData;
  }

  @override
  set listData(ObservableList<ItemSelect<dynamic>> value) {
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

mixin _$ItemSelectExpanded on _ItemSelectExpandedBase, Store {
  final _$itemsAtom = Atom(name: '_ItemSelectExpandedBase.items');

  @override
  ObservableList<ItemSelectExpanded> get items {
    _$itemsAtom.reportRead();
    return super.items;
  }

  @override
  set items(ObservableList<ItemSelectExpanded> value) {
    _$itemsAtom.reportWrite(value, super.items, () {
      super.items = value;
    });
  }

  final _$isExpandedAtom = Atom(name: '_ItemSelectExpandedBase.isExpanded');

  @override
  bool get isExpanded {
    _$isExpandedAtom.reportRead();
    return super.isExpanded;
  }

  @override
  set isExpanded(bool value) {
    _$isExpandedAtom.reportWrite(value, super.isExpanded, () {
      super.isExpanded = value;
    });
  }

  @override
  String toString() {
    return '''
items: ${items},
isExpanded: ${isExpanded}
    ''';
  }
}
