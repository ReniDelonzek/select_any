import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:select_any/src/models/models.dart';

part 'select_fk_controller.g.dart';

class SelectFKController = _SelectFKBase with _$SelectFKController;

abstract class _SelectFKBase with Store {
  @observable
  bool inFocus = false;
  @observable
  Map<String, dynamic>? obj;
  @observable
  bool showClearIcon = false;

  @observable
  ObservableList<ItemSelect> list = ObservableList();
  @observable
  bool listIsLoaded = false;
  FocusNode focusNode = FocusNode();
  SelectModel? selectModel;

  /// Retorna o valor da chave, caso o objeto não seja null e o valor conste no objeto
  getValueKey(String key) {
    if (obj == null || !obj!.containsKey(key)) {
      return null;
    }
    return obj![key];
  }

  /// Verifica se a [fontData] especificada retorna somente um registro
  /// Caso sim, seta o dado no input
  void checkSingleRow() async {
    /// Deixa o limite como dois, porque caso retorne dois ele possui > 1 registro
    /// Pode ser null caso o widget não tenha sido construído ainda
    selectModel?.dataSource.getList(2, 0, selectModel).then((value) {
      value.first.then((value) {
        if (value.data.length == 1) {
          obj = value.data.first.object;
        }
      });
    });
  }

  /// Limpa o objeto selecionado
  void clear() {
    obj = null;
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
          .getList(-1, -1, selectModel, data: data);
      value?.listen((event) {
        list = ObservableList.of(event.data);
        listIsLoaded = true;
      });
      return;
    }
  }
}
