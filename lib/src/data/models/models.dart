import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/extensions/date.dart';
import 'package:msk_utils/extensions/string.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:msk_utils/utils/utils_platform.dart';
import 'package:select_any/select_any.dart';

part 'models.g.dart';

enum TypeSelect {
  /// Returns Map<String, dynamic>
  SIMPLE,

  /// Returns [ItemSelect]
  MULTIPLE,
  ACTION
}

class CustomBottomBuilderArgs {
  BuildContext context;
  GroupFilterExp? filter;
  bool isLoaded;
  DataSource? actualDataSource;
  List<ItemSelectTable> partialData;
  CustomBottomBuilderArgs(this.context, this.filter, this.isLoaded,
      this.actualDataSource, this.partialData);
}

typedef Widget CustomBottomBuilder(CustomBottomBuilderArgs args);

class SelectModel {
  /// Selection type
  TypeSelect typeSelect;

  /// Titulo a ser exibido na parte superior
  String title;

  /// Lista de linhas a serem exibidas
  List<Line> lines;

  /// Chave do id de cada linha
  String id;
  List<FilterBase>? filters;

  /// Ações que serão selecionáveis após o clique em cada item
  List<ActionSelect>? actions;

  /// Botões que apareceram no canto inferior direito
  List<ActionSelectBase>? buttons;

  /// Indica a fonte dos dados a ser exibidos
  DataSource dataSource;

  /// Uma lista dos ids que devem iniciar pré-selecionados
  @Deprecated("Use preSelected")
  List<int>? selectedItens;

  /// Uma lista dos ids que devem iniciar pré-selecionados
  List<ItemSelect>? preSelected;

  // ignore: deprecated_member_use_from_same_package
  /// define se os itens já selecionados que constam na lista [selectedItens] ou [preSelected]
  /// Devem aparecer na listagem ou não
  bool showPreSelected;

  /// Caso a fonte de daos principal falhe, tenta buscar os dados da segunda fonte
  DataSource? alternativeDataSource;

  /// Caso seja true, abre a pesquisa automaticamente
  bool? openSearchAutomatically;

  /// caso true, não carrega os dados automaticamente, exibindo um botão na tela para fazer isso
  bool confirmToLoadData;

  /// Indica se o botão de selecionar todos ficará visível ou não
  bool? allowSelectAll;

  /// Indica se devem aparecer os campos de filtro para a tabela (EXPERIMENTAL)
  bool showFiltersInput;

  /// Custom theme
  SelectModelTheme theme;

  /// Widget to fill the bottom left corner of the table
  CustomBottomBuilder? tableBottomBuilder;

  /// Widget to fill the bottom of the list
  CustomBottomBuilder? listBottomBuilder;

  /// Set default filter on table
  Future<Line?> Function(List<Line>)? initialFilter;

  /// Indicates that the content in the listing must always be presented on cards
  bool? showInCards;

  SelectModel(this.title, this.id, this.lines, this.dataSource, this.typeSelect,
      {this.filters,
      this.actions,
      this.buttons,
      this.selectedItens,
      this.showPreSelected = false,
      this.alternativeDataSource,
      this.openSearchAutomatically,
      this.preSelected,
      this.confirmToLoadData = false,
      this.allowSelectAll,
      this.showFiltersInput = true,
      this.theme = const SelectModelTheme(tableTheme: SelectModelThemeTable()),
      this.tableBottomBuilder,
      this.initialFilter,
      this.listBottomBuilder,
      this.showInCards}) {
    if (openSearchAutomatically == null) {
      openSearchAutomatically = !UtilsPlatform.isMobile;
    }
    if (buttons != null &&
        buttons!.where((element) => element is ActionSelect).length > 1) {
      int i = 0;
      while (i < buttons!.length) {
        if ((i -
                    buttons!
                        .sublist(0, i)
                        .where((element) => !(element is ActionSelect))
                        .length) >
                0 &&
            buttons![i] is ActionSelect) {
          if ((buttons![i] as ActionSelect).floatingActionButtonMini == null) {
            (buttons![i] as ActionSelect).floatingActionButtonMini = true;
          }
        }
        i++;
      }
    }
    if (showInCards == null) {
      showInCards = lines.length > 2;
    }
  }
}

class SelectModelTheme {
  final SelectModelThemeTable tableTheme;

  /// Indicates whether the title should be in the center
  final bool centerTitle;

  /// Color AppBar
  final Color? appBarBackgroundColor;

  final Color? backgroundColor;

  final TextStyle? defaultTextStyle;

  final Color? defaultIconActionColor;

  final EdgeInsets? paddingAppBarActions;

  final ButtonPosition Function(int typeScreen) defaultButtonPosition;

  const SelectModelTheme(
      {this.tableTheme = const SelectModelThemeTable(),
      this.centerTitle = true,
      this.appBarBackgroundColor,
      this.backgroundColor,
      this.defaultTextStyle,
      this.defaultIconActionColor,
      this.paddingAppBarActions,
      this.defaultButtonPosition = getDefaultButtonPosition});
}

class SelectModelThemeTable {
  /// Header color
  final Color? headerColor;

  /// Indicates whether the table should be displayed inside a card.
  final bool showTableInCard;

  /// Custom width column
  final Map<int, TableColumnWidth>? widthTableColumns;

  final TextStyle? headerTextStyle;

  final Color? bottomIconsColor;

  /// Table padding
  final EdgeInsetsGeometry tablePadding;

  const SelectModelThemeTable(
      {this.headerColor = const Color(0xFF00823A),
      this.showTableInCard = true,
      this.widthTableColumns,
      this.tablePadding = const EdgeInsets.only(left: 16, right: 16),
      this.headerTextStyle,
      this.bottomIconsColor});
}

enum ButtonPosition { APPBAR, BOTTOM, IN_TABLE }

class Line {
  String key;

  /// *Only on the list*
  /// Wrapping text for content
  /// Example: My enclosure: ???
  /// Where ??? will be replaced by the content of the line
  String? enclosure;

  /// Build Custom Widget
  CustomLine? customLine;

  /// Default value where value is null or empty
  DefaultValue? defaultValue;

  /// Usado para o cabeçalho em tabelas
  String? name;

  /// Caso seja != null, infica que o resultado é uma lista, e as quais linhas devem ser exibidas
  List<Line>? listKeys;

  /// Define o estilo do texto a ser apresentado
  TextStyle Function(ObjFormatData)? textStyle;

  /// Você pode espeficicar uma formatação a ser aplicada
  FormatData? formatData;

  FilterBase? filter;

  TypeData? typeData;

  int maxLines;

  int? minLines;

  bool enableSorting;

  bool? showTextInTableScroll;

  /// Indicates whether the line must support filters specific to it
  bool? enableLineFilter;

  /// Show sizedbox when empty row
  bool showSizedBoxWhenEmpty;

  /// Custom table tooltip
  String? tableTooltip;

  /// Indicate the line is the result of aggregate.
  /// It is useful for building SQL queries correctly
  bool isAgregate;

  Line(this.key,
      {this.enclosure,
      this.customLine,
      this.defaultValue,
      this.name,
      this.listKeys,
      this.textStyle,
      this.formatData,
      this.filter,
      this.typeData,
      this.maxLines = 1,
      this.minLines,
      this.enableSorting = true,
      this.showTextInTableScroll,
      this.enableLineFilter,
      this.showSizedBoxWhenEmpty = false,
      this.tableTooltip,
      this.isAgregate = false}) {
    if (filter == null) {
      if (typeData is TDDateTimestamp) {
        filter = FilterRangeDate();
        if (formatData == null) {
          formatData =
              FormatDataTimestamp((typeData as TDDateTimestamp).outputFormat);
        }
      } else {
        filter = FilterText();
      }
    }
    if (enableLineFilter == null) {
      enableLineFilter = customLine == null;
    }
    if (name == null) {
      final pascalWords = RegExp(r"(?:[A-Z]+|^)[a-z]*");
      List<String?> getPascalWords(String input) =>
          pascalWords.allMatches(input).map((m) => m[0]).toList();
      name = getPascalWords(key).join(' ').upperCaseFirst();
    }
    if (enclosure != null &&
        enclosure!.isNotEmpty &&
        !enclosure!.contains('???')) {
      enclosure = enclosure! + ' ???';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Line &&
        other.key == key &&
        other.enclosure == enclosure &&
        other.defaultValue == defaultValue &&
        other.name == name &&
        listEquals(other.listKeys, listKeys) &&
        other.textStyle == textStyle &&
        other.formatData == formatData &&
        other.filter == filter &&
        other.typeData == typeData;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        enclosure.hashCode ^
        defaultValue.hashCode ^
        name.hashCode ^
        listKeys.hashCode ^
        textStyle.hashCode ^
        formatData.hashCode ^
        filter.hashCode ^
        typeData.hashCode;
  }
}

abstract class TypeData {}

abstract class TDDate extends TypeData {
  String outputFormat;

  TDDate({this.outputFormat = 'dd/MM/yyyy'});
}

class TDDateString extends TDDate {
  TDDateString({String outputFormat = 'dd/MM/yyyy'})
      : super(outputFormat: outputFormat);
}

class TDDateTimestamp extends TDDate {
  TDDateTimestamp({String outputFormat = 'dd/MM/yyyy'})
      : super(outputFormat: outputFormat);
}

class TDMoney extends TypeData {}

class TDString extends TypeData {}

class TDNumber extends TypeData {}

class TDBoolean extends TypeData {}

/// Generic class that represents a non-string value, do not use outside the app
class TDNotString extends TypeData {}

typedef CustomLine = Widget Function(CustomLineData);

class CustomLineData {
  dynamic data;
  int typeScreen;
  CustomLineData({
    this.data,
    required this.typeScreen,
  });
}

typedef DefaultValue = String Function(dynamic data);

class ObjFormatData {
  dynamic data;
  Map? map;
  ObjFormatData({this.data, this.map});
}

abstract class FormatData {
  String defaultValue;
  FormatData({this.defaultValue = ''});
  String formatData(ObjFormatData obj);
}

class FormatDataDate extends FormatData {
  late String inputFormat;
  late String outputFormat;

  @override
  String formatData(ObjFormatData obj) {
    try {
      String? data;
      if (obj.data is String) {
        data = obj.data;
      } else {
        data = obj.data?.toString();
      }
      return data.toDate(inputFormat).string(outputFormat);
    } catch (error, _) {
      // UtilsSentry.reportError(error, stackTrace);
    }
    return defaultValue;
  }
}

class FormatDataTimestamp extends FormatData {
  String outputFormat;

  FormatDataTimestamp(this.outputFormat, {String defaultValue = ''})
      : super(defaultValue: defaultValue);

  @override
  String formatData(ObjFormatData data) {
    try {
      if (data.data == null) return defaultValue;
      return DateTime.fromMillisecondsSinceEpoch(data.data.toString().toInt())
          .string(outputFormat);
    } catch (error, _) {
      // UtilsSentry.reportError(error, stackTrace);
    }
    return defaultValue;
  }
}

class FormatDataAny extends FormatData {
  Function(ObjFormatData) format;
  FormatDataAny(this.format);

  @override
  String formatData(ObjFormatData data) {
    return format(data);
  }
}

class FormatDataMoney extends FormatData {
  String? locale;
  String? symbol;
  int maxDecimalDigits;

  FormatDataMoney({this.locale, this.symbol, this.maxDecimalDigits = 2});

  @override
  String formatData(ObjFormatData data) {
    try {
      return UtilsFormat.formatMoney(data.data,
          maxDecimalDigits: maxDecimalDigits);
    } catch (error, _) {}
    return defaultValue;
  }
}

class FormatDataBool extends FormatData {
  final String textTrue, textFalse;
  FormatDataBool({this.textTrue = 'Sim', this.textFalse = 'Não'});

  @override
  String formatData(ObjFormatData data) {
    return data.data == true ? textTrue : textFalse;
  }
}

abstract class FilterBase = _FilterBaseBase with _$FilterBase;

abstract class _FilterBaseBase with Store {
  @observable
  ItemDataFilter? selectedValue;

  _FilterBaseBase({this.selectedValue});
}

class FilterRangeDate extends FilterBase {
  DateTime? dateMin;
  DateTime? dateMax;
  DateTime? dateDefault;
  ItemDataFilterRange? selectedValueRange;
  FilterRangeDate(
      {this.dateMin, this.dateMax, this.dateDefault, this.selectedValueRange});
}

class FilterSelectItem extends FilterBase {
  FontDataFilterBase fontDataFilter;

  /// custom key for filters by id
  String? keyFilterId;

  FilterSelectItem(this.fontDataFilter,
      {this.keyFilterId, ItemDataFilter? selectedValue})
      : super(selectedValue: selectedValue);
}

class FilterText extends FilterBase {
  FilterText();
}

class ItemDataFilter {
  String? label;
  dynamic value;
  dynamic idValue;
  ItemDataFilter({this.label, @required this.value, this.idValue});
}

class ItemDataFilterRange extends ItemDataFilter {
  dynamic start;
  dynamic end;

  ItemDataFilterRange({String? label, this.start, this.end})
      : super(label: label, value: null);
}

abstract class FontDataFilterBase {
  Future<List<ItemDataFilter>> getList(
      GroupFilterExp? filters, String textSearch);
}

class FontDataFilterAny extends FontDataFilterBase {
  Future<List<ItemDataFilter>> Function(
      GroupFilterExp? filters, String textSearch) list;
  FontDataFilterAny(this.list);

  @override
  Future<List<ItemDataFilter>> getList(
      GroupFilterExp? filters, String textSearch) async {
    return list(filters, textSearch);
  }
}

class ResponseData {
  int? total;
  Exception? exception;
  List<ItemSelectTable> data;

  /// Campo opcional, indica o filtro aplicado na resposta
  /// Usado para comparar se a resposta ainda é válida de acordo com o input
  String? filter;

  /// Indica o range que esse retorno atende
  /// Por ex: 1-10
  int start;
  int end;
  ResponseData(
      {this.exception,
      required this.data,
      this.total,
      this.filter,
      required this.start,
      required this.end});
}

class ItemSelectTable extends ItemSelect {
  int? position;
  ItemSelectTable({
    this.position,
  });
}

abstract class ActionSelectBase {
  final ButtonPosition Function(int typeScreen)? buttonPosition;

  ActionSelectBase({this.buttonPosition});

  Widget build(ButtonPosition position, void Function()? onTap);
}

typedef BuildWidget = Widget Function(
    ButtonPosition position, void Function()? onTap);

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

ButtonPosition getDefaultButtonPosition(int typeScreen) {
  if (typeScreen == 1) {
    return ButtonPosition.BOTTOM;
  }
  return ButtonPosition.IN_TABLE;
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

typedef FunctionAction = void Function(DataFunction);
typedef FunctionActionUpd = Future<bool> Function(DataFunction);

class ItemSelectExpanded = _ItemSelectExpandedBase with _$ItemSelectExpanded;

class DataFunction {
  dynamic data;
  int? index;
  BuildContext? context;
  DataFunction({this.data, this.index, this.context});
}

abstract class _ItemSelectExpandedBase extends ItemSelect with Store {
  @observable
  ObservableList<ItemSelectExpanded>? items = ObservableList();
  @observable
  bool isExpanded = false;

  _ItemSelectExpandedBase({this.items, this.isExpanded = false});
}

enum TypeSearch { CONTAINS, BEGINSWITH, ENDSWITH, NOTCONTAINS }

abstract class FilterExp {
  Line? line;

  FilterExp({this.line});
}

class FilterExpColumn extends FilterExp {
  dynamic value;
  TypeSearch typeSearch;
  FilterExpColumn(
      {required Line line, this.value, this.typeSearch = TypeSearch.CONTAINS})
      : super(line: line);
}

class FilterExpRangeCollun extends FilterExp {
  DateTime? dateStart;
  DateTime? dateEnd;
  FilterExpRangeCollun({required Line line, this.dateStart, this.dateEnd})
      : super(line: line);
}

class GroupFilterExp extends FilterExp {
  OperatorFilterEx operatorEx;
  List<FilterExp> filterExps;
  GroupFilterExp({
    required this.operatorEx,
    this.filterExps = const [],
  });
}

class FilterSelectColumn extends FilterExp {
  dynamic value;
  TypeSearch typeSearch;
  String? customKey;
  dynamic valueId;
  FilterSelectColumn(
      {required Line line,
      this.value,
      this.typeSearch = TypeSearch.CONTAINS,
      this.customKey,
      this.valueId})
      : super(line: line);
}

enum OperatorFilterEx { AND, OR }

enum EnumTypeSort { ASC, DESC }

extension ExEnumTypeSort on EnumTypeSort {
  String toStringEnum() {
    if (this == EnumTypeSort.ASC) {
      return 'asc';
    } else {
      return 'desc';
    }
  }
}

class ItemSort {
  EnumTypeSort? typeSort;
  Line? line;
  int? indexLine;
  ItemSort({this.typeSort, this.line, this.indexLine});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemSort &&
        other.typeSort == typeSort &&
        other.line == line;
  }

  @override
  int get hashCode => typeSort.hashCode ^ line.hashCode;
}