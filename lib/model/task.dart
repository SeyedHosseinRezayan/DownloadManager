import 'package:downlaod_service/model/parent_task.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class SimpleTask extends ParentTask {
  String? fileName;
  String? taskId;
  DownloadTaskStatus? status;
  int? progress;
  String? savedDir;
  SimpleTask(
      {this.fileName, this.taskId, this.status, this.progress, this.savedDir});
}
