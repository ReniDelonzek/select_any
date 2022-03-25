import 'package:select_any/select_any.dart';

class ResponseDataDataSource {
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
  ResponseDataDataSource(
      {this.exception,
      required this.data,
      this.total,
      this.filter,
      required this.start,
      required this.end});
}
