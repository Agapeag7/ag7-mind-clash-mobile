import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants.dart';
import 'screens/splash_screen.dart';

class Ag7App extends StatelessWidget {
  const Ag7App({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.red),
      scaffoldBackgroundColor: AppColors.bgBottom,
    );
    return MaterialApp(
      title: 'AG7 Mind Clash',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: GoogleFonts.fredokaTextTheme(base.textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}