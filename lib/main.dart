import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoreboards/constants/app_colors.dart';
import 'package:scoreboards/services/notification_service.dart';
import 'package:scoreboards/services/background_service.dart';
import 'package:scoreboards/services/favorites_service.dart';
import 'package:scoreboards/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Temporarily off while we get the base app (nav, screens, favorites)
/// solid — the real-time notification background service has been the
/// source of a hard-to-diagnose startup crash, and it isn't wired to
/// anything user-facing yet anyway. Flip this back to true once the base
/// app is confirmed working and the staging websocket host is reachable.
const bool kEnableBackgroundNotificationService = false;

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  await LocalNotificationService.initialize();
  await FavoritesService.instance.init();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String lastMessage = "No messages yet";

  @override
  void initState() {
    super.initState();

    if (kEnableBackgroundNotificationService) {
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Scoreboards',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        canvasColor: AppColors.bg,
        primaryColor: AppColors.coral,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.coral,
          brightness: Brightness.dark,
          primary: AppColors.coral,
          secondary: AppColors.mint,
          surface: AppColors.surface,
        ),
        // Hanken Grotesk is the default body/UI font across the app.
        // Space Grotesk (headings) and Archivo (score numerals) are applied
        // per-widget via GoogleFonts.spaceGrotesk()/archivo() where needed.
        //
        // Deliberately NOT using GoogleFonts.hankenGroteskTextTheme() here:
        // that generates and fetches ~13 distinct text-style/weight variants
        // for the whole app theme synchronously on the very first frame,
        // which is the main contributor to the "skipped frames" cold-start
        // jank. Setting just `fontFamily` lets each weight resolve lazily,
        // spread across the frames as individual screens actually render.
        textTheme: ThemeData(brightness: Brightness.dark).textTheme.apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
              fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
            ),
        fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
      ),
      routerConfig: router,
    );
  }
}
