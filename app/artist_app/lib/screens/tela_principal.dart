import 'package:flutter/material.dart';
import '../core/app_cores.dart';
import 'tela_home.dart';
import 'tela_explorar.dart';
import 'tela_pedidos.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _indiceSelecionado = 0;

  final _telas = const [
    TelaHome(),
    TelaExplorar(),
    TelaPedidos(),
  ];

  @override
  Widget build(BuildContext context) {
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore_rounded),
              label: 'Explorar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Pedidos',
            ),
          ],
        ),
      ),
    );
  }
}
