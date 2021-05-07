import 'dart:io';

import 'package:msk_utils/utils/utils_platform.dart';
import 'dart:io' as io;

import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

class UtilsFile {
  static saveFileString(String s,
      {String fileName,
      String extensionFile,
      String dirComplementar,
      String contentExport}) async {
    String directory;
    String separator = "/";
    if (UtilsPlatform.isWindows()) {
      separator = "\\";
    }
    if (UtilsPlatform.isDesktop()) {
      directory = '${io.Directory.current.path}${separator}Files';
    } else {
      if (UtilsPlatform.isIOS()) {
        directory = (await getTemporaryDirectory()).absolute.path;
      } else {
        directory = (await getExternalStorageDirectory()).absolute.path;
      }
    }
    if (dirComplementar != null) {
      directory += '$separator$dirComplementar';
    }
    io.File file =
        io.File('$directory$separator${DateTime.now().millisecondsSinceEpoch}');
    io.Directory dir = io.Directory('$directory');
    if ((await dir.exists()) == false) {
      dir = await dir.create(recursive: true);
    }
    if (fileName == null) {
      fileName =
          '${DateTime.now().millisecondsSinceEpoch}${extensionFile != null ? extensionFile : ''}';
    }
    file = io.File('${dir.path}$separator$fileName');
    if ((await file.exists()) == false) {
      file = await file.create(recursive: true);
    }
    await file.writeAsString(s);
    await openFileOrDirectory(file.path, dir.path,
        contentExport: contentExport);
  }

  static Future<File> saveFileBytes(List<int> bytes,
      {String fileName,
      String extensionFile,
      String dirExtra,
      String contentExport,
      bool openExplorer = true}) async {
    String directory;
    String separator = "/";
    if (UtilsPlatform.isWindows()) {
      separator = "\\";
    }
    if (UtilsPlatform.isDesktop()) {
      directory = '${io.Directory.current.path}${separator}Files';
    } else {
      if (UtilsPlatform.isIOS()) {
        directory = (await getTemporaryDirectory()).absolute.path;
      } else {
        directory = (await getExternalStorageDirectory()).absolute.path;
      }
    }
    if (dirExtra != null) {
      directory += '$separator$dirExtra';
    }
    io.File file =
        io.File('$directory$separator${DateTime.now().millisecondsSinceEpoch}');
    io.Directory dir = io.Directory('$directory');
    if ((await dir.exists()) == false) {
      dir = await dir.create(recursive: true);
    }
    if (fileName == null) {
      fileName =
          '${DateTime.now().millisecondsSinceEpoch}${extensionFile != null ? extensionFile : ''}';
    }
    file = io.File('${dir.path}$separator$fileName');
    if ((await file.exists()) == false) {
      file = await file.create(recursive: true);
    }
    // ignore: close_sinks
    var open = file.openWrite();
    open.add(bytes);
    await open.flush();
    if (openExplorer) {
      await openFileOrDirectory(file.path, dir.path,
          contentExport: contentExport);
    }
    return file;
  }

  static openFileOrDirectory(String filePath, String directoryPath,
      {String contentExport}) async {
    if (UtilsPlatform.isWeb()) {
      return;
    }
    if (UtilsPlatform.isWindows()) {
      await UtilsPlatform.openProcess('explorer.exe', args: ['$directoryPath']);
    } else if (Platform.isMacOS) {
      await UtilsPlatform.openProcess('open', args: ['$directoryPath']);
    } else if (UtilsPlatform.isMobile()) {
      ShareExtend.share(filePath, "file",
          sharePanelTitle: 'Selecione por onde deseja enviar seu arquivo',
          subject: contentExport ?? 'Segue em anexo seu relatório');
    }
  }
}
