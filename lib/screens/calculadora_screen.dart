import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/mhw_loading.dart';
import '../utils/constants.dart';
import '../providers/calculadora_provider.dart'; 

// Tela responsável pela lista de armaduras e cálculo de materiais (Wishlist)
class Tela3Calculadora extends StatefulWidget {
  const Tela3Calculadora({super.key});

  @override
  State<Tela3Calculadora> createState() => _Tela3CalculadoraState();
}

class _Tela3CalculadoraState extends State<Tela3Calculadora> {
  // Controle de estado local
  List<dynamic> armadurasOriginais = [];
  List<dynamic> armadurasExibidas = [];
  bool carregando = true;
  String _rankSelecionado = 'low';
  
  @override
  void initState() {
    super.initState();
    _buscarArmaduras();
  }

  // Busca dados da API e aplica o filtro inicial dos monstros
  Future<void> _buscarArmaduras() async {
    final url = Uri.parse('https://mhw-db.com/armor');
    try {
      final resposta = await http.get(url);
      if (resposta.statusCode == 200) {
        final dadosBrutos = jsonDecode(resposta.body) as List<dynamic>;

        // Mantem apenas as armaduras dos monstros definidos nas constantes
        final armadurasFiltradas = dadosBrutos.where((armadura) {
          final nomeArmadura = (armadura['name'] ?? '').toString().toLowerCase();
          return monstrosFoco.any((nomeMonstro) =>
              nomeArmadura.contains(nomeMonstro.toLowerCase()));
        }).toList();

        setState(() {
          armadurasOriginais = armadurasFiltradas;
          carregando = false;
        });

        _filtrarPorRank();
      }
    } catch (erro) {
      debugPrint('Erro ao buscar armaduras: $erro');
      setState(() { carregando = false; });
    }
  }

  // Atualiza a lista exibida conforme o rank selecionado
  void _filtrarPorRank() {
    setState(() {
      armadurasExibidas = armadurasOriginais.where((armadura) {
        return armadura['rank'] == _rankSelecionado;
      }).toList();
    });
  }

  // Processa os itens selecionados e soma os materiais necessários
  void _calcularMateriais() {
    Map<String, int> materiaisNecessarios = {};
    
    // Obtém os IDs salvos no gerenciador de estado (Provider)
    final selecionadosIds = context.read<CalculadoraProvider>().itensDesejados;

    for (int id in selecionadosIds) {
      final armadura = armadurasOriginais.firstWhere((a) => a['id'] == id, orElse: () => null);

      if (armadura != null) {
        final crafting = armadura['crafting'];
        if (crafting != null && crafting['materials'] != null) {
          final materiais = crafting['materials'] as List<dynamic>;

          // Soma a quantidade de cada material necessário
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

    // Exibe o resultado do cálculo em um Dialog
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
    // Escuta as mudanças do Provider para atualizar a UI reativamente
    final provider = context.watch<CalculadoraProvider>();
    final selecionadosIds = provider.itensDesejados;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forja: Calculadora'),
        centerTitle: true,
      ),
      body: carregando
          ? const MhwLoading()
          : Column(
        children: [
          // Filtros de Rank
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

          // Lista de armaduras renderizadas dinamicamente
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

                final isSelecionado = selecionadosIds.contains(id);

                return CheckboxListTile(
                  title: Text(nome),
                  subtitle: Text('ID: $id | Rank: ${armadura['rank']}'),
                  value: isSelecionado,
                  activeColor: Colors.orange,
                  onChanged: (bool? valor) {
                    // Adiciona ou remove itens persistindo no Hive via Provider
                    if (valor == true) {
                      provider.adicionarItem(id);
                    } else {
                      provider.removerItem(id);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Aciona o cálculo e exibe a quantidade de itens na Wishlist
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selecionadosIds.isEmpty ? null : _calcularMateriais,
        backgroundColor: selecionadosIds.isEmpty ? Colors.grey : Colors.orange,
        icon: const Icon(Icons.calculate),
        label: Text('Calculate (${selecionadosIds.length})'),
      ),
    );
  }
}