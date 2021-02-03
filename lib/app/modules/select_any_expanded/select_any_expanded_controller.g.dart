// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select_any_expanded_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SelectAnyExpandedController on _SelectAnyExpandedBase, Store {
  final _$searchIconAtom = Atom(name: '_SelectAnyExpandedBase.searchIcon');

  @override
  Icon get searchIcon {
    _$searchIconAtom.context.enforceReadPolicy(_$searchIconAtom);
    _$searchIconAtom.reportObserved();
    return super.searchIcon;
  }

  @override
  set searchIcon(Icon value) {
    _$searchIconAtom.context.conditionallyRunInAction(() {
      super.searchIcon = value;
      _$searchIconAtom.reportChanged();
    }, _$searchIconAtom, name: '${_$searchIconAtom.name}_set');
  }

  final _$appBarTitleAtom = Atom(name: '_SelectAnyExpandedBase.appBarTitle');

  @override
  Widget get appBarTitle {
    _$appBarTitleAtom.context.enforceReadPolicy(_$appBarTitleAtom);
    _$appBarTitleAtom.reportObserved();
    return super.appBarTitle;
  }

  @override
  set appBarTitle(Widget value) {
    _$appBarTitleAtom.context.conditionallyRunInAction(() {
      super.appBarTitle = value;
      _$appBarTitleAtom.reportChanged();
    }, _$appBarTitleAtom, name: '${_$appBarTitleAtom.name}_set');
  }

  final _$listaExibidaAtom = Atom(name: '_SelectAnyExpandedBase.listaExibida');

  @override
  ObservableList<ItemSelect> get listaExibida {
    _$listaExibidaAtom.context.enforceReadPolicy(_$listaExibidaAtom);
    _$listaExibidaAtom.reportObserved();
    return super.listaExibida;
  }

  @override
  set listaExibida(ObservableList<ItemSelect> value) {
    _$listaExibidaAtom.context.conditionallyRunInAction(() {
      super.listaExibida = value;
      _$listaExibidaAtom.reportChanged();
    }, _$listaExibidaAtom, name: '${_$listaExibidaAtom.name}_set');
  }

  final _$streamAtom = Atom(name: '_SelectAnyExpandedBase.stream');

  @override
  Stream get stream {
    _$streamAtom.context.enforceReadPolicy(_$streamAtom);
    _$streamAtom.reportObserved();
    return super.stream;
  }

  @override
  set stream(Stream value) {
    _$streamAtom.context.conditionallyRunInAction(() {
      super.stream = value;
      _$streamAtom.reportChanged();
    }, _$streamAtom, name: '${_$streamAtom.name}_set');
  }

  final _$_SelectAnyExpandedBaseActionController =
      ActionController(name: '_SelectAnyExpandedBase');

  @override
  void clearList() {
    final _$actionInfo = _$_SelectAnyExpandedBaseActionController.startAction();
    try {
      return super.clearList();
    } finally {
      _$_SelectAnyExpandedBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setList(List<ItemSelect> list) {
    final _$actionInfo = _$_SelectAnyExpandedBaseActionController.startAction();
    try {
      return super.setList(list);
    } finally {
      _$_SelectAnyExpandedBaseActionController.endAction(_$actionInfo);
    }
  }
}
