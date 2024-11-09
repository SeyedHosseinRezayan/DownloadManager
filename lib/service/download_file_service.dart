import 'package:downlaod_service/model/task.dart';
import 'package:downlaod_service/permission/directory_path.dart';
import 'package:downlaod_service/permission/storage_permission.dart';
import 'package:downlaod_service/providers/download_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadFileService {
  Future<void> initialize() async {
    await FlutterDownloader.initialize(); // Initialize the downloader
  }

// start downloading event
  Future<void> startDownload(
      String url, String filename, DownloadProvider provider) async {
    var isPermissionStorage = await PermissionStorage.getPermissionStorage();
    if (isPermissionStorage) {
      DirectoryPath directoryPath = DirectoryPath();
      var savedDir = await directoryPath.getDirPath(filename: filename);
      savedDir.create(recursive: true).then((onValue) async {
        var taskId = await FlutterDownloader.enqueue(
            fileName: filename,
            url: url,
            savedDir: savedDir.path,
            showNotification: true,
            openFileFromNotification: false);
        provider.addTask(SimpleTask(
          fileName: filename,
          taskId: taskId,
          status: DownloadTaskStatus.running,
          progress: 0,
          savedDir: savedDir.path,
        ));
      });
    } else {
      print('NO Permission Storage !');
    }
  }
}
