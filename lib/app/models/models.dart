import 'package:flutter/cupertino.dart';
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
  List<Filtro> filtros;

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
      this.permitirSelecionarTodos}) {
    if (abrirPesquisaAutomaticamente == null) {
      abrirPesquisaAutomaticamente = !UtilsPlatform.isMobile();
    }
  }
}

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
  FormatacaoDados formatacaoDados;

  Linha(this.chave,
      {this.color,
      this.involucro,
      this.personalizacao,
      this.valorPadrao,
      @required this.nome,
      this.chavesLista,
      this.estiloTexto,
      this.formatacaoDados});
}

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

abstract class FormatacaoDados {
  String valorPadrao;
  FormatacaoDados({this.valorPadrao});
  String dadosFormatados(String dados);
}

class FormatacaoDadosDate extends FormatacaoDados {
  String formatoEntrada;
  String formatoSaida;

  @override
  String dadosFormatados(String dataOriginal) {
    try {
      String data;
      if (dataOriginal is String) {
        data = dataOriginal;
      } else {
        data = dataOriginal?.toString();
      }
      return data.toDate(formatoEntrada).string(formatoSaida);
    } catch (error, _) {
      // UtilsSentry.reportError(error, stackTrace);
    }
    return valorPadrao;
  }
}

class FormatacaoDadosTimestamp extends FormatacaoDados {
  String formatoSaida;

  FormatacaoDadosTimestamp(this.formatoSaida);

  @override
  String dadosFormatados(String dados) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(dados.toInt())
          .string(formatoSaida);
    } catch (error, _) {
      // UtilsSentry.reportError(error, stackTrace);
    }
    return valorPadrao;
  }
}

class Filtro {
  String id;
  String label;
  TextInputType inputType;
  TextCapitalization textCapitalization;

  Filtro(this.id, this.label, this.inputType, this.textCapitalization);
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

  @observable
  ObservableList<ItemSelect> listData = ObservableList();

  _DataSourceBase({this.id, this.searchDelay = 300, this.allowExport = false});

  Future<Stream<ResponseData>> getList(
      int limit, int offset, SelectModel selectModel,
      {Map data, bool refresh = false});

  Future<Stream<ResponseData>> getListSearch(
      String text, int limit, int offset, SelectModel selectModel,
      {Map data, bool refresh});

  List<ItemSelectTable> generateList(
      List data, int offset, SelectModel selectModel) {
    ObservableList<ItemSelectTable> lista = ObservableList();
    for (Map a in data) {
      bool preSelecionado = selectModel.itensSelecionados != null &&
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
        /// TODO revisar
        itemSelect.id = a[selectModel.id];
        itemSelect.isSelected = preSelecionado;
        itemSelect.object = a;
        itemSelect.position = offset++;
        lista.add(itemSelect);
      }
    }
    return lista;
  }

  Future exportData(SelectModel selectModel);
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
