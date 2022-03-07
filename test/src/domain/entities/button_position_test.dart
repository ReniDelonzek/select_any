import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/src/domain/domain.dart';

void main() {
  test('Test getDefaultButtonPosition', () {
    expect(getDefaultButtonPosition(1), ButtonPosition.BOTTOM);
  });
}
