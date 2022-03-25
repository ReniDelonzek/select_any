import 'package:flutter/material.dart';
import 'package:select_any/select_any.dart';

class ActionWidget extends ActionSelectBase {
  BuildWidget buildWidget;
  ActionWidget(this.buildWidget,
      {ButtonPosition Function(int typeScreen)? buttonPosition})
      : super(buttonPosition: buttonPosition);

  @override
  Widget build(ButtonPosition position, void Function()? onTap) {
    return buildWidget(position, onTap);
  }
}

class ActionSelect extends ActionSelectBase {
  /// Keys das colunas a serem enviadas, e o nome como elas devem ir
  Map<String, String>? keys;
  String? description;
  PageRoute? route;
  Widget Function()? page;
  FunctionAction? function;

  /// Tem um papel igual da função, esta porém atualiza a tela quando recebe um resultado verdadeiro
  FunctionActionUpd? functionUpd;
  Widget? icon;

  /// Indica se a tela deve ser fechada ou não
  bool closePage;
  bool? enabled;
  bool? floatingActionButtonMini;

  ActionSelect(
      {this.description,
      this.route,
      this.keys,
      this.function,
      this.icon,
      this.page,
      this.closePage = false,
      this.functionUpd,
      this.enabled,
      this.floatingActionButtonMini,
      ButtonPosition Function(int typeScreen)? buttonPosition})
      : super(buttonPosition: buttonPosition) {
    if (enabled == null) {
      enabled = function != null ||
          functionUpd != null ||
          page != null ||
          route != null;
    }
  }

  @override
  Widget build(ButtonPosition position, void Function()? onTap) {
    if (position == ButtonPosition.BOTTOM) {
      return FloatingActionButton(
        heroTag: description,
        mini: floatingActionButtonMini ?? false,
        tooltip: description,
        onPressed: enabled == true ? onTap : null,
        child: icon ?? Icon(Icons.add),
      );
    }
    return IconButton(
      splashRadius: 24,
      icon: icon ?? Icon(Icons.add),
      tooltip: description,
      onPressed: enabled == true ? onTap : null,
    );
  }
}
