import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../core/app_cores.dart';
import 'userSection.dart';
import '../service/event_service.dart';
import 'dart:async';

class TelaPedidos extends StatefulWidget {
  const TelaPedidos({super.key});

  @override
  State<TelaPedidos> createState() => _TelaPedidosState();
}

class _TelaPedidosState extends State<TelaPedidos>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _apiUrl = 'http://10.0.2.2:3000';
  StreamSubscription? _eventoSub;

  List<dynamic> _todosPedidos = [];
  bool _carregando = true;
  String? _erroMensagem;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _buscarPedidosDoCliente();
    _escutarEventos();
  }

  void _escutarEventos() {
    final userId = UserSession.instance.id;
    if (userId == null) return;

    _eventoSub = EventService.instance
        .connect(userId)
        .listen((evento) {
          
      if (evento['type'] == 'ORDER_UPDATE') {
        _buscarPedidosDoCliente();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _eventoSub?.cancel();
    super.dispose();
  }

  Future<void> _buscarPedidosDoCliente() async {
    // ← pega o id da sessão em vez de hardcoded
    final clientId = UserSession.instance.id;
    if (clientId == null) {
      setState(() {
        _erroMensagem = 'Sessão expirada. Faça login novamente.';
        _carregando = false;
      });
      return;
    }

    try {
      setState(() {
        _carregando = true;
        _erroMensagem = null;
      });

      final url = Uri.parse('$_apiUrl/orders/client/$clientId');
      final token = UserSession.instance.token;
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        setState(() {
          _todosPedidos = dados;
          _carregando = false;
        });
      } else {
        setState(() {
          _erroMensagem = 'Não foi possível carregar seus pedidos.';
          _carregando = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroMensagem = 'Erro de conexão com o servidor.';
        _carregando = false;
      });
    }
  }

  List<dynamic> _filtrarPedidos(String statusTipo) {
    if (statusTipo == 'andamento') {
      return _todosPedidos.where((p) {
        final status = p['status'] as String? ?? 'PENDING';
        return status == 'PENDING' ||
            status == 'ACCEPTED' ||
            status == 'IN_PROGRESS' ||
            status == 'WAITING_PAYMENT';
      }).toList();
    } else if (statusTipo == 'concluido') {
      return _todosPedidos.where((p) {
        return (p['status'] as String? ?? '') == 'FINISHED';
      }).toList();
    }
    return _todosPedidos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.corFundo,
      appBar: AppBar(
        backgroundColor: AppCores.corSecundaria,
        title: const Text('Meus Pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _buscarPedidosDoCliente,
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
            Tab(text: 'Em andamento'),
            Tab(text: 'Concluídos'),
          ],
        ),
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: AppCores.corPrimaria),
            )
          : _erroMensagem != null
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _ListaPedidos(pedidos: _filtrarPedidos('todos')),
                    _ListaPedidos(pedidos: _filtrarPedidos('andamento')),
                    _ListaPedidos(pedidos: _filtrarPedidos('concluido')),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppCores.corErro),
            const SizedBox(height: 16),
            Text(
              _erroMensagem!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppCores.corTextoSecundario),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _buscarPedidosDoCliente,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaPedidos extends StatelessWidget {
  final List<dynamic> pedidos;
  const _ListaPedidos({required this.pedidos});

  @override
  Widget build(BuildContext context) {
    if (pedidos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppCores.corTextoSecundario),
            SizedBox(height: 16),
            Text(
              'Nenhum pedido aqui',
              style: TextStyle(
                color: AppCores.corTextoSecundario,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pedidos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _CardPedido(pedido: pedidos[i]),
    );
  }
}

class _CardPedido extends StatelessWidget {
  final Map<String, dynamic> pedido;
  const _CardPedido({required this.pedido});

  Map<String, dynamic> _obterInfoStatus(String status) {
    switch (status) {
      case 'PENDING':
        return {'texto': 'Pendente', 'cor': AppCores.corAtencao, 'mostrarBotao': true};
      case 'ACCEPTED':
        return {'texto': 'Aceito', 'cor': AppCores.corAtencao, 'mostrarBotao': true};
      case 'IN_PROGRESS':
        return {'texto': 'Em Andamento', 'cor': AppCores.corAtencao, 'mostrarBotao': true};
      case 'WAITING_PAYMENT':
        return {'texto': 'Aguardando Pagamento', 'cor': AppCores.corAtencao, 'mostrarBotao': true};
      case 'FINISHED':
        return {'texto': 'Concluído', 'cor': AppCores.corSucesso, 'mostrarBotao': false};
      case 'CANCELLED':
        return {'texto': 'Cancelado', 'cor': AppCores.corErro, 'mostrarBotao': false};
      default:
        return {'texto': status, 'cor': Colors.grey, 'mostrarBotao': false};
    }
  }

  String _formatarData(String? dataRaw) {
    if (dataRaw == null) return '';
    try {
      final data = DateTime.parse(dataRaw);
      return DateFormat("dd MMM yyyy", 'pt_BR').format(data);
    } catch (_) {
      return dataRaw.split('T')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusOriginal = pedido['status'] as String? ?? 'PENDING';
    final infoStatus = _obterInfoStatus(statusOriginal);

    // o backend retorna artist.name (campo do Prisma), mas o userService
    // mapeia name → username, então o JSON do include pode vir como 'name'
    final artistaObj = pedido['artist'] as Map<String, dynamic>?;
    final String artistaNome =
        (artistaObj?['name'] ?? artistaObj?['username'] ?? 'Artista') as String;

    final String descricao = pedido['description'] as String? ?? 'Sem descrição';
    final String dataFormatada = _formatarData(pedido['createdAt'] as String?);

    final dynamic precoRaw = pedido['commissionSlot']?['price'];
    final String valorFormatado = precoRaw != null
        ? 'R\$ ${precoRaw.toString()}'
        : 'Valor sob consulta';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppCores.corFundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppCores.corBorda, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppCores.corSombra,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppCores.corDestaque,
                    child: Text(
                      artistaNome.isNotEmpty ? artistaNome[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        color: AppCores.corPrimaria,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    artistaNome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppCores.corTexto,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (infoStatus['cor'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  infoStatus['texto'] as String,
                  style: TextStyle(
                    color: infoStatus['cor'] as Color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppCores.corDivisor),
          const SizedBox(height: 10),
          Text(
            descricao,
            style: const TextStyle(
              color: AppCores.corTexto,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                valorFormatado,
                style: const TextStyle(
                  color: AppCores.corPrimaria,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                dataFormatada,
                style: const TextStyle(
                  color: AppCores.corTextoClaro,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          
        ],
      ),
    );
  }
}