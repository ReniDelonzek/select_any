import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/msk_utils.dart';
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

  /// Builds a Widget between AppBar and the filter Widgets
  Widget Function(BuildContext)? filterTopBuilder;

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
      this.showInCards,
      this.filterTopBuilder}) {
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

  final TextStyle headerTextStyle;

  final Color? bottomIconsColor;

  /// Table padding
  final EdgeInsetsGeometry tablePadding;

  final TextStyle headerActionsTextStyle;

  const SelectModelThemeTable(
      {this.headerColor = const Color(0xFF00823A),
      this.showTableInCard = true,
      this.widthTableColumns,
      this.tablePadding = const EdgeInsets.only(left: 16, right: 16),
      this.headerTextStyle = const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      this.bottomIconsColor,
      this.headerActionsTextStyle =
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)});
}

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

  bool alwaysShowTextTableInScroll;

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
      this.alwaysShowTextTableInScroll = false,
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
      enclosure = enclosure!.trim() + ': ???';
    }
  }
}

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

class ItemDataFilterRange extends ItemDataFilter {
  dynamic start;
  dynamic end;

  ItemDataFilterRange({String? label, this.start, this.end})
      : super(label: label, value: null);
}

class ItemSelectTable extends ItemSelect {
  int? position;
  ItemSelectTable({this.position, Map<String, dynamic>? strings})
      : super(strings: strings);
}

typedef BuildWidget = Widget Function(
    ButtonPosition position, void Function()? onTap);

typedef FunctionAction = void Function(DataFunction);

typedef FunctionActionUpd = Future<bool> Function(DataFunction);

class DataFunction {
  dynamic data;
  int? index;
  BuildContext? context;
  DataFunction({this.data, this.index, this.context});
}

class ItemSelectExpanded = _ItemSelectExpandedBase with _$ItemSelectExpanded;

abstract class _ItemSelectExpandedBase extends ItemSelect with Store {
  @observable
  ObservableList<ItemSelectExpanded>? items;
  @observable
  bool isExpanded;

  _ItemSelectExpandedBase(
      {required this.items,
      // ignore: unused_element
      this.isExpanded = false,
      Map<String, dynamic>? strings,
      int? id,
      bool isDeleted = false,
      bool isSelected = false,
      dynamic object})
      : super(
            strings: strings,
            id: id,
            isDeleted: isDeleted,
            isSelected: isSelected,
            object: object);

  ItemSelectExpanded clone() {
    return ItemSelectExpanded(
      items:
          ObservableList.of(items!.map((element) => element.clone()).toList()),
      isExpanded: isExpanded,
      strings: strings,
      id: id,
      isDeleted: isDeleted,
      isSelected: isSelected,
      object: object,
    );
  }
}
