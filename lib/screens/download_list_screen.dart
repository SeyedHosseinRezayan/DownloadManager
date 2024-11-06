import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:downlaod_service/constants/Constants.dart';
import 'package:downlaod_service/main.dart';
import 'package:downlaod_service/model/task.dart';
import 'package:downlaod_service/providers/download_provider.dart';
import 'package:downlaod_service/screens/home_screen.dart';
import 'package:downlaod_service/service/download_file_service.dart';
import 'package:downlaod_service/utility/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as Path;

class DownloadListScreen extends StatefulWidget {
  const DownloadListScreen({super.key});

  @override
  State<DownloadListScreen> createState() => _DownloadListScreenState();
}

class _DownloadListScreenState extends State<DownloadListScreen> {
  final ReceivePort _receivePort = ReceivePort();
  DownloadFileService downloadService = DownloadFileService();

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

// bind backgrond isolate
  bindBackgroundIsolate() {
    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, 'downloader_send_port');
    _receivePort.listen((message) {
      String taskId = message[0];
      int status = message[1];
      int progress = message[2];

      var tasks = context
          .read<DownloadProvider>()
          .tasks
          .where((task) => task.taskId == taskId);
      tasks.forEach((element) {
        element.status = DownloadTaskStatus.fromInt(status);
        element.progress = progress;
      });

      print('#### Status : { ${status} }');
      print('#### Progress : { ${progress} }');
    });
  }

// un bind backgrond isolate remove port
  unBindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @override
  void initState() {
    super.initState();
    // load all downloading tasks
    context
        .read<DownloadProvider>()
        .loadTasks(context.read<DownloadProvider>());

    // bing background isolate
    bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    super.dispose();
    unBindBackgroundIsolate();
  }

  @override
  Widget build(BuildContext context) {
    var provider = context.read<DownloadProvider>();
    return Scaffold(
      backgroundColor: ColorConstants.pink,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: ColorConstants.red,
        title: const Text(
          'Download Manager',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.backspace_rounded,
          color: ColorConstants.red,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: filesListView(provider),
              ),
              Consumer<DownloadProvider>(
                builder: (context, newProvider, child) {
                  return Expanded(
                    flex: 1,
                    child: newProvider.tasks.isNotEmpty
                        ? downloadingfilesListView(newProvider)
                        : Container(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

// file ready for downlad list
  ListView filesListView(DownloadProvider provider) {
    return ListView.builder(
      itemCount: provider.urls.length,
      itemBuilder: (context, index) {
        String fileName = Path.basename(provider.urls[index]);
        return Card(
          color: ColorConstants.red,
          elevation: 6,
          child: ListTile(
            title: Text(
              fileName,
              style: TextStyle(color: ColorConstants.white),
            ),
            trailing: GestureDetector(
              onTap: () {
                downloadService.startDownload(
                    provider.urls[index], fileName, provider);
              },
              child: Icon(Icons.download, color: ColorConstants.white),
            ),
          ),
        );
      },
    );
  }

// files downlaoding list
  ListView downloadingfilesListView(DownloadProvider newProvider) {
    return ListView.builder(
      itemCount: newProvider.tasks.length,
      itemBuilder: (context, index) {
        // task
        var task = newProvider.tasks[index];

        FileSystemEntity? file = getFileFromDirectory(savedDir: task.savedDir!);

        return GestureDetector(
          onTap: () => onFileTap(file: file, status: task.status!),
          child: Card(
            elevation: 6,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                      '${newProvider.tasks[index].fileName ?? 'file ${index + 1}'}'),
                  trailing: buttons(task.taskId, task.status!, index),
                  subtitle: textDownloadStatus(task.status!),
                ),
                if (task.status != DownloadTaskStatus.complete)
                  getProgressIndicator(task.progress!)
              ],
            ),
          ),
        );
      },
    );
  }

  ////         Widgets        ////

  ///   progress
  Widget getProgressIndicator(int progress) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          Text('$progress %'),
          LinearProgressIndicator(
            value: (progress / 100),
          )
        ],
      ),
    );
  }

  ///  Text Download Status
  Widget textDownloadStatus(DownloadTaskStatus status) {
    String message = '';
    Color color;
    switch (status) {
      case DownloadTaskStatus.running:
        message = 'Downloading...';
        color = ColorConstants.white;
        break;
      case DownloadTaskStatus.failed:
        message = 'Download Failed !';
        color = ColorConstants.red;
        break;
      case DownloadTaskStatus.paused:
        message = 'Download Paused';
        color = ColorConstants.blue;
        break;
      case DownloadTaskStatus.complete:
        message = 'Download Complated !';
        color = ColorConstants.green;
        break;
      default:
        message = 'Waiting ...';
        color = ColorConstants.white;
        break;
    }
    return Text(
      message,
      style: TextStyle(color: color),
    );
  }

  ///  Buttons  Download Status
  Widget buttons(var taskId, DownloadTaskStatus status, int index) {
    void changedTaskId(String oldTaskId, String newTaskId) {
      setState(() {
        var _tasks = context.read<DownloadProvider>().tasks.where(
              (task) => task.taskId == oldTaskId,
            );
        _tasks.forEach((element) {
          element.taskId = newTaskId;
        });
      });
    }

// Delete task Button
    Widget _removeButton(var taskId) {
      return GestureDetector(
        child: const Icon(
          Icons.cancel,
          color: const Color.fromARGB(255, 180, 0, 30),
        ),
        onTap: () {
          setState(() {
            context.read<DownloadProvider>().tasks.removeAt(index);
            FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: true);
          });
        },
      );
    }

    // Retry again Button
    Widget retryButton(var taskId) {
      return Container(
        width: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              child: const Icon(Icons.repeat, color: ColorConstants.red),
              onTap: () {
                setState(() {
                  FlutterDownloader.retry(taskId: taskId).then(
                    (newTaskId) {
                      changedTaskId(taskId, newTaskId!);
                    },
                  );
                });
              },
            ),
            Spacer(),
            _removeButton(taskId)
          ],
        ),
      );
    }

    // Pause Button
    Widget pauseButton(var taskId) {
      return Container(
        width: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              child: const Icon(
                Icons.pause,
                color: ColorConstants.blue,
                size: 30,
              ),
              onTap: () {
                setState(() {
                  FlutterDownloader.pause(taskId: taskId);
                });
              },
            ),
            Spacer(),
            _removeButton(taskId)
          ],
        ),
      );
    }

// Resume Button
    Widget resumeButton(var taskId) {
      return Container(
        width: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              child: const Icon(
                Icons.play_arrow,
                color: ColorConstants.blue,
                size: 30,
              ),
              onTap: () {
                setState(() {
                  FlutterDownloader.resume(taskId: taskId).then((newTaskId) {
                    changedTaskId(taskId, newTaskId!);
                  });
                });
              },
            ),
            Spacer(),
            _removeButton(taskId)
          ],
        ),
      );
    }

    // All Buttons Status
    switch (status) {
      case DownloadTaskStatus.canceled:
        return _removeButton(taskId);
      case DownloadTaskStatus.failed:
        return retryButton(taskId);
      case DownloadTaskStatus.complete:
        return _removeButton(taskId);
      case DownloadTaskStatus.paused:
        return resumeButton(taskId);
      case DownloadTaskStatus.running:
        return pauseButton(taskId);

      default:
        return Container();
    }
  }
}
