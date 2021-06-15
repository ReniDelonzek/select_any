import 'package:diacritic/diacritic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/extensions/date.dart';
import 'package:msk_utils/extensions/map.dart';
import 'package:msk_utils/extensions/string.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:msk_utils/utils/utils_platform.dart';

part 'models.g.dart';

class SelectModel {
  /// 0 selecao simples, 1 selecao multipla, 2 acao
  int tipoSelecao;

  /// Titulo a ser exibido na parte superior
  String titulo;

  /// Lista de linhas a serem exibidas
  List<Linha> linhas;

  /// Chave do id de cada linha
  String id;
  List<FilterBase> filtros;

  /// Ações que serão selecionáveis após o clique em cada item
  List<Acao> acoes;

  /// Botões que apareceram no canto inferior direito
  List<Acao> botoes;
  List<String> legendas;

  /// Indica a fonte dos dados a ser exibidos
  DataSource fonteDados;

  /// Uma lista dos ids que devem iniciar pré-selecionados
  @Deprecated("Use preSelected")
  List<int> itensSelecionados;

  /// Uma lista dos ids que devem iniciar pré-selecionados
  List<ItemSelect> preSelected;

  // ignore: deprecated_member_use_from_same_package
  /// define se os itens já selecionados que constam na lista [itensSelecionados] ou [preSelected]
  /// Devem aparecer na listagem ou não
  bool exibirPreSelecionados;

  /// Caso a fonte de daos principal falhe, tenta buscar os dados da segunda fonte
  DataSource fonteDadosAlternativa;

  /// Caso seja true, abre a pesquisa automaticamente
  bool abrirPesquisaAutomaticamente;

  /// caso true, não carrega os dados automaticamente, exibindo um botão na tela para fazer isso
  bool confirmarParaCarregarDados;

  /// Indica se o botão de selecionar todos ficará visível ou não
  bool permitirSelecionarTodos;

  /// Indica se devem aparecer os campos de filtro para a tabela (EXPERIMENTAL)
  bool showFiltersInput;

  /// Custom theme
  SelectModelTheme theme;

  SelectModel(
      this.titulo, this.id, this.linhas, this.fonteDados, this.tipoSelecao,
      {this.filtros,
      this.acoes,
      this.botoes,
      this.itensSelecionados,
      this.exibirPreSelecionados = false,
      this.fonteDadosAlternativa,
      this.legendas,
      this.abrirPesquisaAutomaticamente,
      this.preSelected,
      this.confirmarParaCarregarDados = false,
      this.permitirSelecionarTodos,
      this.showFiltersInput = true,
      this.theme}) {
    if (abrirPesquisaAutomaticamente == null) {
      abrirPesquisaAutomaticamente = !UtilsPlatform.isMobile;
    }
    if (theme == null) {
      theme = SelectModelTheme(tableTheme: SelectModelThemeTable());
    }
  }
}

class SelectModelTheme {
  final SelectModelThemeTable tableTheme;

  /// Indicates whether the title should be in the center
  final bool centerTitle;

  /// Color AppBar
  final Color appBarBackgroundColor;

  final Color backgroundColor;

  final ButtonsPosition buttonsPosition;

  const SelectModelTheme(
      {this.tableTheme,
      this.centerTitle = true,
      this.appBarBackgroundColor,
      this.backgroundColor,
      this.buttonsPosition = ButtonsPosition.IN_TABLE_AND_BOTTOM});
}

class SelectModelThemeTable {
  /// Header color
  final Color headerColor;

  /// Indicates whether the table should be displayed inside a card.
  final bool showTableInCard;

  /// Custom width column
  final Map<int, TableColumnWidth> widthTableColumns;

  /// Table padding
  final EdgeInsetsGeometry tablePadding;
  const SelectModelThemeTable(
      {this.headerColor = const Color(0xFF00823A),
      this.showTableInCard = true,
      this.widthTableColumns,
      this.tablePadding = const EdgeInsets.only(left: 16, right: 16)})
      : assert(showTableInCard != null);
}

enum ButtonsPosition { APPBAR, BOTTOM, IN_TABLE_AND_BOTTOM }

class Linha {
  String chave;
  Color color;
  String involucro;
  LinhaPersonalizada personalizacao;
  ValorPadrao valorPadrao;

  /// Usado para o cabeçalho em tabelas
  String nome;

  /// Caso seja != null, infica que o resultado é uma lista, e as quais linhas devem ser exibidas
  List<Linha> chavesLista;

  /// Define o estilo do texto a ser apresentado
  TextStyle estiloTexto;

  /// Você pode espeficicar uma formatação a ser aplicada
  FormatData formatData;

  FilterBase filter;

  TypeData typeData;

  int maxLines;

  int minLines;

  bool enableSorting;

  bool showTextInTableScroll;

  /// Indicates whether the line must support filters specific to it
  bool enableLineFilter;

  /// Show sizedbox when empty row
  bool showSizedBoxWhenEmpty;

  Linha(this.chave,
      {this.color,
      this.involucro,
      this.personalizacao,
      this.valorPadrao,
      @required this.nome,
      this.chavesLista,
      this.estiloTexto,
      this.formatData,
      this.filter,
      this.typeData,
      this.maxLines = 1,
      this.minLines,
      this.enableSorting = true,
      this.showTextInTableScroll,
      this.enableLineFilter = true,
      this.showSizedBoxWhenEmpty = false}) {
    if (typeData is TDDateTimestamp && filter == null) {
      filter = FilterRangeDate();
      if (formatData == null) {
        formatData =
            FormatDataTimestamp((typeData as TDDateTimestamp).outputFormat);
      }
    }
    if (enableLineFilter == null && personalizacao != null) {
      enableLineFilter = false;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Linha &&
        other.chave == chave &&
        other.color == color &&
        other.involucro == involucro &&
        other.valorPadrao == valorPadrao &&
        other.nome == nome &&
        listEquals(other.chavesLista, chavesLista) &&
        other.estiloTexto == estiloTexto &&
        other.formatData == formatData &&
        other.filter == filter &&
        other.typeData == typeData;
  }

  @override
  int get hashCode {
    return chave.hashCode ^
        color.hashCode ^
        involucro.hashCode ^
        valorPadrao.hashCode ^
        nome.hashCode ^
        chavesLista.hashCode ^
        estiloTexto.hashCode ^
        formatData.hashCode ^
        filter.hashCode ^
        typeData.hashCode;
  }
}

abstract class TypeData {}

class TDText extends TypeData {}

class TDNumberInt extends TypeData {}

class TDNumberDecimal extends TypeData {}

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

typedef LinhaPersonalizada = Widget Function(CustomLineData);

class CustomLineData {
  dynamic data;
  int typeScreen;
  CustomLineData({
    this.data,
    this.typeScreen,
  });
}

typedef ValorPadrao = String Function(dynamic dados);

class ObjFormatData {
  dynamic data;
  ObjFormatData({
    this.data,
  });
}

abstract class FormatData {
  String defaultValue;
  FormatData({this.defaultValue = ''});
  String formatData(ObjFormatData obj);
}

class FormatDataDate extends FormatData {
  String inputFormat;
  String outputFormat;

  @override
  String formatData(ObjFormatData obj) {
    try {
      String data;
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

  FormatDataTimestamp(this.outputFormat);

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

abstract class FilterBase {
  FilterBase();
}

class FilterRangeDate extends FilterBase {
  DateTime dateMin;
  DateTime dateMax;
  DateTime dateDefault;
  FilterRangeDate({
    this.dateMin,
    this.dateMax,
    this.dateDefault,
  });
}

class FilterSelectItem {
  FontDataFilterBase fontDataFilter;

  FilterSelectItem({this.fontDataFilter});
}

class ItemDataFilter {
  String label;
  int id;
}

abstract class FontDataFilterBase {
  Future<List<ItemDataFilter>> getList();
}

class FontDataFilterStatic extends FontDataFilterBase {
  List<ItemDataFilter> list;
  FontDataFilterStatic(this.list);

  @override
  Future<List<ItemDataFilter>> getList() async {
    return list;
  }
}

abstract class DataSource = _DataSourceBase with _$DataSource;

abstract class _DataSourceBase with Store {
  /// Indica a chave (id) dessa fonte de dados
  final String id;

  /// Indica o tempo de delay (em ms) entre a digitação do usuário e a busca dos dados
  /// É util para econimizar banda
  final int searchDelay;

  /// Indica se será permitido exportar dessa fonte ou não
  final bool allowExport;

  /// Indica se a fonte suporta paginação
  bool supportPaginate;

  /// Indica suporte a filtros por coluna
  bool supportSingleLineFilter;

  @observable
  ObservableList<ItemSelect> listData = ObservableList();

  _DataSourceBase(
      {this.id,
      this.searchDelay = 300,
      this.allowExport = false,
      this.supportPaginate = false,
      this.supportSingleLineFilter = false});

  Future<Stream<ResponseData>> getList(
      int limit, int offset, SelectModel selectModel,
      {Map data,
      bool refresh = false,
      ItemSort itemSort,
      GroupFilterExp filter});

  Future<Stream<ResponseData>> getListSearch(
      String text, int limit, int offset, SelectModel selectModel,
      {Map data,
      bool refresh,
      TypeSearch typeSearch = TypeSearch.CONTAINS,
      ItemSort itemSort});

  List<ItemSelectTable> generateList(
      List data, int offset, SelectModel selectModel) {
    ObservableList<ItemSelectTable> lista = ObservableList();
    offset = offset.abs();
    for (Map a in data) {
      // ignore: deprecated_member_use_from_same_package
      bool preSelecionado = selectModel.itensSelecionados != null &&
          // ignore: deprecated_member_use_from_same_package
          selectModel.itensSelecionados
              .any((element) => element == a[selectModel.id]);
      if (!preSelecionado) {
        preSelecionado = selectModel.preSelected
                ?.any((element) => element.id == a[selectModel.id]) ==
            true;
      }
      //caso nao seja pré-selecionado ou a regra é exibir os pre-selecionados
      if (preSelecionado == false ||
          selectModel.exibirPreSelecionados == true) {
        ItemSelectTable itemSelect = ItemSelectTable();
        for (var linha in selectModel.linhas) {
          // caso seja uma lista
          if (linha.chavesLista != null) {
            String valorLinha = "";
            for (Map map2 in a[linha.chave]) {
              for (Linha linha2 in linha.chavesLista) {
                var ret = map2.getLineValue(linha2.chave);
                valorLinha += '$ret, ';
              }
            }
            if (valorLinha.isNotEmpty) {
              //remove a ultima virgula
              valorLinha.substring(0, valorLinha.length - 2);
            }
            itemSelect.strings[linha.chave] = valorLinha;
          } else {
            itemSelect.strings[linha.chave] = a.getLineValue(linha.chave);
          }
        }

        /// Caso a fonte indique um id, pega dela, se não, pega do modelo
        if (a[this.id ?? selectModel.id] == null && !UtilsPlatform.isRelease) {
          throw ('Id null');
        }
        itemSelect.id = a[this.id ?? selectModel.id];
        itemSelect.isSelected = preSelecionado;
        itemSelect.object = a;
        itemSelect.position = offset++;
        lista.add(itemSelect);
      }
    }
    return lista;
  }

  Future exportData(SelectModel selectModel);

  Future clear();

  bool filterTypeSearch(TypeSearch typeSearch, dynamic value, String text) {
    if (typeSearch == TypeSearch.CONTAINS) {
      return removeDiacritics(value.toString()).toLowerCase()?.contains(text) ==
          true;
    } else if (typeSearch == TypeSearch.BEGINSWITH) {
      return removeDiacritics(value.toString())
              .toLowerCase()
              ?.startsWith(text) ==
          true;
    } else if (typeSearch == TypeSearch.ENDSWITH) {
      return removeDiacritics(value.toString()).toLowerCase()?.endsWith(text) ==
          true;
    } else if (typeSearch == TypeSearch.NOTCONTAINS) {
      return removeDiacritics(value.toString()).toLowerCase()?.contains(text) !=
          true;
    }
    return false;
  }
}

class ResponseData {
  int total;
  Exception exception;
  List<ItemSelectTable> data;

  /// Campo opcional, indica o filtro aplicado na resposta
  /// Usado para comparar se a resposta ainda é válida de acordo com o input
  String filter;

  /// Indica o range que esse retorno atende
  /// Por ex: 1-10
  int start;
  int end;
  ResponseData(
      {this.exception,
      @required this.data,
      this.total,
      this.filter,
      @required this.start,
      @required this.end});
}

class ItemSelectTable extends ItemSelect {
  int position;
  ItemSelectTable({
    this.position,
  });
}

class Acao {
  Map<String, String>
      chaves; //keys das colunas a serem enviadas, e o nome como elas devem ir
  String descricao;
  PageRoute route;
  Widget page;
  bool edicao;
  Funcao funcao;

  /// Tem um papel igual da função, esta porém atualiza a tela quando recebe um resultado verdadeiro
  FuncaoAtt funcaoAtt;
  Widget icon;

  /// Indica se a tela deve ser fechada ou não
  bool fecharTela;

  Acao(
      {this.descricao,
      this.route,
      this.chaves,
      this.edicao,
      this.funcao,
      this.icon,
      this.page,
      this.fecharTela = false,
      this.funcaoAtt});
}

typedef Funcao = void Function(DataFunction);
typedef FuncaoAtt = Future<bool> Function({dynamic data, BuildContext context});

class ItemSelectExpanded = _ItemSelectExpandedBase with _$ItemSelectExpanded;

class DataFunction {
  dynamic data;
  int index;
  BuildContext context;
  DataFunction({this.data, this.index, this.context});
}

abstract class _ItemSelectExpandedBase extends ItemSelect with Store {
  @observable
  ObservableList<ItemSelectExpanded> items = ObservableList();
  @observable
  bool isExpanded = false;

  _ItemSelectExpandedBase({this.items, this.isExpanded = false});
}

enum TypeSearch { CONTAINS, BEGINSWITH, ENDSWITH, NOTCONTAINS }

abstract class FilterExp {}

class FilterExpCollun extends FilterExp {
  Linha line;
  dynamic value;
  TypeSearch typeSearch;
  FilterExpCollun(
      {this.line, this.value, this.typeSearch = TypeSearch.CONTAINS});
}

class FilterExpRangeCollun extends FilterExp {
  Linha line;
  DateTime dateStart;
  DateTime dateEnd;
  FilterExpRangeCollun({this.line, this.dateStart, this.dateEnd});
}

class GroupFilterExp extends FilterExp {
  OperatorFilterEx operatorEx;
  List<FilterExp> filterExps;
  GroupFilterExp({
    this.operatorEx,
    this.filterExps,
  });
}

enum OperatorFilterEx { AND, OR }

enum EnumTypeSort { ASC, DESC }

class ItemSort {
  EnumTypeSort typeSort;
  Linha linha;
  int indexLine;
  ItemSort({this.typeSort, this.linha, this.indexLine});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemSort &&
        other.typeSort == typeSort &&
        other.linha == linha;
  }

  @override
  int get hashCode => typeSort.hashCode ^ linha.hashCode;
}
