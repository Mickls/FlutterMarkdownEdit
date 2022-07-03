
import 'dart:io';

import 'package:path_provider/path_provider.dart';

String? _content;
String? rootDirPath;

// Find the Documents path
Future getDirPath() async {
  if (rootDirPath == "") {
    final _dir = await getApplicationDocumentsDirectory();
    rootDirPath = _dir.path;
  }
  return rootDirPath;
}

Future<List<String>> getFilesList(String dirPath) async {
  rootDirPath = await getDirPath();
  String _dirPath = "$rootDirPath/$dirPath";
  Stream _filesList = Directory(_dirPath).list();
  List<String> filesList = [];
  await for (FileSystemEntity fileSystemEntity in _filesList) {
    print(fileSystemEntity.path.split('/'));
    print(fileSystemEntity.path.split('/').last);
    filesList.add(fileSystemEntity.toString());
  }
  return filesList;
}
