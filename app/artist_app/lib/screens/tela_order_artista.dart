import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../core/app_cores.dart';
import 'userSection.dart';
import 'dart:async';
import '../service/event_service.dart';

class TelaOrdersArtista extends StatefulWidget {
  const TelaOrdersArtista({super.key});

  @override
  State<TelaOrdersArtista> createState() => _TelaOrdersArtistaState();
}

class _TelaOrdersArtistaState extends State<TelaOrdersArtista>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _apiUrl = 'http://10.0.2.2:3000';
  StreamSubscription? _eventoSub;

  List<dynamic> _todasOrders = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _buscarOrders();
    _escutarEventos();
  }

  void _escutarEventos() {
    final artistId = UserSession.instance.id;
    if (artistId == null) return;

    _eventoSub = EventService.instance
        .connect(artistId)
        .listen((evento) {
      if (evento['type'] == 'ORDER_UPDATE') {
        _buscarOrders();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _eventoSub?.cancel();
    super.dispose();
  }

  Future<void> _buscarOrders() async {
    final artistId = UserSession.instance.id;
    if (artistId == null) {
      setState(() {
        _erro = 'Sessão expirada. Faça login novamente.';
        _carregando = false;
      });
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final token = UserSession.instance.token;
      final response = await http.get(
        Uri.parse('$_apiUrl/orders/artist/$artistId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _todasOrders = data is List ? data : [data];
          _carregando = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _todasOrders = [];
          _carregando = false;
        });
      } else {
        setState(() {
          _erro = 'Erro ao carregar pedidos.';
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

  List<dynamic> _filtrar(String tipo) {
    switch (tipo) {
      case 'pendentes':
        return _todasOrders
            .where((o) => o['status'] == 'PENDING')
            .toList();
      case 'andamento':
        return _todasOrders.where((o) {
          final s = o['status'] as String? ?? '';
          return s == 'ACCEPTED' ||
              s == 'IN_PROGRESS' ||
              s == 'WAITING_PAYMENT' ||
              s == 'REVISED';
        }).toList();
      default:
        return _todasOrders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.corFundo,
      appBar: AppBar(
        backgroundColor: AppCores.corSecundaria,
        title: const Text(
          'Pedidos recebidos',
          style: TextStyle(color: AppCores.corTexto, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh, color: AppCores.corTexto),
            onPressed: _buscarOrders,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppCores.corPrimaria,
          unselectedLabelColor: AppCores.corTextoSecundario,
          indicatorColor: AppCores.corPrimaria,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Pendentes'),
            Tab(text: 'Em andamento'),
          ],
        ),
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: AppCores.corPrimaria))
          : _erro != null
              ? _ErroWidget(mensagem: _erro!, onRetry: _buscarOrders)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _ListaOrders(
                      orders: _filtrar('todos'),
                      onAtualizar: _buscarOrders,
                    ),
                    _ListaOrders(
                      orders: _filtrar('pendentes'),
                      onAtualizar: _buscarOrders,
                    ),
                    _ListaOrders(
                      orders: _filtrar('andamento'),
                      onAtualizar: _buscarOrders,
                    ),
                  ],
                ),
    );
  }
}

// ─── Lista ────────────────────────────────────────────────────────────────────

class _ListaOrders extends StatelessWidget {
  final List<dynamic> orders;
  final VoidCallback onAtualizar;

  const _ListaOrders({required this.orders, required this.onAtualizar});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: AppCores.corTextoClaro),
            SizedBox(height: 12),
            Text(
              'Nenhum pedido aqui',
              style: TextStyle(color: AppCores.corTextoSecundario, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CardOrder(
        order: orders[i],
        onAtualizar: onAtualizar,
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _CardOrder extends StatefulWidget {
  final Map<String, dynamic> order;
  final VoidCallback onAtualizar;

  const _CardOrder({required this.order, required this.onAtualizar});

  @override
  State<_CardOrder> createState() => _CardOrderState();
}

class _CardOrderState extends State<_CardOrder> {
  final String _apiUrl = 'http://10.0.2.2:3000';
  bool _processando = false;

  // ── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _infoStatus(String status) {
    switch (status) {
      case 'PENDING':
        return {'texto': 'Pendente', 'cor': AppCores.corAtencao};
      case 'ACCEPTED':
        return {'texto': 'Aceito', 'cor': AppCores.corSucesso};
      case 'IN_PROGRESS':
        return {'texto': 'Em andamento', 'cor': AppCores.corPrimaria};
      case 'WAITING_PAYMENT':
        return {'texto': 'Aguardando pagamento', 'cor': AppCores.corAtencao};
      case 'REVISED':
        return {'texto': 'Em revisão', 'cor': AppCores.corAtencao};
      case 'FINISHED':
        return {'texto': 'Concluído', 'cor': AppCores.corSucesso};
      case 'CANCELLED':
        return {'texto': 'Cancelado', 'cor': AppCores.corErro};
      default:
        return {'texto': status, 'cor': Colors.grey};
    }
  }

  String _formatarData(String? raw) {
    if (raw == null) return '';
    try {
      return DateFormat("dd MMM yyyy", 'pt_BR').format(DateTime.parse(raw));
    } catch (_) {
      return raw.split('T')[0];
    }
  }

  // ── Ações de API ─────────────────────────────────────────────────────────

  Future<void> _aceitar() => _acaoSimples(
        Uri.parse('$_apiUrl/orders/${widget.order['id']}/accept'),
        body: {'artistId': UserSession.instance.id},
        metodo: 'POST',
      );

  Future<void> _recusar() => _acaoSimples(
        Uri.parse('$_apiUrl/orders/${widget.order['id']}/reject'),
        body: {'artistId': UserSession.instance.id},
        metodo: 'POST',
      );

  Future<void> _excluir() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppCores.corSecundaria,
        title: const Text('Excluir pedido',
            style: TextStyle(color: AppCores.corTexto)),
        content: const Text(
          'Tem certeza? Essa ação não pode ser desfeita.',
          style: TextStyle(color: AppCores.corTextoSecundario),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir',
                  style: TextStyle(color: AppCores.corErro))),
        ],
      ),
    );
    if (confirmar != true) return;
    await _acaoSimples(
      Uri.parse('$_apiUrl/orders/${widget.order['id']}'),
      metodo: 'DELETE',
    );
  }

  Future<void> _alterarStatus(String novoStatus) => _acaoSimples(
        Uri.parse('$_apiUrl/orders/${widget.order['id']}'),
        body: {'status': novoStatus},
        metodo: 'PUT',
      );

  Future<void> _acaoSimples(
    Uri uri, {
    Map<String, dynamic>? body,
    required String metodo,
  }) async {
    setState(() => _processando = true);
    try {
      final token = UserSession.instance.token;
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      http.Response response;
      switch (metodo) {
        case 'POST':
          response = await http.post(uri,
              headers: headers, body: jsonEncode(body ?? {}));
          break;
        case 'PUT':
          response = await http.put(uri,
              headers: headers, body: jsonEncode(body ?? {}));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          return;
      }

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        widget.onAtualizar();
      } else {
        final data = jsonDecode(response.body);
        _mostrarErro(data['error'] ?? 'Erro ao processar ação.');
      }
    } catch (_) {
      if (mounted) _mostrarErro('Não foi possível conectar ao servidor.');
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _abrirMenuStatus(BuildContext context) {
    const opcoes = [
      ('ACCEPTED', 'Aceito'),
      ('IN_PROGRESS', 'Em andamento'),
      ('WAITING_PAYMENT', 'Aguardando pagamento'),
      ('REVISED', 'Em revisão'),
      ('FINISHED', 'Concluído'),
      ('CANCELLED', 'Cancelado'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppCores.corSecundaria,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Alterar status',
              style: TextStyle(
                color: AppCores.corTexto,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1, color: AppCores.corBorda),
          ...opcoes.map((op) {
            final info = _infoStatus(op.$1);
            final isCurrent =
                widget.order['status'] == op.$1;
            return ListTile(
              leading: CircleAvatar(
                radius: 5,
                backgroundColor: info['cor'] as Color,
              ),
              title: Text(
                op.$2,
                style: TextStyle(
                  color: isCurrent
                      ? AppCores.corPrimaria
                      : AppCores.corTexto,
                  fontWeight:
                      isCurrent ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              trailing: isCurrent
                  ? const Icon(Icons.check,
                      size: 18, color: AppCores.corPrimaria)
                  : null,
              onTap: () {
                Navigator.pop(context);
                if (!isCurrent) _alterarStatus(op.$1);
              },
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final status = order['status'] as String? ?? 'PENDING';
    final info = _infoStatus(status);

    final clienteObj = order['client'] as Map<String, dynamic>?;
    final String clienteNome =
        (clienteObj?['name'] ?? clienteObj?['username'] ?? 'Cliente') as String;
    final String inicial =
        clienteNome.isNotEmpty ? clienteNome[0].toUpperCase() : 'C';

    final String descricao = order['description'] as String? ?? 'Sem descrição';
    final String data = _formatarData(order['createdAt'] as String?);

    final dynamic precoRaw = order['commissionSlot']?['price'];
    final String valor =
        precoRaw != null ? 'R\$ ${precoRaw.toString()}' : 'A combinar';

    final String? refImage = order['referenceImage'] as String?;
    final bool isPending = status == 'PENDING';

    return Container(
      decoration: BoxDecoration(
        color: AppCores.corFundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppCores.corBorda, width: 0.8),
        boxShadow: const [
          BoxShadow(
              color: AppCores.corSombra, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cabeçalho ──────────────────────────────────
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppCores.corPrimariaClara,
                      child: Text(
                        inicial,
                        style: const TextStyle(
                          color: AppCores.corPrimaria,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clienteNome,
                            style: const TextStyle(
                              color: AppCores.corTexto,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            data,
                            style: const TextStyle(
                              color: AppCores.corTextoClaro,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge status
                    Container(
                      margin: const EdgeInsets.only(right: 25),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            (info['cor'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        info['texto'] as String,
                        style: TextStyle(
                          color: info['cor'] as Color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppCores.corBorda),
                const SizedBox(height: 12),

                // ── Descrição ───────────────────────────────────
                Text(
                  descricao,
                  style: const TextStyle(
                    color: AppCores.corTexto,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                // ── Imagem de referência ────────────────────────
                if (refImage != null && refImage.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      refImage,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // ── Valor ───────────────────────────────────────
                Text(
                  valor,
                  style: const TextStyle(
                    color: AppCores.corPrimaria,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 14),

                // ── Ações ────────────────────────────────────────
                if (isPending) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              _processando ? null : _recusar,
                          icon: const Icon(Icons.close,
                              size: 16, color: AppCores.corErro),
                          label: const Text('Recusar',
                              style:
                                  TextStyle(color: AppCores.corErro)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppCores.corErro, width: 0.8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _processando ? null : _aceitar,
                          icon: const Icon(Icons.check,
                              size: 16, color: Colors.white),
                          label: const Text('Aceitar',
                              style:
                                  TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppCores.corSucesso,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (status != 'FINISHED' &&
                    status != 'CANCELLED') ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _processando
                          ? null
                          : () => _abrirMenuStatus(context),
                      icon: const Icon(Icons.swap_horiz,
                          size: 16, color: AppCores.corTextoSecundario),
                      label: const Text('Alterar status',
                          style: TextStyle(
                              color: AppCores.corTextoSecundario)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppCores.corBorda, width: 0.8),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Botão excluir (canto superior direito, fora do fluxo) ──
          Positioned(
            top: 10,
            right: 4,
            child: IconButton(
              tooltip: 'Excluir pedido',
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: AppCores.corErro),
              onPressed: _processando ? null : _excluir,
            ),
          ),

          // ── Overlay de loading ──────────────────────────────────────
          if (_processando)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppCores.corFundoCard.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                      color: AppCores.corPrimaria, strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Widget de erro ───────────────────────────────────────────────────────────

class _ErroWidget extends StatelessWidget {
  final String mensagem;
  final VoidCallback onRetry;

  const _ErroWidget({required this.mensagem, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off,
                size: 56, color: AppCores.corTextoClaro),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppCores.corTextoSecundario),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
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
}