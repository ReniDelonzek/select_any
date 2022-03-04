import 'package:select_any/select_any.dart';

enum TypeSearch { CONTAINS, BEGINSWITH, ENDSWITH, NOTCONTAINS }

enum OperatorFilterEx { AND, OR }

enum EnumTypeSort { ASC, DESC }

extension ExEnumTypeSort on EnumTypeSort {
  String toStringEnum() {
    if (this == EnumTypeSort.ASC) {
      return 'asc';
    } else {
      return 'desc';
    }
  }
}

class FilterExpColumn extends FilterExp {
  dynamic value;
  TypeSearch typeSearch;
  FilterExpColumn(
      {required Line line, this.value, this.typeSearch = TypeSearch.CONTAINS})
      : super(line: line);
}

class FilterExpRangeCollun extends FilterExp {
  DateTime? dateStart;
  DateTime? dateEnd;
  FilterExpRangeCollun({required Line line, this.dateStart, this.dateEnd})
      : super(line: line);
}

class GroupFilterExp extends FilterExp {
  OperatorFilterEx operatorEx;
  List<FilterExp> filterExps;
  GroupFilterExp({
    required this.operatorEx,
    this.filterExps = const [],
  });
}

class FilterSelectColumn extends FilterExp {
  dynamic value;
  TypeSearch typeSearch;
  String? customKey;
  dynamic valueId;
  FilterSelectColumn(
      {required Line line,
      this.value,
      this.typeSearch = TypeSearch.CONTAINS,
      this.customKey,
      this.valueId})
      : super(line: line);
}

class ItemSort {
  EnumTypeSort? typeSort;
  Line? line;
  int? indexLine;
  ItemSort({this.typeSort, this.line, this.indexLine});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemSort &&
        other.typeSort == typeSort &&
        other.line == line;
  }

  @override
  int get hashCode => typeSort.hashCode ^ line.hashCode;
}
