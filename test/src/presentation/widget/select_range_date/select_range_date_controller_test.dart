import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/src/presentation/widgets/select_range_date/select_range_date_controller.dart';

void main() {
  test('Test select_range_date_controller', () {
    SelectRangeDateController controller = SelectRangeDateController();
    DateTime dateTime = DateTime(2020, 1, 1);
    controller.initialDate = dateTime;
    controller.finalDate = dateTime.add(Duration(days: 1));
    controller.clear();

    expect(controller.initialDate, isNull);
    expect(controller.finalDate, isNull);
  });
}
