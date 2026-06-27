import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/app_cores.dart';
import 'userSection.dart';

class TelaCommissions extends StatefulWidget {
  const TelaCommissions({super.key});

  @override
  State<TelaCommissions> createState() => _TelaCommissionsState();
}

class _TelaCommissionsState extends State<TelaCommissions> {
  final String _apiUrl = 'http://10.0.2.2:3000';
  List<dynamic> _commissions = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _buscarCommissions();
  }

  Future<void> _buscarCommissions() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final artistId = UserSession.instance.id;
      if (artistId == null) {
        setState(() {
          _erro = 'Sessão inválida.';
          _carregando = false;
        });
        return;
      }

      final token = UserSession.instance.token;
      final response = await http.get(
        Uri.parse('$_apiUrl/commission-slots/artist/$artistId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // API retorna um único slot por artista conforme o service findByArtistId
          // Se quiser listar todos, use o endpoint '/' com filtro local
          _commissions = data is List ? data : [data];
          _carregando = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _commissions = [];
          _carregando = false;
        });
      } else {
        setState(() {
          _erro = 'Erro ao carregar commissions.';
          _carregando = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _erro = 'Não foi possível conectar ao servidor.';
          _carregando = false;
        });
      }
    }
  }

  Future<void> _abrirModalCriar() async {
    final criado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ModalCriarCommission(),
    );
    if (criado == true) _buscarCommissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.corFundo,
      appBar: AppBar(
        backgroundColor: AppCores.corSecundaria,
        title: const Text(
          'Minhas Commissions',
          style: TextStyle(color: AppCores.corTexto, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppCores.corBorda),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh, color: AppCores.corTexto),
            onPressed: _buscarCommissions,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirModalCriar,
        backgroundColor: AppCores.corPrimaria,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova commission', style: TextStyle(color: Colors.white)),
      ),
      body: _construirConteudo(),
    );
  }

  Widget _construirConteudo() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(color: AppCores.corPrimaria),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 56, color: AppCores.corTextoClaro),
              const SizedBox(height: 16),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppCores.corTextoSecundario),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _buscarCommissions,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppCores.corPrimaria,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_commissions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppCores.corPrimariaClara,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.palette_outlined,
                  size: 40,
                  color: AppCores.corPrimaria,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Nenhuma commission ainda',
                style: TextStyle(
                  color: AppCores.corTexto,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crie sua primeira commission para começar a receber pedidos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppCores.corTextoSecundario, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _commissions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CardCommission(
        commission: _commissions[i],
        onAtualizar: _buscarCommissions,
      ),
    );
  }
}

// ─── Card de commission ───────────────────────────────────────────────────────

class _CardCommission extends StatelessWidget {
  final Map<String, dynamic> commission;
  final VoidCallback onAtualizar;

  const _CardCommission({required this.commission, required this.onAtualizar});

  final String _apiUrl = 'http://10.0.2.2:3000';

  Future<void> _remover(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppCores.corSecundaria,
        title: const Text('Remover commission', style: TextStyle(color: AppCores.corTexto)),
        content: const Text(
          'Tem certeza? Essa ação não pode ser desfeita.',
          style: TextStyle(color: AppCores.corTextoSecundario),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover', style: TextStyle(color: AppCores.corErro)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final id = commission['id'] as String;
      final token = UserSession.instance.token;

      final response = await http.delete(
        Uri.parse('$_apiUrl/commission-slots/$id'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        onAtualizar();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao remover commission.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível conectar ao servidor.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = commission['title'] as String? ?? 'Sem título';
    final String description = commission['description'] as String? ?? '';
    final dynamic priceRaw = commission['price'];
    final String preco = priceRaw != null ? 'R\$ $priceRaw' : 'A combinar';
    final int slots = (commission['slots'] as num?)?.toInt() ?? 0;
    final bool available = commission['available'] as bool? ?? false;
    final String? imageUrl = commission['imageUrl'] as String?;

    return Container(
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
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _PlaceholderImagem(topRadius: true),
              ),
            )
          else
            const _PlaceholderImagem(topRadius: true),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppCores.corTexto,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: available
                            ? const Color.fromARGB(255, 198, 255, 219)
                            : AppCores.corPrimariaClara,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        available ? 'Disponível' : 'Indisponível',
                        style: TextStyle(
                          color: available ? AppCores.corSucesso : AppCores.corTextoClaro,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppCores.corTextoSecundario,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 16, color: AppCores.corSucesso),
                    Text(
                      preco,
                      style: const TextStyle(
                        color: AppCores.corSucesso,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.people_outline, size: 16, color: AppCores.corTextoSecundario),
                    const SizedBox(width: 4),
                    Text(
                      '$slots vagas',
                      style: const TextStyle(
                        color: AppCores.corTextoSecundario,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    // ── Botão remover ──────────────────────────
                    TextButton.icon(
                      onPressed: () => _remover(context),
                      icon: const Icon(Icons.delete_outline, size: 16, color: AppCores.corErro),
                      label: const Text('Remover', style: TextStyle(color: AppCores.corErro, fontSize: 13)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _PlaceholderImagem extends StatelessWidget {
  final bool topRadius;
  const _PlaceholderImagem({this.topRadius = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: topRadius
          ? const BorderRadius.vertical(top: Radius.circular(12))
          : BorderRadius.zero,
      child: Container(
        height: 120,
        width: double.infinity,
        color: AppCores.corBorda,
        child: const Icon(Icons.image_outlined, size: 40, color: AppCores.corTextoClaro),
      ),
    );
  }
}

// ─── Modal de criação ─────────────────────────────────────────────────────────

class _ModalCriarCommission extends StatefulWidget {
  const _ModalCriarCommission();

  @override
  State<_ModalCriarCommission> createState() => _ModalCriarCommissionState();
}

class _ModalCriarCommissionState extends State<_ModalCriarCommission> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _precoCtrl = TextEditingController();
  final _slotsCtrl = TextEditingController();
  final _imagemCtrl = TextEditingController();

  bool _enviando = false;
  String? _erroEnvio;

  final String _apiUrl = 'http://10.0.2.2:3000';

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    _precoCtrl.dispose();
    _slotsCtrl.dispose();
    _imagemCtrl.dispose();
    super.dispose();
  }

  Future<void> _criar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _enviando = true;
      _erroEnvio = null;
    });

    try {
      final artistId = UserSession.instance.id;
      final token = UserSession.instance.token;

      final body = jsonEncode({
        'title': _tituloCtrl.text.trim(),
        'description': _descricaoCtrl.text.trim(),
        'price': double.tryParse(_precoCtrl.text.trim()) ?? 0,
        'slots': int.tryParse(_slotsCtrl.text.trim()) ?? 1,
        'artistId': artistId,
        if (_imagemCtrl.text.trim().isNotEmpty)
          'imageUrl': _imagemCtrl.text.trim(),
      });

      final response = await http.post(
        Uri.parse('$_apiUrl/commission-slots/createCommissionSlot'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        Navigator.of(context).pop(true);
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _erroEnvio = data['error'] ?? 'Erro ao criar commission.';
          _enviando = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _erroEnvio = 'Não foi possível conectar ao servidor.';
          _enviando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppCores.corSecundaria,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppCores.corBorda,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text(
              'Nova commission',
              style: TextStyle(
                color: AppCores.corTexto,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Preencha os dados para criar uma nova commission.',
              style: TextStyle(color: AppCores.corTextoSecundario, fontSize: 13),
            ),
            const SizedBox(height: 24),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Campo(
                    label: 'Título',
                    controller: _tituloCtrl,
                    hint: 'Ex: Ilustração digital de personagem',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Informe um título' : null,
                  ),
                  const SizedBox(height: 16),
                  _Campo(
                    label: 'Descrição',
                    controller: _descricaoCtrl,
                    hint: 'Descreva o que está incluso na commission...',
                    maxLines: 3,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Informe uma descrição' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _Campo(
                          label: 'Preço (R\$)',
                          controller: _precoCtrl,
                          hint: '150.00',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Obrigatório';
                            if (double.tryParse(v.trim()) == null) return 'Valor inválido';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Campo(
                          label: 'Vagas',
                          controller: _slotsCtrl,
                          hint: '5',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Obrigatório';
                            if (int.tryParse(v.trim()) == null) return 'Número inválido';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Campo(
                    label: 'URL da imagem (opcional)',
                    controller: _imagemCtrl,
                    hint: 'https://res.cloudinary.com/...',
                  ),

                  if (_erroEnvio != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppCores.corErro,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppCores.corErro.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppCores.corErro, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _erroEnvio!,
                              style: const TextStyle(color: AppCores.corErro, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _enviando ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppCores.corTextoSecundario,
                            side: const BorderSide(color: AppCores.corBorda),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _enviando ? null : _criar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppCores.corPrimaria,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _enviando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Criar commission',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
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
    );
  }
}

// ─── Widget auxiliar de campo ─────────────────────────────────────────────────

class _Campo extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Campo({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppCores.corTexto,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppCores.corTexto, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppCores.corTextoClaro, fontSize: 14),
            filled: true,
            fillColor: AppCores.corFundo,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppCores.corBorda),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppCores.corBorda),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppCores.corPrimaria),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppCores.corErro),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppCores.corErro),
            ),
          ),
        ),
      ],
    );
  }
}