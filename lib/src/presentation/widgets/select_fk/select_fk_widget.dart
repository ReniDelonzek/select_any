import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/msk_utils.dart';
import 'package:select_any/select_any.dart';
import 'package:select_any/src/presentation/widgets/utils_snack.dart';

typedef SelectedFK = Future<bool> Function(Map<String, dynamic>? obj, Function);

typedef AllowSelect = Future<bool> Function();

typedef ConvertValue = Future<Map<String, dynamic>> Function(dynamic obj);

enum TypeView { selectable, radioList, customChipList, dropdown }

// ignore: must_be_immutable
class SelectFKWidget extends StatelessWidget {
  /// Prodive a controller
  final SelectFKController controller;

  /// Title displayed above selector
  final String title;

  /// Id Column that contains some unique identifier in the [dataSource]
  final String id;

  /// Source of data displayed for selection
  final DataSource dataSource;

  /// Lines that should be displayed (if the selection type is different [TypeView.selectable], only the first one is displayed)
  final List<Line> lines;

  /// Calls every time a record is selected. If it returns false, the selection is canceled
  final SelectedFK? selectedFK;

  /// List screen actions
  final List<ActionSelect>? actions;

  /// Buttons screen actions
  final List<ActionSelect>? buttons;
  Line? defaultLine;
  final bool isRequired;

  /// Custom theme
  SelectModelTheme? theme;

  final TypeView typeView;

  /// Caso seja necessário aplicar alguma conversão do valor selecionado
  final ConvertValue? convertValue;

  /// Height the selector widget
  final double height;

  /// Width the selector dropdown widget
  final double? dropdownWidth;

  /// Custom color the selector widget
  final Color? customColor;

  /// Label in the selector when value is null
  final String defaultLabel;

  /// Custom title above the selector
  final Widget? customTitle;

  /// Specifies a special title for the list screen
  final String? customListTitle;

  /// Provide data that will be sent to the datasource
  final Map<String, dynamic> Function()? dataToSelect;

  /// Triggered when the value is cleared by the user
  final Function? cleanValue;

  /// Show when typeView is radioList, customChipList, dropdown and list data is empty
  final Widget? customEmptyList;

  /// Padding chip when typeView is customChipList
  final EdgeInsets customChipPadding;

  /// If the TypeView is [radioList, customChipList, dropdown]
  /// the function is activated, making it possible to perform a pre-selection
  final Future<Map<String, dynamic>?> Function(ObservableList<ItemSelect>)?
      setDefaultSelectionList;

  /// When in list mode, display on cards regardless of the number of lines
  final bool? showInCards;

  /// Custom message when field is cleared
  final String messageWhenValueCleared;

  final Future<bool> Function()? allowEdit;

  SelectFKWidget(
    this.title,
    this.id,
    this.lines,
    this.controller,
    this.dataSource, {
    this.defaultLine,
    this.selectedFK,
    this.actions,
    this.buttons,
    this.isRequired = false,
    this.theme,
    this.typeView = TypeView.selectable,
    this.convertValue,
    this.height = 45,
    this.dropdownWidth,
    this.customColor,
    this.defaultLabel = 'Toque para selecionar',
    this.customTitle,
    this.customListTitle,
    this.dataToSelect,
    this.cleanValue,
    this.customEmptyList,
    this.customChipPadding =
        const EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16),
    this.setDefaultSelectionList,
    this.showInCards,
    this.messageWhenValueCleared = 'Campo limpo com sucesso',
    this.allowEdit,
  }) {
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
          showInCards: showInCards,
          theme: theme ?? SelectModelTheme());
    }
    if (isRequired) {
      controller.checkSingleRow();
    }
    if (typeView != TypeView.selectable) {
      controller.loadData(data: dataToSelect?.call());
    }
    controller.setDefaultSelection = setDefaultSelectionList;
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
            customTitle ??
                (title.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: 16, left: 8, right: 8, bottom: 8),
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            title,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      )
                    : SizedBox()),
            typeView != TypeView.selectable
                ? _buildList(context)
                : InkWell(
                    key: Key('key_inkewell_$title'),
                    onLongPress: () {
                      clearObj(context);
                    },
                    onTap: () async {
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
                    },
                    child: Container(child: Observer(builder: (_) {
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
                                    height: height,
                                    constraints: BoxConstraints(
                                        minWidth: 45,
                                        maxWidth: 500,
                                        minHeight: height,
                                        maxHeight: 60),
                                    decoration: _getBoxDecoration(context),
                                    child: Container(
                                        padding: EdgeInsets.only(
                                            left: 15, right: 15),
                                        alignment: Alignment.centerLeft,
                                        child: getWidgetContent(context)),
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
        return _dropdownButton(context);
      }

      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        runAlignment: WrapAlignment.start,
        direction: Axis.horizontal,
        spacing: 8,
        children: typeView == TypeView.radioList
            ? _radioList(context)
            : _customChipList(context),
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
              onDoubleTap: () {
                clearObj(context);
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
                        key: Key('radio_select_${element.id}'),
                        onChanged: (value) {
                          _validateSelectList(element.object);
                        },
                      );
                    }),
                    SizedBox(width: 8),
                    Text(element.strings.values.first ?? '',
                        style: theme.textTheme.titleMedium)
                  ],
                ),
              ),
            ))
        .toList();
  }

  List<Widget> _customChipList(BuildContext context) {
    return controller.list
        .map((element) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Observer(builder: (_) {
                return ButtonChip(
                  '${element.strings.values.firstOrNull ?? ''}',
                  isSelected: controller.obj == element.object,
                  onTap: () {
                    _validateSelectList(element.object);
                  },
                  padding: customChipPadding,
                  onLongPress: () {
                    clearObj(context);
                  },
                );
              }),
            ))
        .toList();
  }

  Widget _dropdownButton(BuildContext context) {
    return Container(
      height: height,
      width: dropdownWidth,
      decoration: _getBoxDecoration(context),
      child: Padding(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
              value: controller.obj,
              onChanged: (newValue) {
                _validateSelectList(newValue);
              },
              items: controller.list
                  .map((element) => DropdownMenuItem(
                      value: element.object,
                      child:
                          Text('${element.strings.values.firstOrNull ?? ''}')))
                  .toList()),
        ),
      ),
    );
  }

  void clearObj(BuildContext context) async {
    if (await _preValidate()) {
      controller.clear();
      showSnackMessage(context, 'Campo limpo com sucesso');
      cleanValue?.call();
    }
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
    return (allowEdit == null || await allowEdit!() == true);
  }

  Future<void> _convertValue(res) async {
    if (convertValue != null) {
      res = await convertValue!(res);
    }
    controller.obj = res;
  }

  BoxDecoration _getBoxDecoration(BuildContext context) {
    return BoxDecoration(
        color: customColor ??
            (controller.inFocus
                ? UtilsColorSelect.getAccentColor(context)
                : Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF515151)
                    : Color(0xFFf5f5f5)),
        borderRadius: BorderRadius.circular(20));
  }

  Widget getWidgetContent(BuildContext context) {
    return Observer(
      builder: (_) {
        if (defaultLine!.customLine != null) {
          return defaultLine!
              .customLine!(CustomLineData(data: controller.obj, typeScreen: 1));
        }
        String value;
        if (controller.obj == null) {
          value = defaultLabel;
        } else if (controller.obj![defaultLine!.key] == null ||
            controller.obj![defaultLine!.key].toString().isEmpty) {
          value = defaultLine!.defaultValue != null
              ? defaultLine!.defaultValue!(controller.obj)
              : 'Linha vazia';
        } else if (defaultLine!.formatData != null) {
          value = defaultLine!.formatData!.formatData(ObjFormatData(
              data: controller.obj![defaultLine!.key], map: controller.obj));
        } else {
          value = controller.obj.getLineValue(defaultLine!.key).toString();
        }
        if (defaultLine!.enclosure != null) {
          value = defaultLine!.enclosure!.replaceAll('???', value);
        }
        return Text(
          value,
          maxLines: 2,
          style: controller.inFocus
              ? TextStyle(color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xFFFDFDFD)
                      : Color(0xFF323232))
              : defaultLine!.textStyle
                  ?.call(ObjFormatData(data: value, map: controller.obj)),
        );
      },
    );
  }
}
