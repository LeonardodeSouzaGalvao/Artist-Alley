import 'package:flutter/material.dart';
import 'core/app_tema.dart';
import 'screens/tela_login.dart';

void main() {
  runApp(const ArtistAlleyApp());
}

class ArtistAlleyApp extends StatelessWidget {
  const ArtistAlleyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtistAlley',
      debugShowCheckedModeBanner: false,
      theme: AppTema.tema,
      home: const TelaLogin(),
    );
  }
}
