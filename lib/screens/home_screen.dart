import 'package:downlaod_service/constants/Constants.dart';
import 'package:downlaod_service/screens/download_list_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

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
          child: Image(image: AssetImage('images/vidmate_icon_windows.png'))),
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
