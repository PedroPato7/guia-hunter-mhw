import 'package:flutter/material.dart';
import 'lista_criaturas_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navegarParaProximaTela();
  }

  Future<void> _navegarParaProximaTela() async {
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Tela1Criaturas()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/logoMhw.gif',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}