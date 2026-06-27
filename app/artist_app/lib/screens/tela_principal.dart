import 'package:flutter/material.dart';
import '../core/app_cores.dart';
import 'tela_home.dart';
import 'tela_explorar.dart';
import 'tela_pedidos.dart';
import 'userSection.dart';
import 'tela_commission.dart';
import 'tela_order_artista.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _indiceSelecionado = 0;

  // Calculado uma única vez por build e reutilizado
  late List<Widget> _telas;
  late List<BottomNavigationBarItem> _itensNav;

  @override
  void initState() {
    super.initState();
    _recalcularNavegacao();
  }

  void _recalcularNavegacao() {
    final isArtist = UserSession.instance.isArtist;

    _telas = [
      const TelaHome(),
      const TelaExplorar(),
      if (!isArtist) const TelaPedidos(),
      if (isArtist) const TelaOrdersArtista(),
      if (isArtist) const TelaCommissions(),
    ];

    _itensNav = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: 'Início',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.explore_outlined),
        activeIcon: Icon(Icons.explore_rounded),
        label: 'Explorar',
      ),
      if (!isArtist)
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long_rounded),
          label: 'Pedidos',
        ),
      if (isArtist)
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long_rounded),
          label: 'Pedidos',
        ),
      if (isArtist)
        const BottomNavigationBarItem(
          icon: Icon(Icons.draw_outlined),
          activeIcon: Icon(Icons.draw),
          label: 'Commissions',
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Garante que o índice nunca ultrapasse o tamanho da lista
    final indiceSeguro = _indiceSelecionado.clamp(0, _telas.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: indiceSeguro,
        children: _telas,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppCores.corBorda, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: indiceSeguro,
          onTap: (i) => setState(() => _indiceSelecionado = i),
          backgroundColor: AppCores.corSecundaria,
          selectedItemColor: AppCores.corPrimaria,
          unselectedItemColor: AppCores.corTextoClaro,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: _itensNav,
        ),
      ),
    );
  }
}
