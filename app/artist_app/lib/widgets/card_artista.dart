import 'package:flutter/material.dart';
import '../core/app_cores.dart';
import '../screens/tela_detalhe_artista.dart';

class CardArtista extends StatelessWidget {
  final String nome;
  final String descricao;
  final String valor;
  final String fotoUrl;

  const CardArtista({
    super.key,
    required this.nome,
    required this.descricao,
    required this.valor,
    required this.fotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TelaDetalheArtista(
            nome: nome,
            descricao: descricao,
            valor: valor,
            fotoUrl: fotoUrl, artistId: '', commissionSlotId: '',
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppCores.corFundoCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppCores.corBorda, width: 0.8),
          boxShadow: const [
            BoxShadow(color: AppCores.corSombra, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppCores.corDestaque,
                borderRadius: BorderRadius.circular(27),
                border: Border.all(color: AppCores.corPrimariaClara, width: 2),
              ),
              child: Center(
                child: Text(
                  nome[0],
                  style: const TextStyle(
                    color: AppCores.corPrimaria,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppCores.corTexto,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descricao,
                    style: const TextStyle(
                      color: AppCores.corTextoSecundario,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                      const SizedBox(width: 3),
                      Text(
                        valor,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppCores.corTexto,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Valor: $valor',
                        style: const TextStyle(
                          color: AppCores.corTextoClaro,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: AppCores.corTextoClaro,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
