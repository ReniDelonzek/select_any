import 'package:select_any/select_any.dart';

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
