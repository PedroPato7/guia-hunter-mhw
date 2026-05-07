import 'package:flutter/material.dart';
import 'package:guia_mhw_app/screens/splash_screen.dart';

void main() {
  runApp(const GuiaCacadorApp());
}

class GuiaCacadorApp extends StatelessWidget {
  const GuiaCacadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guia do Caçador - MHW',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.brown,
      ),
      home: const SplashScreen(),
    );
  }
}