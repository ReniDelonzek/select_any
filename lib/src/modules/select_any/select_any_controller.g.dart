// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select_any_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SelectAnyController on _SelectAnyBase, Store {
  Computed<ObservableList<ItemSelectTable>>? _$listaExibidaComputed;

  @override
  ObservableList<ItemSelectTable> get listaExibida =>
      (_$listaExibidaComputed ??= Computed<ObservableList<ItemSelectTable>>(
              () => super.listaExibida,
              name: '_SelectAnyBase.listaExibida'))
          .value;

  final _$typeDiplayAtom = Atom(name: '_SelectAnyBase.typeDiplay');

  @override
  int get typeDiplay {
    _$typeDiplayAtom.reportRead();
    return super.typeDiplay;
  }

  @override
  set typeDiplay(int value) {
    _$typeDiplayAtom.reportWrite(value, super.typeDiplay, () {
      super.typeDiplay = value;
    });
  }

  final _$searchTextAtom = Atom(name: '_SelectAnyBase.searchText');

  @override
  String get searchText {
    _$searchTextAtom.reportRead();
    return super.searchText;
  }

  @override
  set searchText(String value) {
    _$searchTextAtom.reportWrite(value, super.searchText, () {
      super.searchText = value;
    });
  }

  final _$searchIconAtom = Atom(name: '_SelectAnyBase.searchIcon');

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

  final _$appBarTitleAtom = Atom(name: '_SelectAnyBase.appBarTitle');

  @override
  Widget? get appBarTitle {
    _$appBarTitleAtom.reportRead();
    return super.appBarTitle;
  }

  @override
  set appBarTitle(Widget? value) {
    _$appBarTitleAtom.reportWrite(value, super.appBarTitle, () {
      super.appBarTitle = value;
    });
  }

  final _$confirmToLoadDataAtom =
      Atom(name: '_SelectAnyBase.confirmToLoadData');

  @override
  bool get confirmToLoadData {
    _$confirmToLoadDataAtom.reportRead();
    return super.confirmToLoadData;
  }

  @override
  set confirmToLoadData(bool value) {
    _$confirmToLoadDataAtom.reportWrite(value, super.confirmToLoadData, () {
      super.confirmToLoadData = value;
    });
  }

  final _$pageAtom = Atom(name: '_SelectAnyBase.page');

  @override
  int get page {
    _$pageAtom.reportRead();
    return super.page;
  }

  @override
  set page(int value) {
    _$pageAtom.reportWrite(value, super.page, () {
      super.page = value;
    });
  }

  final _$totalAtom = Atom(name: '_SelectAnyBase.total');

  @override
  int get total {
    _$totalAtom.reportRead();
    return super.total;
  }

  @override
  set total(int value) {
    _$totalAtom.reportWrite(value, super.total, () {
      super.total = value;
    });
  }

  final _$listAtom = Atom(name: '_SelectAnyBase.list');

  @override
  ObservableList<ItemSelectTable> get list {
    _$listAtom.reportRead();
    return super.list;
  }

  @override
  set list(ObservableList<ItemSelectTable> value) {
    _$listAtom.reportWrite(value, super.list, () {
      super.list = value;
    });
  }

  final _$loadingAtom = Atom(name: '_SelectAnyBase.loading');

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  final _$loadedAtom = Atom(name: '_SelectAnyBase.loaded');

  @override
  bool get loaded {
    _$loadedAtom.reportRead();
    return super.loaded;
  }

  @override
  set loaded(bool value) {
    _$loadedAtom.reportWrite(value, super.loaded, () {
      super.loaded = value;
    });
  }

  final _$quantityItensPageAtom =
      Atom(name: '_SelectAnyBase.quantityItensPage');

  @override
  int? get quantityItensPage {
    _$quantityItensPageAtom.reportRead();
    return super.quantityItensPage;
  }

  @override
  set quantityItensPage(int? value) {
    _$quantityItensPageAtom.reportWrite(value, super.quantityItensPage, () {
      super.quantityItensPage = value;
    });
  }

  final _$loadingMoreAtom = Atom(name: '_SelectAnyBase.loadingMore');

  @override
  bool get loadingMore {
    _$loadingMoreAtom.reportRead();
    return super.loadingMore;
  }

  @override
  set loadingMore(bool value) {
    _$loadingMoreAtom.reportWrite(value, super.loadingMore, () {
      super.loadingMore = value;
    });
  }

  final _$showSearchAtom = Atom(name: '_SelectAnyBase.showSearch');

  @override
  bool get showSearch {
    _$showSearchAtom.reportRead();
    return super.showSearch;
  }

  @override
  set showSearch(bool value) {
    _$showSearchAtom.reportWrite(value, super.showSearch, () {
      super.showSearch = value;
    });
  }

  final _$actualFiltersAtom = Atom(name: '_SelectAnyBase.actualFilters');

  @override
  GroupFilterExp get actualFilters {
    _$actualFiltersAtom.reportRead();
    return super.actualFilters;
  }

  @override
  set actualFilters(GroupFilterExp value) {
    _$actualFiltersAtom.reportWrite(value, super.actualFilters, () {
      super.actualFilters = value;
    });
  }

  @override
  String toString() {
    return '''
typeDiplay: ${typeDiplay},
searchText: ${searchText},
searchIcon: ${searchIcon},
appBarTitle: ${appBarTitle},
confirmToLoadData: ${confirmToLoadData},
page: ${page},
total: ${total},
list: ${list},
loading: ${loading},
loaded: ${loaded},
quantityItensPage: ${quantityItensPage},
loadingMore: ${loadingMore},
showSearch: ${showSearch},
actualFilters: ${actualFilters},
listaExibida: ${listaExibida}
    ''';
  }
}
