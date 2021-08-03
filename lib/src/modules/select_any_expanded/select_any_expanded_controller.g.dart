// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select_any_expanded_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SelectAnyExpandedController on _SelectAnyExpandedBase, Store {
  final _$searchIconAtom = Atom(name: '_SelectAnyExpandedBase.searchIcon');

  @override
  Icon get searchIcon {
    _$searchIconAtom.reportRead();
    return super.searchIcon;
  }

  @override
  set searchIcon(Icon value) {
    _$searchIconAtom.reportWrite(value, super.searchIcon, () {
      super.searchIcon = value;
    });
  }

  final _$appBarTitleAtom = Atom(name: '_SelectAnyExpandedBase.appBarTitle');

  @override
  Widget get appBarTitle {
    _$appBarTitleAtom.reportRead();
    return super.appBarTitle;
  }

  @override
  set appBarTitle(Widget value) {
    _$appBarTitleAtom.reportWrite(value, super.appBarTitle, () {
      super.appBarTitle = value;
    });
  }

  final _$listaExibidaAtom = Atom(name: '_SelectAnyExpandedBase.listaExibida');

  @override
  ObservableList<ItemSelect<dynamic>> get listaExibida {
    _$listaExibidaAtom.reportRead();
    return super.listaExibida;
  }

  @override
  set listaExibida(ObservableList<ItemSelect<dynamic>> value) {
    _$listaExibidaAtom.reportWrite(value, super.listaExibida, () {
      super.listaExibida = value;
    });
  }

  final _$streamAtom = Atom(name: '_SelectAnyExpandedBase.stream');

  @override
  Stream<dynamic> get stream {
    _$streamAtom.reportRead();
    return super.stream;
  }

  @override
  set stream(Stream<dynamic> value) {
    _$streamAtom.reportWrite(value, super.stream, () {
      super.stream = value;
    });
  }

  final _$_SelectAnyExpandedBaseActionController =
      ActionController(name: '_SelectAnyExpandedBase');

  @override
  void clearList() {
    final _$actionInfo = _$_SelectAnyExpandedBaseActionController.startAction(
        name: '_SelectAnyExpandedBase.clearList');
    try {
      return super.clearList();
    } finally {
      _$_SelectAnyExpandedBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setList(List<ItemSelect<dynamic>> list) {
    final _$actionInfo = _$_SelectAnyExpandedBaseActionController.startAction(
        name: '_SelectAnyExpandedBase.setList');
    try {
      return super.setList(list);
    } finally {
      _$_SelectAnyExpandedBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
searchIcon: ${searchIcon},
appBarTitle: ${appBarTitle},
listaExibida: ${listaExibida},
stream: ${stream}
    ''';
  }
}
