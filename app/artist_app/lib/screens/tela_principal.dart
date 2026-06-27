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

  List<Widget> get _telas {
    return [
      const TelaHome(),
      const TelaExplorar(),
      if (!UserSession.instance.isArtist)const TelaPedidos(),
      if (UserSession.instance.isArtist) const TelaOrdersArtista(),
      if (UserSession.instance.isArtist) const TelaCommissions(),
    ];
  }

  List<BottomNavigationBarItem> get _itensNav {
    return [
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
      if(!UserSession.instance.isArtist)
      const BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long_outlined),
        activeIcon: Icon(Icons.receipt_long_rounded),
        label: 'Pedidos',
      ),
      if(UserSession.instance.isArtist)
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long_rounded),
          label: 'Pedidos_Artista',
        ),
      if (UserSession.instance.isArtist)
        const BottomNavigationBarItem(
          icon: Icon(Icons.draw_outlined),
          activeIcon: Icon(Icons.draw),
          label: 'Commissions',
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {

    final telas = _telas;

    return Scaffold(
      body: IndexedStack(
        index: _indiceSelecionado,
        children: _telas,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppCores.corBorda, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceSelecionado,
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
