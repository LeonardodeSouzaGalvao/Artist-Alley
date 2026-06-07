import 'package:flutter/material.dart';
import '../core/app_cores.dart';

class TelaDetalheArtista extends StatelessWidget {
  final String nome;
  final String especialidade;
  final double avaliacao;
  final int totalTrabalhos;

  const TelaDetalheArtista({
    super.key,
    required this.nome,
    required this.especialidade,
    required this.avaliacao,
    required this.totalTrabalhos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.corFundo,
      appBar: AppBar(
        backgroundColor: AppCores.corSecundaria,
        title: Text(nome),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppCores.corBorda),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppCores.corTexto),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: AppCores.corTexto),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        children: [
          // Cabeçalho do artista
          Container(
            color: AppCores.corSecundaria,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppCores.corPrimariaClara,
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(color: AppCores.corPrimaria, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      nome[0],
                      style: const TextStyle(
                        color: AppCores.corPrimaria,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppCores.corTexto,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        especialidade,
                        style: const TextStyle(
                          color: AppCores.corTextoSecundario,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            avaliacao.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppCores.corTexto,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• $totalTrabalhos trabalhos',
                            style: const TextStyle(
                              color: AppCores.corTextoSecundario,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Sobre
          Container(
            color: AppCores.corSecundaria,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sobre',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppCores.corTexto,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Artista digital apaixonado por criar mundos únicos e personagens memoráveis. '
                  'Trabalho com projetos de ilustração há mais de 5 anos, atendendo clientes '
                  'nacionais e internacionais com qualidade e pontualidade.',
                  style: TextStyle(
                    color: AppCores.corTextoSecundario,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Portfólio
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Portfólio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppCores.corTexto,
                  ),
                ),
                Text(
                  'Ver todos ($totalTrabalhos)',
                  style: const TextStyle(
                    color: AppCores.corPrimaria,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Grid de portfólio
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: 4,
            itemBuilder: (_, i) => _CardPortfolio(indice: i),
          ),

          const SizedBox(height: 8),

          // Avaliações
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppCores.corSecundaria,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppCores.corBorda),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Avaliações recentes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppCores.corTexto,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(2, (i) => _ItemAvaliacao(indice: i)),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),

      // Botão fixo no rodapé
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: AppCores.corSecundaria,
          border: Border(top: BorderSide(color: AppCores.corBorda)),
        ),
        child: ElevatedButton(
          onPressed: () => _mostrarModalContratar(context),
          child: const Text('Contratar artista'),
        ),
      ),
    );
  }

  void _mostrarModalContratar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppCores.corSecundaria,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppCores.corBorda,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Contratar $nome',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(labelText: 'Descreva seu projeto'),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Orçamento (R\$)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Prazo estimado'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Enviar proposta'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPortfolio extends StatelessWidget {
  final int indice;
  const _CardPortfolio({required this.indice});

  static const _cores = [
    AppCores.corPrimariaClara,
    Color(0xFFE0E7FF),
    Color(0xFFDCFCE7),
    Color(0xFFFEE2E2),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cores[indice % _cores.length],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppCores.corBorda),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppCores.corTextoClaro,
          size: 40,
        ),
      ),
    );
  }
}

class _ItemAvaliacao extends StatelessWidget {
  final int indice;
  const _ItemAvaliacao({required this.indice});

  static const _nomes = ['Maria S.', 'João P.'];
  static const _textos = [
    'Trabalho incrível! Entregou antes do prazo e superou minhas expectativas.',
    'Ótima comunicação e qualidade impecável. Recomendo muito!',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppCores.corDestaque,
                child: Text(
                  _nomes[indice][0],
                  style: const TextStyle(color: AppCores.corPrimaria, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _nomes[indice],
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const Spacer(),
              const Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _textos[indice],
            style: const TextStyle(
              color: AppCores.corTextoSecundario,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (indice == 0)
            const Divider(height: 20, color: AppCores.corDivisor),
        ],
      ),
    );
  }
}
