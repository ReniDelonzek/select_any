import 'package:diacritic/diacritic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:select_any/app/models/models.dart';
import 'package:select_any/app/widgets/table_data/table_data_controller.dart';

part 'select_any_controller.g.dart';

class SelectAnyController = _SelectAnyBase with _$SelectAnyController;

abstract class _SelectAnyBase with Store {
  final TextEditingController filter = new TextEditingController();
  @observable

  /// 1 = List, 2 = Table
  int typeDiplay = 1;
  String searchText = "";
  String title;

  @observable
  Icon searchIcon = new Icon(Icons.search);
  @observable
  Widget appBarTitle;
  ObservableList<ItemSelect> listaOriginal = new ObservableList();
  @observable
  ObservableList<ItemSelect> listaExibida = new ObservableList();
  DataSource fonteDadoAtual;
  @observable
  Stream stream;
  TableDataController tableController;

  /// Cria uma nova variavel, pois se usar a do model,
  /// ela mantém as configurações mesmo depois de sair da tela
  bool confirmarParaCarregarDados = false;

  _SelectAnyBase(this.title) {
    appBarTitle = Text(title);
    addFilterListener();
    tableController = TableDataController();
  }

  addFilterListener() {
    filter.addListener(() {
      if (filter.text.isEmpty) {
        searchText = "";
        listaExibida.clear();
        listaExibida.addAll(listaOriginal);
      } else {
        searchText = filter.text;
        clearList();
        List<ItemSelect> tempList = [];
        String text = removeDiacritics(searchText.toLowerCase());
        for (int i = 0; i < listaOriginal.length; i++) {
          for (var value in listaOriginal[i].strings.values) {
            if (value != null) {
              if (removeDiacritics(value.toString())
                      .toLowerCase()
                      ?.contains(text) ==
                  true) {
                tempList.add(listaOriginal[i]);
                break;
              }
            }
          }
        }
        listaExibida.addAll(tempList);
      }
    });
  }

  @action
  void clearList() {
    this.listaExibida.clear();
  }

  @action
  void setList(List<ItemSelect> list) {
    this.listaExibida.addAll(list);
  }

  void dispose() {
    //super.dispose();
    listaOriginal.clear();
    listaExibida.clear();
    filter.clear();
  }
}
