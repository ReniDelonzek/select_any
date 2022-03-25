import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:select_any/src/data/models/models.dart';

import 'select_any_expanded_page.dart';

class SelectAnyExpandedModule extends ModuleWidget {
  final Map? data;
  final SelectModel model;
  final ObservableList<ItemSelectExpanded> itens;

  SelectAnyExpandedModule(this.model, this.itens, {this.data});

  @override
  List<Dependency> get dependencies => [];

  @override
  Widget get view =>
      SelectAnyExpandedPage(this.model, this.itens, data: this.data);

  static Inject get to => Inject<SelectAnyExpandedModule>.of();

  @override
  List<Bloc> get blocs => [];
}
