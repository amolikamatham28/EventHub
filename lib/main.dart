
import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() {
  runApp(const EventHubApp());
}

class EventHubApp extends StatelessWidget {
  const EventHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventHub',
      debugShowCheckedModeBanner: false,

      // Application-wide theme
      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF202B45),
          primary: const Color(0xFF202B45),
          secondary: const Color(0xFFF07861),
          surface: const Color(0xFFFAF8F4),
        ),

        scaffoldBackgroundColor: const Color(0xFFFAF8F4),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF8F4),
          foregroundColor: Color(0xFF202B45),
          elevation: 0,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF07861),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),
      ),

      home: const HomeScreen(),
    );
  }
}
