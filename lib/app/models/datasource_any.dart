import 'package:select_any/app/utils/utils_file.dart';
import 'package:select_any/select_any.dart';
import 'package:diacritic/diacritic.dart';
import 'package:msk_utils/extensions/date.dart';

abstract class DataSourceAny extends DataSource {
  List<Map<String, dynamic>> listAll;

  DataSourceAny({String id, bool allowExport = true})
      : super(id: id, allowExport: allowExport);

  @override
  Future<Stream<ResponseData>> getList(
      int limit, int offset, SelectModel selectModel,
      {Map data, bool refresh = false}) async {
    if (listAll == null || listAll.isEmpty || refresh == true) {
      await fetchData(limit, offset, selectModel, data: data);
    }
    List<Map<String, dynamic>> subList = [];
    if (offset == -1) {
      subList = listAll;
    } else if (limit > 0 && limit + offset < listAll.length) {
      subList = listAll.sublist(offset, limit + offset);
    } else {
      subList = listAll.sublist(offset);
    }

    return Stream.value(ResponseData(
        total: listAll.length,
        data: generateList(subList, offset, selectModel),
        start: offset,
        end: offset + limit));
  }

  @override
  Future<Stream<ResponseData>> getListSearch(
      String text, int limit, int offset, SelectModel selectModel,
      {Map data, bool refresh = false}) async {
    if (listAll == null || listAll.isEmpty || refresh == true) {
      await fetchData(limit, offset, selectModel, data: data);
    }
    List<Map<String, dynamic>> tempList = [];
    for (int i = 0; i < listAll.length; i++) {
      for (var value in listAll[i].values) {
        if (value != null) {
          if (removeDiacritics(value.toString())
                  .toLowerCase()
                  ?.contains(text) ==
              true) {
            tempList.add(listAll[i]);
            break;
          }
        }
      }
    }

    List<Map<String, dynamic>> subList = [];
    if (offset == -1) {
      subList = listAll;
    } else if (limit > 0 && limit + offset < tempList.length) {
      subList = tempList.sublist(offset, limit + offset);
    } else if (offset < tempList.length) {
      subList = tempList.sublist(offset);
    } else {
      subList = tempList;
    }
    return Stream.value(ResponseData(
        total: tempList.length,
        data: generateList(subList, offset, selectModel),
        start: offset,
        end: offset + limit,
        filter: text));
  }

  Future exportData(SelectModel selectModel) async {
    StringBuffer stringBuffer = StringBuffer();
    if (listAll.isNotEmpty) {
      for (var key in listAll.first.keys) {
        stringBuffer..write(key)..write(';');
      }
      stringBuffer.write('\n');
    }
    for (var item in listAll) {
      for (var value in item.values) {
        stringBuffer..write(value)..write(';');
      }
      stringBuffer.write('\n');
    }
    UtilsFile.saveFileString(stringBuffer.toString(),
        dirComplementar: '${selectModel.titulo}',
        fileName: '${DateTime.now().string('dd-MM-yyyy HH-mm-ss')}.csv');
    return;
  }

  Future fetchData(int limit, int offset, SelectModel selectModel, {Map data});

  @override
  Future clear() async {
    listAll = null;
    return;
  }
}
