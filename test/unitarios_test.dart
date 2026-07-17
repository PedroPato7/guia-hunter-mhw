import 'package:flutter_test/flutter_test.dart';
import 'package:guia_mhw_app/utils/constants.dart'; 

void main() {
  group('Testes Unitários: Regras de Negócio - Constantes', () {
    
    test('Valida integridade e tamanho exato da lista de monstros foco (MVP)', () {
      expect(monstrosFoco.isNotEmpty, true);
      expect(monstrosFoco.length, 18);
      expect(monstrosFoco.contains('Nergigante'), true);
    });

    test('Garante ausência de nomes duplicados na coleção de monstros', () {
      // A conversão para Set elimina duplicatas automaticamente
      final listaSemDuplicatas = monstrosFoco.toSet();
      
      // Valida se o tamanho sofreu alteração pós-conversão
      expect(monstrosFoco.length, equals(listaSemDuplicatas.length));
    });

  });
}