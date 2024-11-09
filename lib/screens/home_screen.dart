import 'dart:isolate';
import 'dart:ui';

import 'package:downlaod_service/constants/Constants.dart';
import 'package:downlaod_service/providers/download_provider.dart';
import 'package:downlaod_service/screens/download_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // call back functino
  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  void initState() {
    context.read<DownloadProvider>().bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.red,
        title: const Text(
          'Download Manager',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
      backgroundColor: ColorConstants.white,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DownloadListScreen(),
              ),
            );
          },
          child: const Image(
              image: AssetImage('images/vidmate_icon_windows.png'))),
      body: const SafeArea(
        child: Center(
          child: Text(
            'Go for it !',
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
    );
  }
}
