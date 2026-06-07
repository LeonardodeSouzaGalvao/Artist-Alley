import 'package:flutter/material.dart';
import '../core/app_cores.dart';
import '../widgets/card_artista.dart';

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.corFundo,
      appBar: AppBar(
        backgroundColor: AppCores.corSecundaria,
        title: const Text(
          'ArtistAlley',
          style: TextStyle(
            color: AppCores.corPrimaria,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppCores.corTexto),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppCores.corBorda),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Seção artistas em destaque
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Artistas em destaque',
                style: TextStyle(
                  color: AppCores.corTexto,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Ver todos',
                  style: TextStyle(color: AppCores.corPrimaria, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Lista de cards
          ...List.generate(4, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CardArtista(
              nome: _nomesArtistas[i],
              especialidade: _especialidades[i],
              avaliacao: _avaliacoes[i],
              totalTrabalhos: _totalTrabalhos[i],
            ),
          )),
        ],
      ),
    );
  }

  static const _nomesArtistas = [
    'Ana Costa',
    'Bruno Melo',
    'Carla Dias',
    'Diego Lima',
  ];
  static const _especialidades = [
    'Ilustração Digital • Chibi',
    'Arte Conceitual • Fantasia',
    'Retratos • Realismo',
    'Pixel Art • Game Art',
  ];
  static const _avaliacoes = [4.9, 4.7, 4.8, 4.6];
  static const _totalTrabalhos = [128, 87, 203, 54];
}

class _CategoriasFiltro extends StatefulWidget {
  @override
  State<_CategoriasFiltro> createState() => _CategoriasFiltroState();
}

class _CategoriasFiltroState extends State<_CategoriasFiltro> {
  int _selecionado = 0;
  final _categorias = ['Todos', 'Ilustração', 'Pixel Art', 'Retratos', 'Chibi', '3D'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categorias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selecionado = i == _selecionado;
          return GestureDetector(
            onTap: () => setState(() => _selecionado = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selecionado ? AppCores.corPrimaria : AppCores.corSecundaria,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selecionado ? AppCores.corPrimaria : AppCores.corBorda,
                ),
              ),
              child: Text(
                _categorias[i],
                style: TextStyle(
                  color: selecionado ? AppCores.corTextoBranco : AppCores.corTextoSecundario,
                  fontSize: 13,
                  fontWeight: selecionado ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
