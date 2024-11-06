import 'package:downlaod_service/providers/download_provider.dart';
import 'package:downlaod_service/screens/download_list_screen.dart';
import 'package:downlaod_service/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DownloadProvider())
      ],
      child: Consumer<DownloadProvider>(
        builder: (context, value, child) {
          return const MyApp();
        },
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
