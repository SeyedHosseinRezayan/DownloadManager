import 'dart:io';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';

///        Open any file tools               ///

FileSystemEntity? getFileFromDirectory({required String savedDir}) {
  List<FileSystemEntity> directories =
      Directory(savedDir).listSync(followLinks: true);
  return directories.isNotEmpty ? directories.first : null;
}

void onFileTap(
    {required FileSystemEntity? file, required DownloadTaskStatus status}) {
  if (status == DownloadTaskStatus.complete && file != null) {
    OpenFile.open(file.path, type: getFileType(path: file.path));
  }
}

String? getFileType({required String path}) {
  const types = {
    ".pdf": "application/pdf",
    ".dwg": "application/x-autocad",
    ".mp4": "video/mp4",
    ".mov": "video/quicktime",
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png",
    ".gif": "image/gif",
    ".bmp": "image/bmp",
    ".webp": "image/webp",
  };

  String extention = path.split('.').last.toLowerCase();
  return types[extention];
}
