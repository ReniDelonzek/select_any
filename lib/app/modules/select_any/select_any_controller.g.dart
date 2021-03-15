// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select_any_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SelectAnyController on _SelectAnyBase, Store {
  Computed<ObservableList<ItemSelectTable>> _$listaExibidaComputed;

  @override
  ObservableList<ItemSelectTable> get listaExibida =>
      (_$listaExibidaComputed ??= Computed<ObservableList<ItemSelectTable>>(
              () => super.listaExibida))
          .value;

  final _$typeDiplayAtom = Atom(name: '_SelectAnyBase.typeDiplay');

  @override
  int get typeDiplay {
    _$typeDiplayAtom.context.enforceReadPolicy(_$typeDiplayAtom);
    _$typeDiplayAtom.reportObserved();
    return super.typeDiplay;
  }

  @override
  set typeDiplay(int value) {
    _$typeDiplayAtom.context.conditionallyRunInAction(() {
      super.typeDiplay = value;
      _$typeDiplayAtom.reportChanged();
    }, _$typeDiplayAtom, name: '${_$typeDiplayAtom.name}_set');
  }

  final _$searchTextAtom = Atom(name: '_SelectAnyBase.searchText');

  @override
  String get searchText {
    _$searchTextAtom.context.enforceReadPolicy(_$searchTextAtom);
    _$searchTextAtom.reportObserved();
    return super.searchText;
  }

  @override
  set searchText(String value) {
    _$searchTextAtom.context.conditionallyRunInAction(() {
      super.searchText = value;
      _$searchTextAtom.reportChanged();
    }, _$searchTextAtom, name: '${_$searchTextAtom.name}_set');
  }

  final _$searchIconAtom = Atom(name: '_SelectAnyBase.searchIcon');

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

  final _$appBarTitleAtom = Atom(name: '_SelectAnyBase.appBarTitle');

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

  final _$confirmarParaCarregarDadosAtom =
      Atom(name: '_SelectAnyBase.confirmarParaCarregarDados');

  @override
  bool get confirmarParaCarregarDados {
    _$confirmarParaCarregarDadosAtom.context
        .enforceReadPolicy(_$confirmarParaCarregarDadosAtom);
    _$confirmarParaCarregarDadosAtom.reportObserved();
    return super.confirmarParaCarregarDados;
  }

  @override
  set confirmarParaCarregarDados(bool value) {
    _$confirmarParaCarregarDadosAtom.context.conditionallyRunInAction(() {
      super.confirmarParaCarregarDados = value;
      _$confirmarParaCarregarDadosAtom.reportChanged();
    }, _$confirmarParaCarregarDadosAtom,
        name: '${_$confirmarParaCarregarDadosAtom.name}_set');
  }

  final _$pageAtom = Atom(name: '_SelectAnyBase.page');

  @override
  int get page {
    _$pageAtom.context.enforceReadPolicy(_$pageAtom);
    _$pageAtom.reportObserved();
    return super.page;
  }

  @override
  set page(int value) {
    _$pageAtom.context.conditionallyRunInAction(() {
      super.page = value;
      _$pageAtom.reportChanged();
    }, _$pageAtom, name: '${_$pageAtom.name}_set');
  }

  final _$totalAtom = Atom(name: '_SelectAnyBase.total');

  @override
  int get total {
    _$totalAtom.context.enforceReadPolicy(_$totalAtom);
    _$totalAtom.reportObserved();
    return super.total;
  }

  @override
  set total(int value) {
    _$totalAtom.context.conditionallyRunInAction(() {
      super.total = value;
      _$totalAtom.reportChanged();
    }, _$totalAtom, name: '${_$totalAtom.name}_set');
  }

  final _$listAtom = Atom(name: '_SelectAnyBase.list');

  @override
  ObservableList<ItemSelectTable> get list {
    _$listAtom.context.enforceReadPolicy(_$listAtom);
    _$listAtom.reportObserved();
    return super.list;
  }

  @override
  set list(ObservableList<ItemSelectTable> value) {
    _$listAtom.context.conditionallyRunInAction(() {
      super.list = value;
      _$listAtom.reportChanged();
    }, _$listAtom, name: '${_$listAtom.name}_set');
  }

  final _$loadingAtom = Atom(name: '_SelectAnyBase.loading');

  @override
  bool get loading {
    _$loadingAtom.context.enforceReadPolicy(_$loadingAtom);
    _$loadingAtom.reportObserved();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.context.conditionallyRunInAction(() {
      super.loading = value;
      _$loadingAtom.reportChanged();
    }, _$loadingAtom, name: '${_$loadingAtom.name}_set');
  }

  final _$_SelectAnyBaseActionController =
      ActionController(name: '_SelectAnyBase');

  @override
  void setList(List<ItemSelectTable> list) {
    final _$actionInfo = _$_SelectAnyBaseActionController.startAction();
    try {
      return super.setList(list);
    } finally {
      _$_SelectAnyBaseActionController.endAction(_$actionInfo);
    }
  }
}
