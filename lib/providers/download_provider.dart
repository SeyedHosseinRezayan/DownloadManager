import 'dart:io';

import 'package:downlaod_service/model/task.dart';
import 'package:downlaod_service/service/download_file_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';

class DownloadProvider with ChangeNotifier {
  DownloadFileService downloadservice = DownloadFileService();
  //set urls
  final List<String> _urls = [
    'https://dl4.3rver.org/Trailer/2024/07/Deadpool.2016.Trailer.mp4',
    'https://sample-videos.com/audio/mp3/crowd-cheering.mp3',
    'https://sample-videos.com/img/Sample-png-image-30mb.png',
  ];
  // get urls
  List<String> get urls {
    return _urls;
  }

// set tasks downloading
  final List<Task> _tasks = [];
// get tasks
  List<Task> get tasks {
    return _tasks;
  }

// add task to tasks List  when click downlaod
  void addTask(Task task) {
    tasks.add(task);
    notifyListeners();
  }

  // not work yet
  // void updateProgress(String? id, int progress) {
  //   var task = _tasks.firstWhere((task) => task.taskId == id);
  //   task.progress = progress;
  //   notifyListeners();
  // }

// load all task method
  Future<void> loadTasks(DownloadProvider provider) async {
    final tasks = await FlutterDownloader.loadTasks();
    provider.clearTasks();

// listen and init every task   Status / progress / savedDir
    tasks!.forEach((task) {
      provider.addTask(Task(
        fileName: task.filename,
        taskId: task.taskId,
        status: task.status,
        progress: task.progress,
        savedDir: task.savedDir,
      ));
    });
    notifyListeners();
  }

// clear for another task
  void clearTasks() {
    _tasks.clear();
    notifyListeners();
  }
}
