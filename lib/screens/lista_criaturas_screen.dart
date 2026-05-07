import 'package:flutter/material.dart';
import 'package:guia_mhw_app/widgets/mhw_loading.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'calculadora_screen.dart';
import 'detalhes_screen.dart';

// === TELA 1: LISTA DE CRIATURAS (Consumindo a API) ===
class Tela1Criaturas extends StatefulWidget {
  const Tela1Criaturas({super.key});

  @override
  State<Tela1Criaturas> createState() => _Tela1CriaturasState();
}

class _Tela1CriaturasState extends State<Tela1Criaturas> {
  // Agora temos duas listas para o filtro funcionar
  List<dynamic> monstrosOriginais = [];
  List<dynamic> monstrosFiltrados = [];

  // Variáveis do filtro
  String termoBusca = "";
  String especieSelecionada = "Todas";
  List<String> especiesDisponiveis = ["Todas"];

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _buscarMonstrosAPI();
  }

  String _formatarNomeArquivo(String nomeOriginal) {
    return nomeOriginal.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
  }

// Tenta carregar a imagem, se não achar, mostra o ícone padrão
  Widget _construirAvatarMonstro(String nomeMonstro) {
    String nomeArquivo = _formatarNomeArquivo(nomeMonstro);
    String caminhoAsset = 'assets/images/monsters/$nomeArquivo.png';

    return ClipOval(
      child: Image.asset(
        caminhoAsset,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, erro, stackTrace) {
          return const CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(Icons.pets, color: Colors.black),
          );
        },
      ),
    );
  }

  Future<void> _buscarMonstrosAPI() async {
    final url = Uri.parse('https://mhw-db.com/monsters');
    try {
      final resposta = await http.get(url);
      if (resposta.statusCode == 200) {
        final dadosBrutos = jsonDecode(resposta.body) as List<dynamic>;

        // Filtrar apenas as criatuuras da lista: "monstrosFoco"
        final dadosFiltrados = dadosBrutos.where((monstro) {
          final nome = monstro['name'] ?? '';
          return monstrosFoco.contains(nome);
          }).toList();

        Set<String> especies = {"Todas"};
        for (var monstro in dadosFiltrados) {
          if (monstro['species'] != null) {
            especies.add(monstro['species']);
          }
        }

        setState(() {
          monstrosOriginais = dadosFiltrados;
          monstrosFiltrados = dadosFiltrados;
          especiesDisponiveis = especies.toList();
          carregando = false;
        });
      }
    } catch (erro) {
      debugPrint('Erro ao buscar monstros: $erro');
      setState(() { carregando = false; });
    }
  }

  // Função mágica que filtra a lista na hora
  void _filtrarMonstros() {
    setState(() {
      monstrosFiltrados = monstrosOriginais.where((monstro) {
        final nome = (monstro['name'] ?? '').toString().toLowerCase();
        final especie = monstro['species'] ?? '';

        final bateNome = nome.contains(termoBusca.toLowerCase());
        final bateEspecie = especieSelecionada == "Todas" || especie == especieSelecionada;

        return bateNome && bateEspecie;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guia de Monstros'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate, color: Colors.orange),
            tooltip: 'Calculadora',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Tela3Calculadora()),
              );
            },
          ),
        ],
      ),
      body: carregando
          ? const MhwLoading()
          : Column(
        children: [
          // === ÁREA DE FILTROS ===
          Container(
            color: Colors.brown[900], // Fundo levemente diferente para destacar
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Barra de Pesquisa de Nome
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar por nome...',
                    prefixIcon: const Icon(Icons.search, color: Colors.orange),
                    filled: true,
                    fillColor: Colors.black45,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (texto) {
                    termoBusca = texto;
                    _filtrarMonstros();
                  },
                ),
                const SizedBox(height: 10),
                // Menu Dropdown de Espécies
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: especieSelecionada,
                    isExpanded: true,
                    underline: const SizedBox(), // Esconde a linha padrão do botão
                    dropdownColor: Colors.grey[900],
                    icon: const Icon(Icons.filter_list, color: Colors.orange),
                    items: especiesDisponiveis.map((especie) {
                      return DropdownMenuItem(
                        value: especie,
                        child: Text(especie),
                      );
                    }).toList(),
                    onChanged: (novaEspecie) {
                      if (novaEspecie != null) {
                        especieSelecionada = novaEspecie;
                        _filtrarMonstros();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // === LISTA DE RESULTADOS ===
          Expanded(
            child: monstrosFiltrados.isEmpty
                ? const Center(child: Text('Nenhum monstro encontrado.'))
                : ListView.builder(
              itemCount: monstrosFiltrados.length,
              itemBuilder: (context, index) {
                final monstro = monstrosFiltrados[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 3,
                  child: ListTile(
                    leading: _construirAvatarMonstro(monstro['name'] ?? ''),
                    title: Text(
                      monstro['name'] ?? 'Nome Desconhecido',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Espécie: ${monstro['species'] ?? 'N/A'}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Tela2Detalhes(monstro: monstro),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}