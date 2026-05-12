import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:scoreboards/services/notification_service.dart';
import 'package:scoreboards/services/background_service.dart';
import 'package:scoreboards/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  await LocalNotificationService.initialize();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String lastMessage = "No messages yet";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
      if (isMobile) {
        await initializeBackgroundService();
      }
    });

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      FlutterBackgroundService().on("notification").listen((event) {
        if (event != null) {
          setState(() {
            lastMessage = event["payload"].toString();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Scoreboards',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Inter',
      ),
      routerConfig: router,
    );
  }
}
