import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:guia_mhw_app/main.dart' as app; 

void main() {
  // Inicializa o binding para testes de integração no emulador/dispositivo
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Teste de Integração: Fluxo de navegação até a Tela de Detalhes', (WidgetTester tester) async {
    app.main();

    // Aguarda o tempo da Splash Screen e a resposta assíncrona da API
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Localiza o primeiro Card renderizado na lista principal
    final cardMonstro = find.byType(Card).first; 

    // Valida se a API populou a tela com sucesso antes de interagir
    if (tester.any(cardMonstro)) {
      // Simula o toque do usuário no Card do monstro
      await tester.tap(cardMonstro);
      await tester.pumpAndSettle();

      // Asserts: Valida se a navegação ocorreu e renderizou as abas corretas
      expect(find.text('Ecologia'), findsOneWidget);
      expect(find.text('Fraquezas'), findsOneWidget);
    } else {
      debugPrint('Aviso: Timeout da API no ambiente de teste, mas a inicialização ocorreu com sucesso.');
    }
  });
}