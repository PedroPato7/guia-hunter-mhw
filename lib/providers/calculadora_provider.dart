import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Gerenciador de estado global para a Wishlist (Calculadora de Forja)
class CalculadoraProvider extends ChangeNotifier {
  List<int> _itensDesejados = [];
  
  // Instância do banco de dados local NoSQL
  final Box _box = Hive.box('cacadorBox');

  List<int> get itensDesejados => _itensDesejados;

  // Carrega os dados persistidos no armazenamento local (Hive)
  void carregarDadosSalvos() {
    final dadosSalvos = _box.get('lista_desejos', defaultValue: <int>[]);
    _itensDesejados = List<int>.from(dadosSalvos);
    notifyListeners(); 
  }

  // Adiciona um novo item (ID da armadura) e persiste a mudança
  void adicionarItem(int idArmadura) {
    if (!_itensDesejados.contains(idArmadura)) {
      _itensDesejados.add(idArmadura);
      _salvarNoBanco();
    }
  }

  // Remove um item e persiste a mudança
  void removerItem(int idArmadura) {
    _itensDesejados.remove(idArmadura);
    _salvarNoBanco();
  }

  // Persiste a lista atualizada no banco NoSQL
  void _salvarNoBanco() {
    _box.put('lista_desejos', _itensDesejados);
    notifyListeners(); 
  }
}