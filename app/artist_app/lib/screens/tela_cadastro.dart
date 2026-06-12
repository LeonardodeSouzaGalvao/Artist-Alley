import 'package:flutter/material.dart';
import '../core/app_cores.dart';
import 'tela_principal.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;
  bool _carregando = false;

  // null = nenhum selecionado, 'artista' ou 'cliente'
  String? _tipoUsuario;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.corPrimaria,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppCores.corTextoBranco),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Criar conta',
                style: TextStyle(
                  color: AppCores.corTextoBranco,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),

              // Card do formulário
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppCores.corSecundaria,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: AppCores.corSombra,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Tipo de usuário ──────────────────────────
                      const Text(
                        'Você é...',
                        style: TextStyle(
                          color: AppCores.corTexto,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _BotaoTipoUsuario(
                              label: 'Artista',
                              descricao: 'Ofereço serviços',
                              icone: Icons.palette_outlined,
                              selecionado: _tipoUsuario == 'artista',
                              onTap: () => setState(() => _tipoUsuario = 'artista'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _BotaoTipoUsuario(
                              label: 'Cliente',
                              descricao: 'Busco serviços',
                              icone: Icons.person_search_outlined,
                              selecionado: _tipoUsuario == 'cliente',
                              onTap: () => setState(() => _tipoUsuario = 'cliente'),
                            ),
                          ),
                        ],
                      ),

                      const Divider(color: AppCores.corDivisor),
                      const SizedBox(height: 15),

                      // ── Email ────────────────────────────────────
                      const Text(
                        'Email',
                        style: TextStyle(
                          color: AppCores.corTexto,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'seu@email.com',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppCores.corTextoSecundario,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe o email';
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // ── Senha ────────────────────────────────────
                      const Text(
                        'Senha',
                        style: TextStyle(
                          color: AppCores.corTexto,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: !_senhaVisivel,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(
                            Icons.lock_outlined,
                            color: AppCores.corTextoSecundario,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _senhaVisivel
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppCores.corTextoSecundario,
                            ),
                            onPressed: () =>
                                setState(() => _senhaVisivel = !_senhaVisivel),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe a senha';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // ── Confirmar senha ──────────────────────────
                      const Text(
                        'Confirmar senha',
                        style: TextStyle(
                          color: AppCores.corTexto,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmarSenhaController,
                        obscureText: !_confirmarSenhaVisivel,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(
                            Icons.lock_outlined,
                            color: AppCores.corTextoSecundario,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmarSenhaVisivel
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppCores.corTextoSecundario,
                            ),
                            onPressed: () => setState(
                                () => _confirmarSenhaVisivel = !_confirmarSenhaVisivel),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirme a senha';
                          if (v != _senhaController.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      // ── Botão cadastrar ──────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _carregando ? null : _cadastrar,
                          child: _carregando
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: AppCores.corTextoBranco,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text('Criar conta'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Já tem conta?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Já tem uma conta? ',
                    style: TextStyle(
                      color: AppCores.corTextoBranco.withOpacity(0.85),
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        color: AppCores.corTextoBranco,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: AppCores.corTextoBranco,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget do botão de seleção de tipo
class _BotaoTipoUsuario extends StatelessWidget {
  final String label;
  final String descricao;
  final IconData icone;
  final bool selecionado;
  final VoidCallback onTap;

  const _BotaoTipoUsuario({
    required this.label,
    required this.descricao,
    required this.icone,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: selecionado ? AppCores.corDestaque : AppCores.corSecundariaEscura,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionado ? AppCores.corPrimaria : AppCores.corBorda,
            width: selecionado ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icone,
              size: 32,
              color: selecionado ? AppCores.corPrimaria : AppCores.corTextoSecundario,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: selecionado ? AppCores.corPrimaria : AppCores.corTexto,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              descricao,
              style: TextStyle(
                fontSize: 11,
                color: selecionado
                    ? AppCores.corPrimaria.withOpacity(0.7)
                    : AppCores.corTextoClaro,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
