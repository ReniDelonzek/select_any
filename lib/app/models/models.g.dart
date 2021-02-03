// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$DataSource on _DataSourceBase, Store {
  final _$listDataAtom = Atom(name: '_DataSourceBase.listData');

  @override
  ObservableList<ItemSelect> get listData {
    _$listDataAtom.context.enforceReadPolicy(_$listDataAtom);
    _$listDataAtom.reportObserved();
    return super.listData;
  }

  @override
  set listData(ObservableList<ItemSelect> value) {
    _$listDataAtom.context.conditionallyRunInAction(() {
      super.listData = value;
      _$listDataAtom.reportChanged();
    }, _$listDataAtom, name: '${_$listDataAtom.name}_set');
  }
}

mixin _$ItemSelectExpanded on _ItemSelectExpandedBase, Store {
  final _$itensAtom = Atom(name: '_ItemSelectExpandedBase.itens');

  @override
  ObservableList<ItemSelectExpanded> get items {
    _$itensAtom.context.enforceReadPolicy(_$itensAtom);
    _$itensAtom.reportObserved();
    return super.items;
  }

  @override
  set items(ObservableList<ItemSelectExpanded> value) {
    _$itensAtom.context.conditionallyRunInAction(() {
      super.items = value;
      _$itensAtom.reportChanged();
    }, _$itensAtom, name: '${_$itensAtom.name}_set');
  }

  final _$isExpandedAtom = Atom(name: '_ItemSelectExpandedBase.isExpanded');

  @override
  bool get isExpanded {
    _$isExpandedAtom.context.enforceReadPolicy(_$isExpandedAtom);
    _$isExpandedAtom.reportObserved();
    return super.isExpanded;
  }

  @override
  set isExpanded(bool value) {
    _$isExpandedAtom.context.conditionallyRunInAction(() {
      super.isExpanded = value;
      _$isExpandedAtom.reportChanged();
    }, _$isExpandedAtom, name: '${_$isExpandedAtom.name}_set');
  }
}
