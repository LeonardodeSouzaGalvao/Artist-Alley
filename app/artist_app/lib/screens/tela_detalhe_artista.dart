import 'package:flutter/material.dart';
import '../core/app_cores.dart';

class TelaDetalheArtista extends StatelessWidget {
  final String nome;
  final String descricao;
  final String valor;
  final String fotoUrl;

  const TelaDetalheArtista({
    super.key,
    required this.nome,
    required this.descricao,
    required this.valor,
    required this.fotoUrl,
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
          Container(
            color: AppCores.corSecundaria,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
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
                      const SizedBox(height: 8),
                      
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Container(
            color: AppCores.corSecundaria,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Commission aberta',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppCores.corTexto,
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      height:
                          160, 
                      color: Colors.grey[200],
                      child:
                          fotoUrl
                              .isNotEmpty
                          ? Image.network(
                              fotoUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  
                  'Vaga para ilustração de personagem em estilo chibi. Orçamento de R\$ 500, prazo de 2 semanas.',
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

        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: AppCores.corSecundaria,
          border: Border(top: BorderSide(color: AppCores.corBorda)),
        ),
        child: ElevatedButton(
          onPressed: () => _mostrarModalContratar(context),
          child: const Text('Pedir commission'),
        ),
      ),
    );
  }

  void _mostrarModalContratar(BuildContext context) {
  String? nomeArquivoSelecionado;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppCores.corSecundaria,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Padding(
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
              const SizedBox(height: 16),
              
              const Text(
                'Imagens de referência',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppCores.corTexto),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  setModalState(() {
                    nomeArquivoSelecionado = 'referencia_personagem.png';
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppCores.corFundo,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppCores.corBorda, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        nomeArquivoSelecionado != null ? Icons.image_rounded : Icons.file_upload_outlined,
                        color: nomeArquivoSelecionado != null ? AppCores.corSucesso : AppCores.corTextoSecundario,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          nomeArquivoSelecionado ?? 'Selecione uma imagem ou moodboard...',
                          style: TextStyle(
                            fontSize: 14,
                            color: nomeArquivoSelecionado != null ? AppCores.corTexto : AppCores.corTextoSecundario,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (nomeArquivoSelecionado != null)
                        GestureDetector(
                          onTap: () {
                            setModalState(() {
                              nomeArquivoSelecionado = null;
                            });
                          },
                          child: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Enviar proposta'),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

}
