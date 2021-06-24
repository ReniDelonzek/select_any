import 'package:diacritic/diacritic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:select_any/src/models/models.dart';

part 'select_any_expanded_controller.g.dart';

class SelectAnyExpandedController = _SelectAnyExpandedBase
    with _$SelectAnyExpandedController;

abstract class _SelectAnyExpandedBase with Store {
  final TextEditingController filter = new TextEditingController();
  final ObservableList<ItemSelectExpanded> itens;
  String searchText = "";
  String title;
  _SelectAnyExpandedBase(this.title, this.itens) {
    appBarTitle = Text(title);
    addFilterListener();
    listaOriginal = itens;
    listaExibida = itens;
  }

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

  /// Cria uma nova variavel, pois se usar a do model,
  /// ela mantém as configurações mesmo depois de sair da tela
  bool confirmarParaCarregarDados = false;

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
