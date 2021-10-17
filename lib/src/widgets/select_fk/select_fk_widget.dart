import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk_utils/extensions/map.dart';
import 'package:msk_utils/utils/utils_platform.dart';
import 'package:select_any/select_any.dart';
import 'package:select_any/src/utils/utils_color.dart';
import 'package:select_any/src/widgets/button_chip.dart';

import 'select_fk_controller.dart';

typedef SelectedFK = Future<bool> Function(Map<String, dynamic>? obj, Function);

typedef ValidationSelect = Future<bool> Function(Map<String, dynamic>? obj);

typedef ConvertValue = Future<Map<String, dynamic>> Function(dynamic obj);

enum TypeView { selectable, radioList, customChipList, dropdown }

// ignore: must_be_immutable
class SelectFKWidget extends StatelessWidget {
  final SelectFKController controller;
  final String title;
  final String id;
  final DataSource dataSource;
  final List<Line> lines;

  /// Dispara toda fez que um registro é selecionado
  /// Caso retorne false, a seleção é cancelada
  final SelectedFK? selectedFK;
  final ValidationSelect? preValidationSelect;
  final List<ActionSelect>? actions;
  final List<ActionSelect>? buttons;
  Line? defaultLine;
  final bool isRequired;

  /// Custom theme
  SelectModelTheme? theme;

  final TypeView typeView;

  /// Caso seja necessário aplicar alguma conversão do valor selecionado
  final ConvertValue? convertValue;

  ///
  final double height;
  final Color? customColor;
  final String? defaultLabel;
  final bool showTextTitle;

  /// Specifies a special title for the list screen
  final String? customListTitle;

  final Map<String, dynamic> Function()? dataToSelect;

  /// Triggered when the value is cleared by the user
  final Function? cleanValue;

  final Widget? customEmptyList;

  SelectFKWidget(
      this.title, this.id, this.lines, this.controller, this.dataSource,
      {this.defaultLine,
      this.selectedFK,
      this.preValidationSelect,
      this.actions,
      this.buttons,
      this.isRequired = false,
      this.theme,
      this.typeView = TypeView.selectable,
      this.convertValue,
      this.height = 45,
      this.customColor,
      this.defaultLabel,
      this.showTextTitle = true,
      this.customListTitle,
      this.dataToSelect,
      this.cleanValue,
      this.customEmptyList}) {
    if (this.defaultLine == null) {
      this.defaultLine = lines.first;
    }
    controller.labelId = id;
    actions?.forEach((element) {
      element.closePage = true;
    });
    buttons?.forEach((element) {
      element.closePage = true;
    });
    if (controller.selectModel == null) {
      controller.selectModel = SelectModel(
          customListTitle ?? title, id, lines, dataSource, TypeSelect.SIMPLE,
          openSearchAutomatically: !UtilsPlatform.isMobile,
          actions: actions,
          buttons: buttons,
          theme: theme ?? SelectModelTheme());
    }
    if (isRequired == true) {
      controller.checkSingleRow();
    }
    if (typeView != TypeView.selectable) {
      controller.loadData(data: dataToSelect?.call());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      focusNode: controller.focusNode,
      onShowFocusHighlight: (bool b) {
        controller.inFocus = b;
      },
      autofocus: true,
      child: Column(
          crossAxisAlignment: typeView != TypeView.selectable
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            if (title.isNotEmpty && showTextTitle)
              Padding(
                padding: const EdgeInsets.only(
                    top: 16, left: 8, right: 8, bottom: 8),
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            typeView != TypeView.selectable
                ? _buildList(context)
                : InkWell(onLongPress: () {
                    clearObj(context);
                  }, onTap: () async {
                    if (await (_preValidate())) {
                      var res = await Navigator.of(context).push(
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new SelectAnyModule(controller.selectModel,
                                      data: dataToSelect?.call())));
                      if (res != null) {
                        _validateResult(res);
                      }
                      controller.focusNode.requestFocus();
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
                                  height: 45,
                                  constraints: BoxConstraints(
                                      minWidth: 45,
                                      maxWidth: 500,
                                      minHeight: height,
                                      maxHeight: 60),
                                  decoration: BoxDecoration(
                                      color: customColor ??
                                          (controller.inFocus
                                              ? UtilsColor.getAccentColor(
                                                  context)
                                              : Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Color(0xFF515151)
                                                  : Color(0xFFf5f5f5)),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 15),
                                    alignment: Alignment.centerLeft,
                                    child: Observer(
                                      builder: (_) {
                                        String valor = controller.obj == null
                                            ? (defaultLabel ??
                                                'Toque para selecionar')
                                            : (controller.obj![
                                                            defaultLine!.key] ==
                                                        null ||
                                                    controller
                                                        .obj![defaultLine!.key]
                                                        .toString()
                                                        .isEmpty)
                                                ? (defaultLine!.defaultValue !=
                                                        null
                                                    ? defaultLine!
                                                            .defaultValue!(
                                                        controller.obj)
                                                    : 'Linha vazia')
                                                : controller.obj
                                                    .getLineValue(
                                                        defaultLine!.key)
                                                    .toString();
                                        return defaultLine!.customLine == null
                                            ? Text(
                                                (defaultLine!.enclosure != null
                                                    ? defaultLine!.enclosure!
                                                        .replaceAll(
                                                            '???', valor)
                                                    : valor),
                                                maxLines: 2,
                                                style: controller.inFocus
                                                    ? TextStyle(
                                                        color: Colors.white)
                                                    : defaultLine!.textStyle
                                                        ?.call(ObjFormatData(
                                                            data: valor,
                                                            map: controller
                                                                .obj)),
                                              )
                                            : defaultLine!.customLine!(
                                                CustomLineData(
                                                    data: controller.obj));
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedCrossFade(
                                firstChild: Container(
                                  height: height,
                                  child: IconButton(
                                      icon: Icon(Icons.close),
                                      tooltip: 'Limpar',
                                      onPressed: () {
                                        clearObj(context);
                                      }),
                                ),
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

  Widget _buildList(BuildContext context) {
    return Observer(builder: (_) {
      if (!controller.listIsLoaded) {
        return Center(child: CircularProgressIndicator());
      }
      if (controller.list.isEmpty) {
        return customEmptyList ??
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Text('Lista vazia'),
            );
      }
      if (typeView == TypeView.dropdown) {
        return _dropdownButton();
      }

      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        runAlignment: WrapAlignment.start,
        direction: Axis.horizontal,
        spacing: 8,
        children: typeView == TypeView.radioList
            ? _radioList(context)
            : _customChipList(),
      );
    });
  }

  List<Widget> _radioList(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return controller.list
        .map((element) => InkWell(
              onTap: () async {
                _validateSelectList(element.object);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Observer(builder: (_) {
                      return Radio<dynamic>(
                        value: element.object,
                        groupValue: controller.obj,
                        onChanged: (value) {
                          _validateSelectList(element.object);
                        },
                      );
                    }),
                    SizedBox(width: 8),
                    Text(element.strings!.values.first ?? '',
                        style: theme.textTheme.subtitle1)
                  ],
                ),
              ),
            ))
        .toList();
  }

  List<Widget> _customChipList() {
    return controller.list
        .map((element) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Observer(builder: (_) {
                return ButtonChip(
                  '${element.strings?.values.first ?? ''}',
                  isSelected: controller.obj == element.object,
                  onTap: () {
                    _validateSelectList(element.object);
                  },
                );
              }),
            ))
        .toList();
  }

  Widget _dropdownButton() {
    return DropdownButton(
        value: controller.obj,
        items: controller.list
            .map((element) => DropdownMenuItem(
                onTap: () {
                  _validateSelectList(element.object);
                },
                child: Text('${element.strings?.values.first ?? ''}')))
            .toList());
  }

  void clearObj(BuildContext context) {
    controller.clear();
    showSnackMessage(context, 'Campo limpo com sucesso');
    cleanValue?.call();
  }

  void _validateSelectList(obj) async {
    if (await (_preValidate())) {
      _validateResult(obj);
    }
  }

  void _validateResult(res) async {
    if (selectedFK != null) {
      if (await selectedFK!(res, (bool b) {
            if (b == true) {
              _convertValue(res);
            }
          }) ==
          true) {
        _convertValue(res);
      }
    } else {
      _convertValue(res);
    }
  }

  Future<bool> _preValidate() async {
    return (preValidationSelect == null ||
        await preValidationSelect!(controller.obj) == true);
  }

  Future<void> _convertValue(res) async {
    if (convertValue != null) {
      res = await convertValue!(res);
    }
    controller.obj = res;
  }
}
