import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:guia_mhw_app/screens/splash_screen.dart';
import 'package:guia_mhw_app/providers/calculadora_provider.dart'; 

void main() async {
  // Garante a inicialização dos bindings do Flutter antes de operações assíncronas
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização do banco de dados local NoSQL (Hive)
  await Hive.initFlutter();
  await Hive.openBox('cacadorBox'); 

  // Injeção do Provider na raiz da árvore de widgets para gerência de estado global
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CalculadoraProvider()..carregarDadosSalvos(),
        ),
      ],
      child: const GuiaCacadorApp(),
    ),
  );
}

// Configuração raiz e definição do tema do aplicativo
class GuiaCacadorApp extends StatelessWidget {
  const GuiaCacadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guia do Caçador - MHW',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.brown, // Paleta de cores rústica global
      ),
      home: const SplashScreen(),
    );
  }
}