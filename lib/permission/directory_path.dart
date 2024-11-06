import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DirectoryPath {
  Future<Directory> getDirPath({required String? filename}) async {
    Directory? _dir = await getApplicationSupportDirectory();
    String _localPath = _dir!.path + filename!;
    Directory _savedDir = Directory(_localPath);
    return _savedDir;
  }
}
