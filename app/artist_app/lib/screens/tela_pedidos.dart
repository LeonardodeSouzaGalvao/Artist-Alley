import 'package:flutter/material.dart';
import '../core/app_cores.dart';

class TelaPedidos extends StatefulWidget {
  const TelaPedidos({super.key});

  @override
  State<TelaPedidos> createState() => _TelaPedidosState();
}

class _TelaPedidosState extends State<TelaPedidos>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final _pedidos = [
    {
      'artista': 'Ana Costa',
      'descricao': 'Ilustração digital – personagem principal do jogo',
      'valor': 'R\$ 350,00',
      'status': 'Em andamento',
      'corStatus': AppCores.corAtencao,
      'data': '05 jun 2026',
    },
    {
      'artista': 'Bruno Melo',
      'descricao': 'Arte conceitual – 3 cenários de fantasia',
      'valor': 'R\$ 780,00',
      'status': 'Concluído',
      'corStatus': AppCores.corSucesso,
      'data': '28 mai 2026',
    },
    {
      'artista': 'Carla Dias',
      'descricao': 'Retrato digital realista',
      'valor': 'R\$ 200,00',
      'status': 'Concluído',
      'corStatus': AppCores.corSucesso,
      'data': '14 mai 2026',
    },
    {
      'artista': 'Diego Lima',
      'descricao': 'Sprites pixel art para plataforma',
      'valor': 'R\$ 420,00',
      'status': 'Cancelado',
      'corStatus': AppCores.corErro,
      'data': '02 mai 2026',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.corFundo,
      appBar: AppBar(
        backgroundColor: AppCores.corSecundaria,
        title: const Text('Meus Pedidos'),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _ListaPedidos(pedidos: _pedidos),
          _ListaPedidos(
            pedidos: _pedidos.where((p) => p['status'] == 'Em andamento').toList(),
          ),
          _ListaPedidos(
            pedidos: _pedidos.where((p) => p['status'] == 'Concluído').toList(),
          ),
        ],
      ),
    );
  }
}

class _ListaPedidos extends StatelessWidget {
  final List<Map<String, dynamic>> pedidos;
  const _ListaPedidos({required this.pedidos});

  @override
  Widget build(BuildContext context) {
    if (pedidos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppCores.corTextoClaro),
            SizedBox(height: 16),
            Text(
              'Nenhum pedido aqui',
              style: TextStyle(color: AppCores.corTextoSecundario, fontSize: 16),
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

  @override
  Widget build(BuildContext context) {
    final corStatus = pedido['corStatus'] as Color;

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
          // Cabeçalho: artista + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppCores.corDestaque,
                    child: Text(
                      (pedido['artista'] as String)[0],
                      style: const TextStyle(
                        color: AppCores.corPrimaria,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    pedido['artista'] as String,
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
                  color: corStatus.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pedido['status'] as String,
                  style: TextStyle(
                    color: corStatus,
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

          // Descrição
          Text(
            pedido['descricao'] as String,
            style: const TextStyle(
              color: AppCores.corTexto,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 10),

          // Valor e data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pedido['valor'] as String,
                style: const TextStyle(
                  color: AppCores.corPrimaria,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                pedido['data'] as String,
                style: const TextStyle(
                  color: AppCores.corTextoClaro,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          // Botão de ação (só aparece se estiver em andamento)
          if (pedido['status'] == 'Em andamento') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 14),
                ),
                child: const Text('Ver andamento'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
