import 'package:flutter/material.dart';
import 'lista_criaturas_screen.dart';

// Tela de carregamento inicial (Splash Screen) com branding do app
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

  // Aguarda 5 segundos antes de redirecionar para a tela principal
  Future<void> _navegarParaProximaTela() async {
    await Future.delayed(const Duration(seconds: 5));
    
    // Evita vazamento de memória caso o widget seja destruído antes do tempo
    if (!mounted) return;

    // Substitui a Splash Screen na pilha de navegação para que o usuário não possa voltar para ela
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