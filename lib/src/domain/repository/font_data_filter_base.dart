import 'package:select_any/select_any.dart';

abstract class FontDataFilterBase {
  Future<List<ItemDataFilter>> getList(
      GroupFilterExp? filters, String textSearch);
}
