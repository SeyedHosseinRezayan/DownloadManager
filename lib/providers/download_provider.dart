import 'dart:isolate';
import 'dart:ui';

import 'package:downlaod_service/model/task.dart';
import 'package:downlaod_service/service/download_file_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadProvider with ChangeNotifier {
  //add urls
  List<String> _urls = [
    'https://dl4.3rver.org/Trailer/2024/07/Deadpool.2016.Trailer.mp4',
    'https://sample-videos.com/audio/mp3/crowd-cheering.mp3',
    'https://sample-videos.com/img/Sample-png-image-30mb.png',
  ];

  void addUrl(String url) {
    if (url.isEmpty) {
      print('Url Not Exist. try again !');
    } else if (url.contains('http')) {
      _urls.add(url);
      notifyListeners();
    }
  }

  deleteUrl(String url) {
    _urls.remove(url);
    notifyListeners();
  }

  // get urls
  List<String> get urls {
    return _urls;
  }

// init tasks downloading
  List<SimpleTask> _tasks = [];
// get tasks
  List<SimpleTask> get tasks {
    return _tasks;
  }

// set tasks
  set tasks(List<SimpleTask> task) {
    _tasks = task;
  }

// add task to tasks List  when click downlaod
  void addTask(SimpleTask task) {
    tasks.add(task);
    notifyListeners();
  }

// bind isolate / register port / listen
  bindBackgroundIsolate() {
    final ReceivePort receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(
        receivePort.sendPort, 'downloader_send_port');
    receivePort.asBroadcastStream();

    receivePort.listen((message) {
      String taskId = message[0];
      int status = message[1];
      int progress = message[2];

      var getTasks = tasks.where((task) => task.taskId == taskId);
      for (var element in getTasks) {
        element.status = DownloadTaskStatus.fromInt(status);
        element.progress = progress;
        notifyListeners();
      }
    });
  }

// load all task method
  Future<void> loadTasks(DownloadProvider provider) async {
    final tasks = await FlutterDownloader.loadTasks();
    provider.clearTasks();

// listen and init every task   Status / progress / savedDir
    for (var task in tasks!) {
      provider.addTask(SimpleTask(
        fileName: task.filename,
        taskId: task.taskId,
        status: task.status,
        progress: task.progress,
        savedDir: task.savedDir,
      ));
    }
    notifyListeners();
  }

// clear for another task
  void clearTasks() {
    _tasks.clear();
    notifyListeners();
  }
}
