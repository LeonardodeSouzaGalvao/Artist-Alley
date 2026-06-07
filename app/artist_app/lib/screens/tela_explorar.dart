import 'package:flutter/material.dart';
import '../core/app_cores.dart';

class TelaExplorar extends StatefulWidget {
  const TelaExplorar({super.key});

  @override
  State<TelaExplorar> createState() => _TelaExplorarState();
}

class _TelaExplorarState extends State<TelaExplorar> {
  final _buscaController = TextEditingController();

  final _vagas = [
    {
      'titulo': 'Ilustrador para livro infantil',
      'descricao': 'Projeto de 20 ilustrações coloridas, estilo cartoon, para livro de 32 páginas.',
      'orcamento': 'R\$ 800 – R\$ 1.500',
    },
    {
      'titulo': 'Arte conceitual para jogo indie',
      'descricao': 'Buscamos artista para criação de personagens e cenários para RPG 2D.',
      'orcamento': 'R\$ 2.000 – R\$ 4.000',
    },
    {
      'titulo': 'Retratos digitais personalizados',
      'descricao': 'Estúdio busca artista para produção contínua de retratos em estilo anime.',
      'orcamento': 'R\$ 150 / retrato',
    },
    {
      'titulo': 'Logo e identidade visual para marca',
      'descricao': 'Startup de moda busca designer para criação de logo e guia de identidade.',
      'orcamento': 'R\$ 600 – R\$ 1.200',
    },
    {
      'titulo': 'Pixel art para app mobile',
      'descricao': 'Desenvolvedor indie busca pixel artist para criar sprites e tilesets.',
      'orcamento': 'R\$ 300 – R\$ 800',
    },
  ];

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.corFundo,
      appBar: AppBar(
        backgroundColor: AppCores.corSecundaria,
        title: const Text('Explorar Vagas'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppCores.corBorda),
        ),
      ),
      body: Column(
        children: [
          // Barra de busca
          Container(
            color: AppCores.corSecundaria,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: TextField(
              controller: _buscaController,
              decoration: const InputDecoration(
                hintText: 'Buscar vagas...',
                prefixIcon: Icon(Icons.search, color: AppCores.corTextoSecundario),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),


          // Lista de vagas
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _vagas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _CardVaga(vaga: _vagas[i]),
            ),
          ),
        ],
      ),
    );
  }
  
}

class _CardVaga extends StatelessWidget {
  final Map<String, dynamic> vaga;
  const _CardVaga({required this.vaga});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppCores.corFundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppCores.corBorda, width: 0.8),
        boxShadow: const [
          BoxShadow(color: AppCores.corSombra, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vaga['titulo'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppCores.corTexto,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            vaga['descricao'] as String,
            style: const TextStyle(
              color: AppCores.corTextoSecundario,
              fontSize: 13,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.attach_money, size: 16, color: AppCores.corSucesso),
              Text(
                vaga['orcamento'] as String,
                style: const TextStyle(
                  color: AppCores.corSucesso,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 14),
              ),
              child: const Text('Ver detalhes'),
            ),
          ),
        ],
      ),
    );
  }
}
