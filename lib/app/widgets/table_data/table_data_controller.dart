import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:select_any/app/models/models.dart';

part 'table_data_controller.g.dart';

class TableDataController = _TableDataControllerBase with _$TableDataController;

abstract class _TableDataControllerBase with Store {
  SelectModel selectModel;
  final TextEditingController ctlSearch = TextEditingController();
  @observable
  int page = 1;
  @observable
  int total = 0;
  @observable
  ObservableList<ItemSelectTable> list = ObservableList();
  var error;
  @observable
  bool loading = false;

  /// Guarda os ids de todos os registros selecionados
  /// Necessário para persistir o estado da seleção
  Set<ItemSelect> selectedList = {};

  Map data;

  _TableDataControllerBase({this.data});

  setDataSource() async {
    /// Somente busca os dados caso eles ainda não esteja na lista
    /// Abordagem com problemas, pois a lista pode conter registros de outros ranges
    //if ((page - 1) * 10 >= list.length) {
    loading = true;
    int offset = (page - 1) * 10;
    (await selectModel.fonteDados.getList(10, offset, selectModel, data: data))
        .listen((event) {
      error = null;
      if (ctlSearch.text.trim().isEmpty) {
        /// Remove todos os registros que o id não consta no range retornado
        list.removeWhere((element) {
          return element.position <= event.end &&
              element.position >= event.start &&
              !event.data.any((e2) {
                return e2.id == element.id;
              });
        });

        event.data.forEach((item) {
          bool present = selectedList.any((element) => element.id == item.id);
          if (item.isSelected == true) {
            if (!present) {
              /// Caso o item esteja selecionado e não esteja na lista selectedList
              selectedList.add(item);
            }
          } else {
            item.isSelected = present;
          }
          int index = list.indexWhere((element) => element.id == item.id);
          if (index > -1) {
            list[index] = item;
          } else {
            list.add(item);
          }
        });
        loading = false;
        total = event.total;
      }
    }, onError: (error) {
      print(error);
      loading = false;
      this.error = error;
    });
    //}
  }

  setDataSourceSearch() async {
    loading = true;
    String text = removeDiacritics(ctlSearch.text.trim()).toLowerCase();
    (await selectModel.fonteDados
            .getListSearch(text, 10, (page - 1) * 10, selectModel, data: data))
        .listen((ResponseData event) {
      error = null;

      /// Só altera se o texto ainda for idêntico ao pesquisado
      if (removeDiacritics(ctlSearch.text.trim()).toLowerCase() == text &&
          text == event.filter) {
        /// Remove todos os registros que o id não consta no range retornado
        list.removeWhere((element) {
          return element.position <= event.end &&
              element.position >= event.start &&
              !event.data.any((e2) {
                return e2.id == element.id;
              });
        });

        event.data.forEach((item) {
          bool present = selectedList.any((element) => element.id == item.id);
          if (item.isSelected == true) {
            if (!present) {
              /// Caso o item esteja selecionado e não esteja na lista selectedList
              selectedList.add(item);
            }
          } else {
            item.isSelected = present;
          }

          int index = list.indexWhere((element) => element.id == item.id);
          if (index > -1) {
            list[index] = item;
          } else {
            list.add(item);
          }
        });
        total = event.total;
        loading =
            !(removeDiacritics(ctlSearch.text.trim()).toLowerCase() == text);
      }
    }, onError: (error) {
      print(error);
      loading = false;
      this.error = error;
    });
  }

  reloadData() {
    list.clear();
    if (ctlSearch.text.trim().isEmpty) {
      setDataSource();
    } else {
      setDataSourceSearch();
    }
  }

  removeItem(int id) {
    list.removeWhere((element) => element.id == id);
    --total;
  }
}
