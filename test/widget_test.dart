import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guia_mhw_app/screens/detalhes_screen.dart'; 

void main() {
  testWidgets('Teste de Widget: Renderização da UI de Detalhes com dados Mockados', (WidgetTester tester) async {
    
    // Mock de dados simulando o payload (JSON) retornado pela API
    final mockMonstro = {
      'name': 'Rathalos Mock',
      'species': 'Flying Wyvern',
      'description': 'Rei dos céus.',
      'locations': [],
      'weaknesses': [],
      'resistances': [],
      'rewards': []
    };

    // Constrói o widget isoladamente no ambiente de teste
    await tester.pumpWidget(MaterialApp(
      home: Tela2Detalhes(monstro: mockMonstro),
    ));

    // Asserts visuais: Verifica se os componentes de texto e ícones foram desenhados na tela
    expect(find.text('Rathalos Mock'), findsOneWidget);
    expect(find.text('Espécie: Flying Wyvern'), findsOneWidget);
    expect(find.byIcon(Icons.menu_book), findsOneWidget);
  });
}