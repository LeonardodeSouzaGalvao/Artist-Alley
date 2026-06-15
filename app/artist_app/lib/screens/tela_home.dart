import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/app_cores.dart';
import 'userSection.dart';
import 'tela_login.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  final String _apiUrl = 'http://10.0.2.2:3000';
  List<dynamic> _destaques = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _buscarDestaques();
  }

  Future<void> _buscarDestaques() async {
    try {
      final token = UserSession.instance.token;
      final response = await http.get(
        Uri.parse('$_apiUrl/commission-slots'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        setState(() {
          _destaques = dados.take(5).toList();
          _carregando = false;
        });
      } else {
        setState(() => _carregando = false);
      }
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppCores.corSecundaria,
        title: const Text('Sair', style: TextStyle(color: AppCores.corTexto)),
        content: const Text(
          'Deseja encerrar sua sessão?',
          style: TextStyle(color: AppCores.corTextoSecundario),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair', style: TextStyle(color: AppCores.corErro)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await UserSession.instance.clear();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TelaLogin()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = UserSession.instance;
    final String nome = session.username ?? 'Usuário';
    final String email = session.email ?? '';
    final String role = session.role ?? '';
    final String inicial = nome.isNotEmpty ? nome[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppCores.corFundo,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card do usuário
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppCores.corSecundaria,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppCores.corBorda, width: 0.8),
              boxShadow: const [
                BoxShadow(color: AppCores.corSombra, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppCores.corPrimariaClara,
                  child: Text(
                    inicial,
                    style: const TextStyle(
                      color: AppCores.corPrimaria,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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
                          color: AppCores.corTexto,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                          color: AppCores.corTextoSecundario,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppCores.corPrimariaClara,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role == 'ARTIST' ? 'Artista' : 'Cliente',
                          style: const TextStyle(
                            color: AppCores.corPrimaria,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Sair',
                  icon: const Icon(Icons.logout, color: AppCores.corErro),
                  onPressed: _logout,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Artistas em destaque
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

          _carregando
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppCores.corPrimaria),
                  ),
                )
              : _destaques.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Nenhum artista em destaque.',
                          style: TextStyle(color: AppCores.corTextoSecundario),
                        ),
                      ),
                    )
                  : Column(
                      children: _destaques
                          .map((slot) => _CardDestaque(slot: slot))
                          .toList(),
                    ),
        ],
      ),
    );
  }
}

class _CardDestaque extends StatelessWidget {
  final Map<String, dynamic> slot;
  const _CardDestaque({required this.slot});

  @override
  Widget build(BuildContext context) {
    final String title = slot['title'] as String? ?? 'Sem título';
    final String description = slot['description'] as String? ?? '';
    final dynamic priceRaw = slot['price'];
    final String preco = priceRaw != null ? 'R\$ $priceRaw' : 'A combinar';
    final String? imageUrl = slot['imageUrl'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 64,
              height: 64,
              color: Colors.grey[200],
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, color: Colors.grey))
                  : const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppCores.corTexto,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppCores.corTextoSecundario,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  preco,
                  style: const TextStyle(
                    color: AppCores.corSucesso,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}