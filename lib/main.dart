import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

void main() {
  runApp(const MilkApp());
}

class MilkApp extends StatelessWidget {
  const MilkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Milk Company',
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32), // change later
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFFFC107), // accent color
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
        ),
      ),
      home: const LoginPage(),
      routes: {'/register': (context) => const RegisterPage()},
    );
  }
}
