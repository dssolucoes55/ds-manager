import 'package:flutter/material.dart';
import 'screens/login/login_page.dart';

void main() {
  runApp(const DSSolucoesApp());
}

class DSSolucoesApp extends StatelessWidget {
  const DSSolucoesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}