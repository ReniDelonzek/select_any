import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/msk_utils.dart';
import 'package:select_any/select_any.dart';

void main() {
  test('Test SelectFKController', () {
    SelectFKController fkController = SelectFKController();
    fkController.obj = {};
    fkController.clear();
    expect(fkController.obj, isNull);
  });

  test('Test SelectFKController checkSingleRow', () async {
    SelectFKController ctlSelect = SelectFKController();
    ctlSelect.selectModel = SelectModel(
        '',
        'id',
        [Line('key')],
        FontDataAny((_) async => [
              {'key': 'key0', 'id': 0}
            ]),
        TypeSelect.ACTION);
    await ctlSelect.checkSingleRow();
    expect(ctlSelect.obj, isNotNull);

    SelectFKController ctlSelect2 = SelectFKController();
    ctlSelect2.selectModel = SelectModel(
        '',
        'id',
        [Line('key')],
        FontDataAny((_) async => [
              {'key': 'key0', 'id': 0},
              {'key': 'key1', 'id': 1}
            ]),
        TypeSelect.ACTION);
    await ctlSelect2.checkSingleRow();
    expect(ctlSelect2.obj, isNull);
  });

  test('Test setObjList', () {
    SelectFKController ctlSelect = SelectFKController();
    ctlSelect.list = ObservableList<ItemSelect>.of([
      ItemSelect(id: 1, object: {'id': 1}),
      ItemSelect(id: 2, object: {'id': 2})
    ]);
    ctlSelect.setObjList({'id': 10}, 'id');
    expect(ctlSelect.obj, isNull);
    ctlSelect.setObjList({'id': 1}, 'id');
    expect(ctlSelect.obj, isNotNull);
  });
}
