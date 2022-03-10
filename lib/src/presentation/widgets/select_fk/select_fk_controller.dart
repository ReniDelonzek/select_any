import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:select_any/src/data/models/models.dart';
import 'package:select_any/src/domain/domain.dart';

part 'select_fk_controller.g.dart';

class SelectFKController = _SelectFKBase with _$SelectFKController;

abstract class _SelectFKBase with Store {
  String? labelId;
  @observable
  bool inFocus = false;
  @observable
  Map<String, dynamic>? _obj;

  @observable
  bool showClearIcon = false;

  @observable
  ObservableList<ItemSelect> list = ObservableList();
  @observable
  bool listIsLoaded = false;
  FocusNode focusNode = FocusNode();
  SelectModel? selectModel;

  /// Used to prevent the value from being updated every time the widget is reloaded
  bool isCheckedSingleRow = false;

  bool get updateFunSingleRow => !isCheckedSingleRow && _obj == null;

  Future<Map<String, dynamic>?> Function(ObservableList<ItemSelect>)?
      setDefaultSelection;

  @computed
  Map<String, dynamic>? get obj {
    return _obj;
  }

  set obj(Map<String, dynamic>? value) {
    _obj = value;
    if (labelId != null) {
      setObjList(_obj, labelId);
    }
    if (_obj == null) {
      selectModel?.dataSource.clear();
    }
  }

  /// Returns the value of the key, if the object is not null and the value is in the object
  dynamic getValueKey(String key) {
    if (_obj == null || !_obj!.containsKey(key)) {
      return null;
    }
    return _obj![key];
  }

  /// Checks if the specified [selectModel.dataSource] returns only one record, if so, sets the data in the input
  Future<void> checkSingleRow() async {
    if (updateFunSingleRow) {
      /// Leave the limit as two, because if it returns two it has > 1 record
      Stream<ResponseDataDataSource>? value =
          await selectModel?.dataSource.getList(2, 0, selectModel);
      if (value == null) {
        return null;
      }
      ResponseDataDataSource? response = await value.first;
      if (response.data.length == 1 && updateFunSingleRow) {
        _obj = response.data.first.object;
      }
      isCheckedSingleRow = true;
    }
    return;
  }

  /// Clean the selected obj
  void clear() {
    _obj = null;
  }

  /// Update the list
  void updateList({Map<String, dynamic>? data}) async {
    list.clear();
    listIsLoaded = false;
    selectModel?.dataSource.clear();
    return loadData(data: data);
  }

  /// Load list data if not already loaded
  void loadData({Map<String, dynamic>? data}) async {
    if (!listIsLoaded) {
      /// Can be null if the widget hasn't been built yet
      var value = await selectModel?.dataSource
          .getList(9999, -1, selectModel, data: data);
      value?.listen((event) {
        list = ObservableList.of(event.data);

        /// Updates the list object as per selection
        setObjList(_obj, labelId);
        listIsLoaded = true;
        _defaultValue();
      });
      return;
    }
  }

  /// Updates the list object as per selection
  void setObjList(Map<String, dynamic>? value, String? labelId) {
    if (value != null && labelId != null) {
      for (var element in list) {
        if (element.id == value[labelId]) {
          _obj = element.object;
          element.isSelected = true;
          break;
        }
      }
    }
  }

  void _defaultValue() {
    if (obj == null && setDefaultSelection != null) {
      setDefaultSelection!(list).then((value) {
        if (value != null) {
          obj = value;
        }
      });
    }
  }
}
