import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() {
  // Deixa a barra de status transparente/escura para um visual moderno
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SocialJoin',
      theme: ThemeData(
        primaryColor: const Color(0xFFEA3F74),
        scaffoldBackgroundColor: const Color(0xFFF2F4F7), // Fundo cinza bem claro estilo "site"
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEA3F74),
          primary: const Color(0xFFEA3F74),
          secondary: const Color(0xFFFFABC5),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}