import 'package:flutter/material.dart';
import 'screens/tela_login.dart';
import 'screens/tela_principal.dart';
import 'screens/userSection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final loggedIn = await UserSession.instance.load();

  runApp(MyApp(startLoggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool startLoggedIn;
  const MyApp({super.key, required this.startLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: startLoggedIn ? const TelaPrincipal() : const TelaLogin(),
    );
  }
}