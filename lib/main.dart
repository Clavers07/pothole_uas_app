import 'package:flutter/material.dart';
import 'login_page.dart';
import 'dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pothole Report',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // ═══ Ionic-Like Theme (Vanilla Flutter) ═══
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3880FF),
          primary: const Color(0xFF3880FF),
          secondary: const Color(0xFF3DC2FF),
          error: const Color(0xFFEB445A),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F0F0),

        // AppBar Ionic-like toolbar
        appBarTheme: const AppBarTheme(
          elevation: 0.5,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF222428),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222428),
            letterSpacing: 0.15,
          ),
        ),

        // ElevatedButton Ionic-like flat styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3880FF),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // TextFormField/Input Ionic-like styling
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFF3880FF), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFFEB445A), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFFEB445A), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF92949C)),
        ),

        // Card Ionic-like styling
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
        ),

        // FAB Ionic-like styling
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF3880FF),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),

        // SnackBar/Toast Ionic-like styling
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF222428),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const LoginPage(),
      routes: {
        '/dashboard': (context) => DashboardPage(),
      },
    );
  }
}
