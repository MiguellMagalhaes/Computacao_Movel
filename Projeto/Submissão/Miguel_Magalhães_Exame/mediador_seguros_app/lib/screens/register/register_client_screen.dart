// Importa a biblioteca flutter/material.dart para criar a interface de utilizador.
import 'package:flutter/material.dart';
// Importa o serviço de autenticação personalizado.
import 'package:mediador_seguros_app/services/auth_service.dart';
// Importa a HomeScreen, para onde o utilizador será redirecionado após o registo com sucesso.
import 'package:mediador_seguros_app/screens/home/home_screen.dart';

/// Classe que representa o ecrã para registar um novo utilizador com o papel "Cliente".
class RegisterClientScreen extends StatefulWidget {
  /// Construtor padrão, sem parâmetros adicionais, além de super.key.
  const RegisterClientScreen({super.key});

  /// Cria o estado correspondente ao [RegisterClientScreen].
  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

/// Classe que gere o estado do [RegisterClientScreen].
class _RegisterClientScreenState extends State<RegisterClientScreen> {
  // Instancia o serviço de autenticação personalizado.
  final _authService = AuthService();
  // Controlador para o campo de texto do email.
  final _emailController = TextEditingController();
  // Controlador para o campo de texto da palavra-passe (senha).
  final _passController = TextEditingController();
  // Indicador de estado de carregamento (por exemplo, durante o registo).
  bool _loading = false;

  // Chave global para validar o formulário.
  final _formKey = GlobalKey<FormState>();

  /// Método chamado quando o widget deixa de existir,
  /// libertando os recursos dos controladores de texto.
  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  /// Método assíncrono para efetuar o registo do utilizador na aplicação.
  /// Caso o formulário seja válido, chama o método [registerClient] do serviço de autenticação.
  Future<void> _register() async {
    // Verifica se o formulário está válido de acordo com as regras de validação.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Activa o estado de carregamento para indicar ao utilizador que algo está a ser processado.
    setState(() {
      _loading = true;
    });

    try {
      // Tenta registar o utilizador (cliente) com os dados inseridos.
      final user = await _authService.registerClient(
        _emailController.text.trim(),
        _passController.text.trim(),
      );
      // Se o registo tiver sucesso, redireciona o utilizador para a HomeScreen.
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      // Caso ocorra algum erro, apresenta uma mensagem com o texto do erro.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: $e')));
    }

    // Desactiva o estado de carregamento.
    setState(() {
      _loading = false;
    });
  }

  /// Método que constrói o widget principal do ecrã de registo de clientes.
  @override
  Widget build(BuildContext context) {
    // Retorna um Scaffold para estruturar o ecrã.
    return Scaffold(
      // Define a cor de fundo do ecrã.
      backgroundColor: Colors.grey[200],
      // Barra de aplicação (AppBar) com o título "Registrar Cliente".
      appBar: AppBar(
        title: const Text('Registrar Cliente'),
        backgroundColor: Colors.blueAccent,
      ),
      // Corpo do ecrã, centrado e com possibilidade de scroll.
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          // Card para dar destaque ao formulário.
          child: Card(
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              // Form que utiliza a _formKey para validações.
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícone ilustrativo no topo do formulário.
                    const Icon(
                      Icons.person_add,
                      size: 80,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16),
                    // Campo de texto para o email.
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      // Validação básica para garantir que o texto introduzido é um email válido.
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'Por favor, insira um email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Campo de texto para a palavra-passe (senha).
                    TextFormField(
                      controller: _passController,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      // obscureText para esconder o texto introduzido (password).
                      obscureText: true,
                      // Validação para garantir que a palavra-passe tem pelo menos 6 caracteres.
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 6) {
                          return 'Senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Botão para efetuar o registo ou indicador de carregamento, consoante o estado _loading.
                    _loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _register,
                              icon: const Icon(Icons.person_add_alt_1),
                              label: const Text('Registrar'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
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
