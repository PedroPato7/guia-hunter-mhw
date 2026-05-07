import 'package:flutter/material.dart';
import 'package:guia_mhw_app/widgets/mhw_loading.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// IMPORTANTE: Agora usando o constants.dart em vez do tradutor
import '../utils/constants.dart';

// === TELA 3: CALCULADORA DE MATERIAIS ===
class Tela3Calculadora extends StatefulWidget {
  const Tela3Calculadora({super.key});

  @override
  State<Tela3Calculadora> createState() => _Tela3CalculadoraState();
}

class _Tela3CalculadoraState extends State<Tela3Calculadora> {
  // Agora temos duas listas: a completa e a que está sendo exibida na tela
  List<dynamic> armadurasOriginais = [];
  List<dynamic> armadurasExibidas = [];

  bool carregando = true;
  String _rankSelecionado = 'low'; // Estado do Rank

  // AGORA GUARDAMOS O ID (e não a posição/index) PARA NÃO DAR BUG AO FILTRAR
  Set<int> selecionadosIds = {};

  @override
  void initState() {
    super.initState();
    _buscarArmaduras();
  }

  Future<void> _buscarArmaduras() async {
    final url = Uri.parse('https://mhw-db.com/armor');
    try {
      final resposta = await http.get(url);
      if (resposta.statusCode == 200) {
        final dadosBrutos = jsonDecode(resposta.body) as List<dynamic>;

        // 1. Primeiro filtramos pelo escopo de monstros (constante)
        final armadurasFiltradas = dadosBrutos.where((armadura) {
          final nomeArmadura = (armadura['name'] ?? '').toString().toLowerCase();
          return monstrosFoco.any((nomeMonstro) =>
              nomeArmadura.contains(nomeMonstro.toLowerCase()));
        }).toList();

        setState(() {
          armadurasOriginais = armadurasFiltradas;
          carregando = false;
        });

        // 2. Depois aplicamos o filtro de Rank inicial
        _filtrarPorRank();
      }
    } catch (erro) {
      debugPrint('Erro ao buscar armaduras: $erro');
      setState(() { carregando = false; });
    }
  }

  // Função que atualiza a lista da tela baseada nos botões de Rank
  void _filtrarPorRank() {
    setState(() {
      armadurasExibidas = armadurasOriginais.where((armadura) {
        return armadura['rank'] == _rankSelecionado;
      }).toList();
    });
  }

  // Lógica de cálculo atualizada para buscar por ID
  void _calcularMateriais() {
    Map<String, int> materiaisNecessarios = {};

    for (int id in selecionadosIds) {
      // Busca a armadura completa na lista original baseada no ID selecionado
      final armadura = armadurasOriginais.firstWhere((a) => a['id'] == id, orElse: () => null);

      if (armadura != null) {
        final crafting = armadura['crafting'];
        if (crafting != null && crafting['materials'] != null) {
          final materiais = crafting['materials'] as List<dynamic>;

          for (var mat in materiais) {
            final nomeMaterial = mat['item']['name'] ?? 'Unknown Material';
            final int quantidade = (mat['quantity'] ?? 0).toInt();

            if (materiaisNecessarios.containsKey(nomeMaterial)) {
              materiaisNecessarios[nomeMaterial] = materiaisNecessarios[nomeMaterial]! + quantidade;
            } else {
              materiaisNecessarios[nomeMaterial] = quantidade;
            }
          }
        }
      }
    }

    // Mostra o resultado da soma num Pop-up
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Wishlist (Total Materials)'),
            content: materiaisNecessarios.isEmpty
                ? const Text('No materials required for the selected items.')
                : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: materiaisNecessarios.keys.length,
                itemBuilder: (context, index) {
                  String nome = materiaisNecessarios.keys.elementAt(index);
                  int qtd = materiaisNecessarios[nome]!;
                  return ListTile(
                    leading: const Icon(Icons.build, color: Colors.orange),
                    title: Text(nome),
                    trailing: Text('x$qtd', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forja: Calculadora'),
        centerTitle: true,
      ),
      body: carregando
          ? const MhwLoading()
          : Column(
        children: [
          // === BOTÕES DE FILTRO DE RANK ===
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            color: Colors.brown[900]?.withOpacity(0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Low Rank Armor', style: TextStyle(fontWeight: FontWeight.bold)),
                  selected: _rankSelecionado == 'low',
                  selectedColor: Colors.green[700],
                  onSelected: (bool selected) {
                    if (selected) {
                      _rankSelecionado = 'low';
                      _filtrarPorRank();
                    }
                  },
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('High Rank Armor', style: TextStyle(fontWeight: FontWeight.bold)),
                  selected: _rankSelecionado == 'high',
                  selectedColor: Colors.orange[800],
                  onSelected: (bool selected) {
                    if (selected) {
                      _rankSelecionado = 'high';
                      _filtrarPorRank();
                    }
                  },
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select the armor pieces you wish to forge:',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),

          // === LISTA DE ARMADURAS ===
          Expanded(
            child: armadurasExibidas.isEmpty
                ? Center(
              child: Text(
                'No $_rankSelecionado rank armors found for the selected monsters.',
                textAlign: TextAlign.center,
              ),
            )
                : ListView.builder(
              itemCount: armadurasExibidas.length,
              itemBuilder: (context, index) {
                final armadura = armadurasExibidas[index];
                final id = armadura['id'];
                final nome = armadura['name'] ?? 'Unknown Armor';

                // Verifica se o ID desta armadura está na nossa lista de selecionados
                final isSelecionado = selecionadosIds.contains(id);

                return CheckboxListTile(
                  title: Text(nome),
                  subtitle: Text('ID: $id | Rank: ${armadura['rank']}'), // Opcional, bom para mostrar que é dinâmico
                  value: isSelecionado,
                  activeColor: Colors.orange,
                  onChanged: (bool? valor) {
                    setState(() {
                      if (valor == true) {
                        selecionadosIds.add(id);
                      } else {
                        selecionadosIds.remove(id);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Botão que ativa o cálculo
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selecionadosIds.isEmpty ? null : _calcularMateriais,
        backgroundColor: selecionadosIds.isEmpty ? Colors.grey : Colors.orange,
        icon: const Icon(Icons.calculate),
        label: Text('Calculate (${selecionadosIds.length})'), // Mostra quantos itens estão selecionados
      ),
    );
  }
}