import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants.dart';
import 'services/audio_service.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';

class Ag7App extends StatefulWidget {
  const Ag7App({super.key});

  @override
  State<Ag7App> createState() => _Ag7AppState();
}

class _Ag7AppState extends State<Ag7App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        NotificationService.remindersEnabled) {
      unawaited(NotificationService.scheduleDailyReminder());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        surface: AppColors.bgTop,
      ),
      scaffoldBackgroundColor: AppColors.bgBottom,
    );
    return MaterialApp(
      title: 'AG7 Mind Clash',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: GoogleFonts.fredokaTextTheme(base.textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bgTop,
          foregroundColor: AppColors.navy,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.navy,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      navigatorObservers: [audioRouteObserver],
      home: const SplashScreen(),
    );
  }
}
