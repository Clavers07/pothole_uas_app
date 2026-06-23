import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  runApp(JalanBerlubangApp(
    isLoggedIn: token != null,
  ));
}

class JalanBerlubangApp extends StatelessWidget {
  const JalanBerlubangApp({
    super.key,
    required this.isLoggedIn,
  });

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pelaporan Jalan Berlubang',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
      ),

      initialRoute: isLoggedIn ? '/dashboard' : '/',

      routes: {
        '/': (context) => const LoginPage(),
        '/dashboard': (context) => DashboardPage(),
      },
    );
  }
}