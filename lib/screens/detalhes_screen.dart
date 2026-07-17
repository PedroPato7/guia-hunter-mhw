import 'package:flutter/material.dart';

// Tela responsável por exibir os detalhes completos de uma criatura em abas
class Tela2Detalhes extends StatelessWidget {
  // Detalhe gamer. 
  final dynamic monstro;
  
  const Tela2Detalhes({super.key, required this.monstro});

  @override
  Widget build(BuildContext context) {
    // Extração segura dos dados da API
    final nome = monstro['name'] ?? 'Desconhecido';
    final especieOriginal = monstro['species'] ?? 'N/A';
    final descricao = monstro['description'] ?? 'Sem descrição.';
    final locais = monstro['locations'] as List<dynamic>? ?? [];
    final fraquezas = monstro['weaknesses'] as List<dynamic>? ?? [];
    final resistencias = monstro['resistances'] as List<dynamic>? ?? [];
    final recompensas = monstro['rewards'] as List<dynamic>? ?? [];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(nome),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.orange,
            tabs: [
              Tab(icon: Icon(Icons.menu_book), text: 'Ecologia'),
              Tab(icon: Icon(Icons.flash_on), text: 'Fraquezas'),
              Tab(icon: Icon(Icons.inventory_2), text: 'Drops'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Aba 1: Informações gerais e locais de aparição
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Espécie: $especieOriginal',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                  ),
                  const Divider(color: Colors.orange),
                  const SizedBox(height: 10),
                  const Text('Descrição (Inglês):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(descricao, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 20),
                  const Text('Onde encontrar:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    children: locais.map((l) => Chip(
                      label: Text(l['name']),
                      backgroundColor: Colors.green[900],
                      avatar: const Icon(Icons.location_on, size: 16, color: Colors.white),
                    )).toList(),
                  ),
                ],
              ),
            ),

            // Aba 2: Efetividade elemental e imunidades
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Efetividade Elemental e Status:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (fraquezas.isEmpty && resistencias.isEmpty)
                    const Text('Nenhuma informação de combate registrada para esta criatura.')
                  else ...[
                    // Renderiza as fraquezas (Estrelas)
                    ...fraquezas.map((f) {
                      int estrelas = f['stars'] ?? 0;
                      if (estrelas == 0) return const SizedBox.shrink();
                      return Card(
                        color: Colors.black45,
                        child: ListTile(
                          leading: _getIconeElemento(f['element'].toString()),
                          title: Text(f['element'].toString().toUpperCase()),
                          trailing: Text('⭐' * estrelas, style: const TextStyle(fontSize: 18)),
                        ),
                      );
                    }),
                    // Renderiza as resistências (Imunidades)
                    ...resistencias.map((r) {
                      return Card(
                        color: Colors.black45,
                        child: ListTile(
                          leading: _getIconeElemento(r['element'].toString()),
                          title: Text(r['element'].toString().toUpperCase()),
                          trailing: const Text('❌', style: TextStyle(fontSize: 18)),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),

            // Aba 3: Lista de materiais dropados pelo monstro
            AbaDrops(recompensas: recompensas),
          ],
        ),
      ),
    );
  }

  // Define os ícones correspondentes a cada elemento/status do jogo
  Widget _getIconeElemento(String elemento) {
    switch (elemento.toLowerCase()) {
      case 'fire': return const Icon(Icons.local_fire_department, color: Colors.red);
      case 'water': return const Icon(Icons.water_drop, color: Colors.blue);
      case 'thunder': return const Icon(Icons.bolt, color: Colors.yellow);
      case 'ice': return const Icon(Icons.ac_unit, color: Colors.cyan);
      case 'dragon': return const Icon(Icons.dark_mode, color: Colors.deepPurple);
      case 'poison': return const Icon(Icons.science, color: Colors.purple);
      case 'sleep': return const Icon(Icons.bedtime, color: Colors.indigo);
      case 'paralysis': return const Icon(Icons.electric_bolt, color: Colors.amber);
      case 'blast': return const Icon(Icons.dynamic_form, color: Colors.orange);
      case 'stun': return const Icon(Icons.stars, color: Colors.yellowAccent);
      default: return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }
}

// Widget Stateful para gerenciar a exibição e os filtros da aba de Drops
class AbaDrops extends StatefulWidget {
  final List<dynamic> recompensas;

  const AbaDrops({super.key, required this.recompensas});

  @override
  State<AbaDrops> createState() => _AbaDropsState();
}

class _AbaDropsState extends State<AbaDrops> {
  String _rankSelecionado = 'low';

  @override
  Widget build(BuildContext context) {
    // Tratamento para criaturas sem drops registrados na API
    if (widget.recompensas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.travel_explore, size: 80, color: Colors.orange[300]),
              const SizedBox(height: 16),
              const Text(
                'Data Not Found',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                'The Hunter\'s Guild database has not yet fully cataloged the specific drop rates for this creature.\n\nTry checking other monsters!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    // Filtra e estrutura os drops com base no rank selecionado
    List<Map<String, dynamic>> dropsParaMostrar = [];
    for (var reward in widget.recompensas) {
      var condicoesDoRank = (reward['conditions'] as List? ?? [])
          .where((condicao) => condicao['rank'] == _rankSelecionado)
          .toList();

      if (condicoesDoRank.isNotEmpty) {
        dropsParaMostrar.add({
          'itemName': reward['item']?['name'] ?? 'Unknown Item',
          'conditions': condicoesDoRank,
        });
      }
    }

    return Column(
      children: [
        // Botões de filtro de Rank
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          color: Colors.brown[900]?.withOpacity(0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Low Rank', style: TextStyle(fontWeight: FontWeight.bold)),
                selected: _rankSelecionado == 'low',
                selectedColor: Colors.green[700],
                onSelected: (bool selected) {
                  if (selected) setState(() => _rankSelecionado = 'low');
                },
              ),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('High Rank', style: TextStyle(fontWeight: FontWeight.bold)),
                selected: _rankSelecionado == 'high',
                selectedColor: Colors.orange[800],
                onSelected: (bool selected) {
                  if (selected) setState(() => _rankSelecionado = 'high');
                },
              ),
            ],
          ),
        ),
        
        // Lista de Drops renderizada
        Expanded(
          child: dropsParaMostrar.isEmpty
              ? Center(
            child: Text(
              'No $_rankSelecionado rank drops registered for this creature.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          )
              : ListView.builder(
            itemCount: dropsParaMostrar.length,
            itemBuilder: (context, index) {
              final drop = dropsParaMostrar[index];
              final nomeItem = drop['itemName'];

              final descricaoCondicoes = (drop['conditions'] as List).map((c) {
                String tipo = c['type']?.toString() ?? 'Unknown';
                String chance = c['chance']?.toString() ?? '?';
                String subtipo = c['subtype']?.toString() ?? '';

                if (subtipo.isNotEmpty) {
                  return "$tipo ($subtipo) - $chance%";
                }
                return "$tipo - $chance%";
              }).join('\n');

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.auto_fix_high, color: Colors.cyanAccent),
                  title: Text(nomeItem, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      descricaoCondicoes,
                      style: TextStyle(color: Colors.orange[200])
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}