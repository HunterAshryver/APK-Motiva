import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const RoboApp());
}

class RoboApp extends StatelessWidget {
  const RoboApp({super.key});

  @override
  Widget build(BuildContext context) {
    const anilMotiva = Color(0xFF5D00FF);

    return MaterialApp(
      title: 'Motiva Robô',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: anilMotiva,
        scaffoldBackgroundColor: const Color(0xFF0A0F1C),
        cardColor: const Color(0xFF121A2A),

        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0A0F1C),
          elevation: 4,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: anilMotiva,
          ),
        ),

        // Correção aqui:
        tabBarTheme: const TabBarThemeData(
          labelColor: anilMotiva,
          unselectedLabelColor: Colors.grey,
          indicatorColor: anilMotiva,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
