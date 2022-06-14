import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:select_any/src/data/models/models.dart';
import 'package:select_any/src/domain/repository/data_source.dart';

part 'select_any_expanded_controller.g.dart';

class SelectAnyExpandedController = _SelectAnyExpandedBase
    with _$SelectAnyExpandedController;

abstract class _SelectAnyExpandedBase with Store {
  final TextEditingController filter = new TextEditingController();
  final ObservableList<ItemSelectExpanded> itens;
  String searchText = "";
  String title;

  @observable
  Icon searchIcon = new Icon(Icons.search);
  @observable
  Widget? appBarTitle;
  ObservableList<ItemSelectExpanded> listaOriginal = new ObservableList();
  @observable
  ObservableList<ItemSelectExpanded> listaExibida = new ObservableList();
  DataSource? fonteDadoAtual;

  /// Cria uma nova variavel, pois se usar a do model,
  /// ela mantém as configurações mesmo depois de sair da tela
  bool confirmarParaCarregarDados = false;

  _SelectAnyExpandedBase(this.title, this.itens) {
    appBarTitle = Text(title);
    addFilterListener();
    listaOriginal =
        ObservableList.of(itens.map((element) => element.clone()).toList());
    listaExibida =
        ObservableList.of(itens.map((element) => element.clone()).toList());
  }

  addFilterListener() {
    filter.addListener(() {
      print('aa');
      if (filter.text.isEmpty) {
        searchText = "";
        listaExibida.clear();
        listaExibida.addAll(listaOriginal);
      } else {
        searchText = filter.text;
        listaExibida.clear();
        List<ItemSelectExpanded> tempList = [];
        String text = removeDiacritics(searchText.toLowerCase());
        for (int i = 0; i < listaOriginal.length; i++) {
          ItemSelectExpanded? item =
              getItemIfCompatibleSearch(listaOriginal[i], text);
          if (item != null) {
            tempList.add(item);
          }
        }
        listaExibida.addAll(tempList);
      }
    });
  }

  ItemSelectExpanded? getItemIfCompatibleSearch(
      ItemSelectExpanded item, String text) {
    ItemSelectExpanded? newItem;
    for (var value in item.strings.values) {
      if (value != null) {
        if (removeDiacritics(value.toString()).toLowerCase().contains(text) ==
            true) {
          newItem = item;
          break;
        }
      }
    }
    if (item.items?.isNotEmpty == true) {
      item = item.clone();
      // Faz esse esquema de remover e substuir para que a lista dos filhos fique correta tmb
      for (int i = 0; i < item.items!.length; i++) {
        var newItem = getItemIfCompatibleSearch(item.items![i], text);
        if (newItem == null) {
          item.items!.removeAt(i);
          i--;
        } else {
          item.items![i] = newItem;
        }
      }
      // Caso encontre algum filho compatível, adiciona o objeto na lsita
      if (item.items!.isNotEmpty) {
        newItem = item;
        newItem.isExpanded = true;
      }
    }
    return newItem;
  }

  @action
  void clearList() {
    this.listaExibida.clear();
  }

  @action
  void setList(List<ItemSelectExpanded> list) {
    this.listaExibida.addAll(list);
  }

  void dispose() {
    //super.dispose();
    listaOriginal.clear();
    listaExibida.clear();
    filter.clear();
  }
}
