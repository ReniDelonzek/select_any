import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/src/data/repository/font_data_filter_any.dart';
import 'package:select_any/src/data/repository/repository.dart';
import 'package:select_any/src/domain/domain.dart';

void main() {
  test('Test FontDataFilterAny', () async {
    FontDataFilterBase fontDataFilter =
        FontDataFilterAny((_, text) async => [ItemDataFilter(value: 'value')]);
    expectLater(
        (await fontDataFilter.getList(
                GroupFilterExp(operatorEx: OperatorFilterEx.AND), 'textSearch'))
            .length,
        1);
  });
}
