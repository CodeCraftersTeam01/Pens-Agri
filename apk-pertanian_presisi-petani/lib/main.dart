import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/colors.dart';
import 'views/dashboard/soil_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow runtime fetching with offline fallback handling
  GoogleFonts.config.allowRuntimeFetching = true;

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  runZonedGuarded(() {
    runApp(const AgriPrecisionPetaniApp());
  }, (error, stack) {
    debugPrint('Uncaught Zone Error: $error\n$stack');
  });
}

class AgriPrecisionPetaniApp extends StatelessWidget {
  const AgriPrecisionPetaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriSensor PENS - Petani',
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
      home: const SoilDashboardPage(),
    );
  }
}