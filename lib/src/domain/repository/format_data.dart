import 'package:select_any/src/domain/entities/object_format_data.dart';

abstract class FormatData {
  String defaultValue;
  FormatData({this.defaultValue = ''});
  String formatData(ObjFormatData obj);
}
