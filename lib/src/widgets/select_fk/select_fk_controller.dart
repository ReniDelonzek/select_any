import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:select_any/src/models/models.dart';

part 'select_fk_controller.g.dart';

class SelectFKController = _SelectFKBase with _$SelectFKController;

abstract class _SelectFKBase with Store {
  String? labelId;
  @observable
  bool inFocus = false;
  @observable
  Map<String, dynamic>? _obj;

  @computed
  Map<String, dynamic>? get obj {
    return _obj;
  }

  set obj(Map<String, dynamic>? value) {
    _obj = value;
    if (labelId != null) {
      setObjList(_obj, labelId);
    }
  }

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

  /// Retorna o valor da chave, caso o objeto não seja null e o valor conste no objeto
  getValueKey(String key) {
    if (_obj == null || !_obj!.containsKey(key)) {
      return null;
    }
    return _obj![key];
  }

  /// Verifica se a [selectModel.dataSource] especificada retorna somente um registro
  /// Caso sim, seta o dado no input
  void checkSingleRow() async {
    /// Só executa caso o obj esteja null
    /// Verifica novamente dentro da lista pois por ser um método async, no momento de setar os dados essa condição pode mudar
    if (updateFunSingleRow) {
      /// Deixa o limite como dois, porque caso retorne dois ele possui > 1 registro
      /// Pode ser null caso o widget não tenha sido construído ainda
      selectModel?.dataSource.getList(2, 0, selectModel).then((value) {
        value.first.then((value) {
          if (value.data.length == 1 && updateFunSingleRow) {
            _obj = value.data.first.object;
          }
          isCheckedSingleRow = true;
        });
      });
    }
  }

  /// Limpa o objeto selecionado
  void clear() {
    _obj = null;
  }

  /// Atualiza a lista
  void updateList({Map<String, dynamic>? data}) async {
    list.clear();
    listIsLoaded = false;
    selectModel?.dataSource.clear();
    return loadData(data: data);
  }

  /// Carrega os dados da lista, caso ainda não tenham sido carregados
  void loadData({Map<String, dynamic>? data}) async {
    if (!listIsLoaded) {
      /// Pode ser null caso o widget não tenha sido construído ainda
      var value = await selectModel?.dataSource
          .getList(999, -1, selectModel, data: data);
      value?.listen((event) {
        list = ObservableList.of(event.data);

        /// Atualiza o objeto da lista conforme a seleção
        setObjList(_obj, labelId);
        listIsLoaded = true;
      });
      return;
    }
  }

  /// Atualiza o objeto da lista conforme a seleção
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
}
