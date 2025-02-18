// Importa a biblioteca flutter/material.dart para construir a interface de utilizador.
import 'package:flutter/material.dart';
// Importa o serviço de autenticação personalizado.
import 'package:mediador_seguros_app/services/auth_service.dart';
// Importa o ecrã de registo de clientes.
import 'package:mediador_seguros_app/screens/register/register_client_screen.dart';
// Importa o ecrã de registo de mediadores.
import 'package:mediador_seguros_app/screens/register/register_mediador_screen.dart';
// Importa o ecrã principal (HomeScreen).
import 'package:mediador_seguros_app/screens/home/home_screen.dart';

/// Classe que representa o ecrã de login, estendendo um [StatefulWidget].
class LoginScreen extends StatefulWidget {
  /// Construtor padrão que recebe [super.key].
  const LoginScreen({super.key});

  /// Cria o estado para o ecrã de Login.
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Classe que gere o estado do [LoginScreen].
class _LoginScreenState extends State<LoginScreen> {
  // Instancia o serviço de autenticação.
  final AuthService _authService = AuthService();
  // Controlador para o campo de texto do email.
  final TextEditingController _emailController = TextEditingController();
  // Controlador para o campo de texto da senha.
  final TextEditingController _passController = TextEditingController();
  // Indicador de estado de carregamento (útil enquanto faz login).
  bool _loading = false;

  // Chave global para o formulário, utilizada na validação dos campos.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Método que limpa os controladores quando o widget é removido da árvore de widgets.
  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  /// Método assíncrono para efetuar o login no sistema.
  /// Primeiro valida o formulário, depois chama o serviço de autenticação.
  Future<void> _login() async {
    // Verifica se os campos do formulário estão válidos.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Ativa o estado de carregamento.
    setState(() {
      _loading = true;
    });

    try {
      // Tenta fazer login com as credenciais inseridas.
      final user = await _authService.signIn(
        _emailController.text.trim(),
        _passController.text.trim(),
      );

      // Se o login tiver sucesso (user != null), redireciona para a HomeScreen.
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      // Em caso de erro, mostra uma mensagem de erro dentro de um SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0),
        ),
      );
    }

    // Desativa o estado de carregamento.
    setState(() {
      _loading = false;
    });
  }

  /// Método que constrói o widget principal do ecrã de login.
  @override
  Widget build(BuildContext context) {
    // Retorna um Scaffold para a estrutura da página.
    return Scaffold(
      // Remove o AppBar padrão para usar um cabeçalho personalizado (gradient, imagem, etc.).
      body: Container(
        // Decoração que define um gradiente de cor para o fundo do ecrã.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // Centra o conteúdo do ecrã.
        child: Center(
          // SingleChildScrollView para permitir rolagem caso o conteúdo seja maior que a tela.
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            // Coluna que organiza o conteúdo verticalmente.
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Imagem (ilustração de login).
                Image.asset(
                  'assets/images/login_illustration.png',
                  height: 150,
                ),
                const SizedBox(height: 16),
                // Título de boas-vindas.
                Text(
                  'Bem-vindo de Volta!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                // Subtítulo.
                Text(
                  'Faça login para continuar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                // Card que contém o formulário de login.
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  // Usa uma cor branca translúcida para deixar o fundo levemente transparente.
                  color: Colors.white.withOpacity(0.85),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    // Form que utiliza a _formKey para validações.
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Campo de texto para o Email.
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.blueAccent.withOpacity(0.7),
                              ),
                              hintText: 'Digite seu email',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              // Validação para verificar se o campo está vazio ou não contém '@'.
                              if (value == null ||
                                  value.isEmpty ||
                                  !value.contains('@')) {
                                return 'Por favor, insira um email válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Campo de texto para a Senha.
                          TextFormField(
                            controller: _passController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.blueAccent.withOpacity(0.7),
                              ),
                              hintText: 'Digite sua senha',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            // obscureText para ocultar a senha enquanto o utilizador digita.
                            obscureText: true,
                            validator: (value) {
                              // Validação para verificar tamanho mínimo de 6 caracteres.
                              if (value == null ||
                                  value.isEmpty ||
                                  value.length < 6) {
                                return 'Senha deve ter pelo menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          // Botão de login ou indicador de carregamento, consoante o estado _loading.
                          _loading
                              ? const CircularProgressIndicator()
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 16),
                          // Secção que apresenta links de registo (Criar Conta Cliente / Criar Conta Mediador).
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Não tem uma conta?',
                                style: TextStyle(color: Colors.black54),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navega para o ecrã de registo de cliente.
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const RegisterClientScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Criar Conta Cliente',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Ou ',
                                style: TextStyle(color: Colors.black54),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navega para o ecrã de registo de mediador.
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const RegisterMediadorScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Criar Conta Mediador',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Rodapé opcional com copyright ou outra informação.
                Text(
                  '© 2024 Mediador Seguros. Todos os direitos reservados.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Trabalho realizado por:
// -> Miguel Magalhães;
// -> Nº:2021103166;
// -> Unidade Curricular de Computação Móvel;
// -> Licenciatura em Engenharia informática;
// -> ISPGAYA
