import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk_utils/extensions/map.dart';
import 'package:msk_utils/utils/utils_platform.dart';
import 'package:select_any/select_any.dart';

import 'select_fk_controller.dart';

typedef SelectedFK = Future<bool> Function(Map<String, dynamic> obj, Function);

typedef ValidationSelect = Future<bool> Function(Map<String, dynamic> obj);

// ignore: must_be_immutable
class SelectFKWidget extends StatelessWidget {
  final SelectFKController controller;
  final String title;
  final String id;
  final DataSource dataSource;
  final List<Linha> linhas;

  /// Dispara toda fez que um registro é selecionado
  /// Caso retorne false, a seleção é cancelada
  final SelectedFK selectedFK;
  final ValidationSelect preValidationSelect;
  final List<Acao> actions;
  final List<Acao> buttons;
  Linha defaultLine;
  final bool isRequired;
  SelectModel selectModel;

  /// Custom theme
  SelectModelTheme theme;

  ///
  final double height;
  final Color customColor;
  final String defaultLabel;
  final bool showTextTitle;

  SelectFKWidget(
      this.title, this.id, this.linhas, this.controller, this.dataSource,
      {this.defaultLine,
      this.selectedFK,
      this.preValidationSelect,
      this.actions,
      this.buttons,
      this.isRequired = false,
      this.theme,
      this.height = 45,
      this.customColor,
      this.defaultLabel,
      this.showTextTitle = true}) {
    if (this.defaultLine == null) {
      this.defaultLine = linhas.first;
    }
    actions?.forEach((element) {
      element.fecharTela = true;
    });
    buttons?.forEach((element) {
      element.fecharTela = true;
    });
    selectModel = SelectModel(
        title, id, linhas, dataSource, SelectAnyPage.TIPO_SELECAO_SIMPLES,
        abrirPesquisaAutomaticamente: !UtilsPlatform.isMobile,
        acoes: actions,
        botoes: buttons,
        theme: theme);
    if (isRequired == true) {
      controller.checkSingleRow(selectModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onShowFocusHighlight: (bool b) {
        controller.inFocus = b;
      },
      autofocus: true,
      child: Column(children: [
        if (title.isNotEmpty && showTextTitle)
          Padding(
            padding:
                const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 8),
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        InkWell(onLongPress: () {
          clearObj(context);
        }, onTap: () async {
          if (preValidationSelect == null ||
              await preValidationSelect(controller.obj) == true) {
            var res = await Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) =>
                    new SelectAnyModule(selectModel)));
            if (res != null) {
              if (selectedFK != null) {
                if (await selectedFK(res, (bool b) {
                      if (b == true) {
                        controller.obj = res;
                      }
                    }) ==
                    true) {
                  controller.obj = res;
                }
              } else {
                controller.obj = res;
              }
            }
          }
        }, child: Container(child: Observer(builder: (_) {
          return MouseRegion(
              onEnter: (_) {
                controller.showClearIcon = true;
              },
              onExit: (_) {
                controller.showClearIcon = false;
              },
              child: Container(
                height: height,
                constraints: BoxConstraints(maxWidth: 500),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(
                            minWidth: 45,
                            maxWidth: 500,
                            minHeight: height,
                            maxHeight: 60),
                        decoration: BoxDecoration(
                            color: customColor ??
                                (controller.inFocus
                                    ? Theme.of(context).accentColor
                                    : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Color(0xFF515151)
                                        : Color(0xFFf5f5f5)),
                            borderRadius: BorderRadius.circular(height / 2)),
                        child: Container(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          alignment: Alignment.centerLeft,
                          child: Observer(
                            builder: (_) {
                              String valor = controller.obj == null
                                  ? (defaultLabel ?? 'Toque para selecionar')
                                  : (controller.obj[defaultLine.chave] ==
                                              null ||
                                          controller.obj[defaultLine.chave]
                                              .toString()
                                              .isEmpty)
                                      ? (defaultLine.valorPadrao != null
                                          ? defaultLine
                                              .valorPadrao(controller.obj)
                                          : 'Linha vazia')
                                      : controller.obj
                                          .getLineValue(defaultLine.chave)
                                          .toString();
                              return defaultLine.personalizacao == null
                                  ? Text(
                                      (defaultLine.involucro != null
                                          ? defaultLine.involucro
                                              .replaceAll('???', valor)
                                          : valor),
                                      maxLines: 2,
                                      style: controller.inFocus
                                          ? TextStyle(color: Colors.white)
                                          : TextStyle(color: defaultLine.color),
                                    )
                                  : defaultLine.personalizacao(
                                      CustomLineData(data: controller.obj));
                            },
                          ),
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: IconButton(
                          icon: Icon(Icons.close),
                          tooltip: 'Limpar',
                          onPressed: () {
                            clearObj(context);
                          }),
                      secondChild: SizedBox(),
                      duration: Duration(milliseconds: 300),
                      reverseDuration: Duration(milliseconds: 300),
                      crossFadeState: !UtilsPlatform.isMobile &&
                              controller.showClearIcon &&
                              controller.obj != null
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                    )
                  ],
                ),
              ));
        })))
      ]),
    );
  }

  void clearObj(BuildContext context) {
    controller.clear();
    showSnackMessage(context, 'Campo limpo com sucesso');
  }
}
