import 'package:flutter_downloader/flutter_downloader.dart';

class Task {
  String? fileName;
  String? taskId;
  DownloadTaskStatus? status;
  int? progress;
  String? savedDir;
  Task({this.fileName, this.taskId, this.status, this.progress, this.savedDir});
}
