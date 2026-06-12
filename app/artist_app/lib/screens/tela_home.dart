import 'package:flutter/material.dart';
import '../core/app_cores.dart';
import '../widgets/card_artista.dart';

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    var _fotoUrls;
    return Scaffold(
      backgroundColor: AppCores.corFundo,
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

        ],
      ),
    );
  }
}
