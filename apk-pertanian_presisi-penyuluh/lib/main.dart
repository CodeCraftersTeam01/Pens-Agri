import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/colors.dart';
import 'views/home/commodity_selection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Protect against GoogleFonts network failure on cold boot
  GoogleFonts.config.allowRuntimeFetching = true;

  // Flutter error boundary to prevent UI thread crashes
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  runZonedGuarded(() {
    runApp(const AgriPrecisionApp());
  }, (error, stack) {
    debugPrint('Uncaught Zone Error: $error\n$stack');
  });
}

class AgriPrecisionApp extends StatelessWidget {
  const AgriPrecisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriSensor PENS - Presisi Tanah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.light().textTheme,
        ).apply(
          bodyColor: AppColors.onSurface,
          displayColor: AppColors.onSurface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
      ),
      home: const CommoditySelectionPage(),
    );
  }
}