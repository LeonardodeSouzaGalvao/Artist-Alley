import 'dart:convert';
import 'package:artist_app/screens/tela_detalhe_artista.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/app_cores.dart';


class CloudinaryConfig {
  static const String cloudName = const String.fromEnvironment('NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME');
  static const String uploadPreset = const String.fromEnvironment('NEXT_PUBLIC_CLOUDINARY_UPLOAD_PRESET');
}

class TelaExplorar extends StatefulWidget {
  const TelaExplorar({super.key});

  @override
  State<TelaExplorar> createState() => _TelaExplorarState();
}

class _TelaExplorarState extends State<TelaExplorar> {
  final _buscaController = TextEditingController();
  final String _apiUrl = 'http://10.0.2.2:3000';

  List<dynamic> _todasCommissions = [];
  List<dynamic> _commissionsFiltradas = [];
  bool _carregando = true;
  String? _erroMensagem;

  @override
  void initState() {
    super.initState();
    _buscarCommissions();
    _buscaController.addListener(_filtrarVagas);
  }

  @override
  void dispose() {
    _buscaController.removeListener(_filtrarVagas);
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _buscarCommissions() async {
    try {
      setState(() {
        _carregando = true;
        _erroMensagem = null;
      });

      final url = Uri.parse('$_apiUrl/commission-slots');
      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        setState(() {
          _todasCommissions = dados;
          _commissionsFiltradas = dados;
          _carregando = false;
        });
      } else {
        setState(() {
          _erroMensagem = 'Erro ao carregar vagas do servidor.';
          _carregando = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroMensagem = 'Não foi possível conectar ao servidor. Verifique sua conexão.';
        _carregando = false;
      });
    }
  }

  void _filtrarVagas() {
    final query = _buscaController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _commissionsFiltradas = _todasCommissions;
      } else {
        _commissionsFiltradas = _todasCommissions.where((vaga) {
          final titulo = (vaga['title'] ?? '').toString().toLowerCase();
          final descricao = (vaga['description'] ?? '').toString().toLowerCase();
          return titulo.contains(query) || descricao.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.corFundo,
      appBar: AppBar(
        backgroundColor: AppCores.corSecundaria,
        title: const Text('Explorar Vagas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _buscarCommissions,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppCores.corBorda),
        ),
      ),
      body: Column(
        children: [
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
          Expanded(
            child: _construirConteudo(),
          ),
        ],
      ),
    );
  }

  Widget _construirConteudo() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppCores.corPrimaria,
        ),
      );
    }

    if (_erroMensagem != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _erroMensagem!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppCores.corTextoSecundario),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _buscarCommissions,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_commissionsFiltradas.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma vaga encontrada.',
          style: TextStyle(color: AppCores.corTextoSecundario),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _commissionsFiltradas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _CardVaga(vaga: _commissionsFiltradas[i]),
    );
  }
}

class _CardVaga extends StatelessWidget {
  final Map<String, dynamic> vaga;
  const _CardVaga({required this.vaga});

  String obterUrlOtimizada(String urlOriginal) {
    if (urlOriginal.isEmpty) return '';

    if (urlOriginal.contains('cloudinary.com')) {
      return urlOriginal.replaceAll('/upload/', '/upload/w_400,c_scale,q_auto,f_auto/');
    }

    if (!urlOriginal.startsWith('http')) {
      final cloudName = CloudinaryConfig.cloudName;
      return 'https://res.cloudinary.com/$cloudName/image/upload/w_400,c_scale,q_auto,f_auto/$urlOriginal';
    }

    return urlOriginal;
  }

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = vaga['imageUrl'] as String?;
    final String title = vaga['title'] as String? ?? 'Sem título';
    final String description = vaga['description'] as String? ?? '';
    
    final dynamic priceRaw = vaga['price'];
    final String orcamento = priceRaw != null ? 'R\$ ${priceRaw.toString()}' : 'A combinar';

    final String urlFinal = obterUrlOtimizada(imageUrl ?? '');

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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              height: 150,
              color: Colors.grey[200],
              child: urlFinal.isNotEmpty
                  ? Image.network(
                      urlFinal, 
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
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
                      child: Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppCores.corTexto,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
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
                orcamento,
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TelaDetalheArtista(
                      nome: title,
                      descricao: description,
                      valor: orcamento,
                      fotoUrl: urlFinal, artistId: '', commissionSlotId: '',
                    ),
                  ),
                );
              },
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