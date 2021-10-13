// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select_fk_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SelectFKController on _SelectFKBase, Store {
  final _$inFocusAtom = Atom(name: '_SelectFKBase.inFocus');

  @override
  bool get inFocus {
    _$inFocusAtom.reportRead();
    return super.inFocus;
  }

  @override
  set inFocus(bool value) {
    _$inFocusAtom.reportWrite(value, super.inFocus, () {
      super.inFocus = value;
    });
  }

  final _$objAtom = Atom(name: '_SelectFKBase.obj');

  @override
  Map<String, dynamic>? get _obj {
    _$objAtom.reportRead();
    return super._obj;
  }

  @override
  set _obj(Map<String, dynamic>? value) {
    _$objAtom.reportWrite(value, super._obj, () {
      super._obj = value;
    });
  }

  final _$showClearIconAtom = Atom(name: '_SelectFKBase.showClearIcon');

  @override
  bool get showClearIcon {
    _$showClearIconAtom.reportRead();
    return super.showClearIcon;
  }

  @override
  set showClearIcon(bool value) {
    _$showClearIconAtom.reportWrite(value, super.showClearIcon, () {
      super.showClearIcon = value;
    });
  }

  final _$listAtom = Atom(name: '_SelectFKBase.list');

  @override
  ObservableList<ItemSelect<dynamic>> get list {
    _$listAtom.reportRead();
    return super.list;
  }

  @override
  set list(ObservableList<ItemSelect<dynamic>> value) {
    _$listAtom.reportWrite(value, super.list, () {
      super.list = value;
    });
  }

  final _$listIsLoadedAtom = Atom(name: '_SelectFKBase.listIsLoaded');

  @override
  bool get listIsLoaded {
    _$listIsLoadedAtom.reportRead();
    return super.listIsLoaded;
  }

  @override
  set listIsLoaded(bool value) {
    _$listIsLoadedAtom.reportWrite(value, super.listIsLoaded, () {
      super.listIsLoaded = value;
    });
  }

  @override
  String toString() {
    return '''
inFocus: ${inFocus},
obj: ${_obj},
showClearIcon: ${showClearIcon},
list: ${list},
listIsLoaded: ${listIsLoaded}
    ''';
  }
}
