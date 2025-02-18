// Importa a biblioteca flutter/material.dart para construir interfaces gráficas.
import 'package:flutter/material.dart';
// Importa o serviço de autenticação personalizado.
import 'package:mediador_seguros_app/services/auth_service.dart';
// Importa a HomeScreen para onde o mediador será redirecionado após registo.
import 'package:mediador_seguros_app/screens/home/home_screen.dart';

// Classe que representa o ecrã de registo para mediadores.
class RegisterMediadorScreen extends StatefulWidget {
  // Construtor padrão, que aceita uma chave opcional.
  const RegisterMediadorScreen({super.key});

  // Cria o estado deste ecrã (RegisterMediadorScreen).
  @override
  State<RegisterMediadorScreen> createState() => _RegisterMediadorScreenState();
}

// Classe que mantém o estado de RegisterMediadorScreen.
class _RegisterMediadorScreenState extends State<RegisterMediadorScreen> {
  // Instancia o serviço de autenticação.
  final _authService = AuthService();
  // Controlador de texto para o campo de email.
  final _emailController = TextEditingController();
  // Controlador de texto para o campo de palavra-passe (password).
  final _passController = TextEditingController();
  // Variável para indicar se estamos num processo de carregamento.
  bool _loading = false;

  // Método chamado quando o widget é removido da árvore de widgets,
  // libertando os recursos dos controladores de texto.
  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // Método assíncrono que tenta registar o mediador através do serviço de autenticação.
  Future<void> _register() async {
    // Define _loading para true, indicando que uma acção está em progresso.
    setState(() {
      _loading = true;
    });
    try {
      // Tenta registar o mediador utilizando o email e a password fornecidos.
      final user = await _authService.registerMediador(
        _emailController.text.trim(),
        _passController.text.trim(),
      );
      // Se o registo for bem-sucedido, redireciona para a HomeScreen.
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      // Se ocorrer um erro, mostra uma mensagem com o erro.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    // Define _loading para false, indicando que a acção terminou.
    setState(() {
      _loading = false;
    });
  }

  // Método que constrói (build) o widget principal deste ecrã.
  @override
  Widget build(BuildContext context) {
    // Retorna um Scaffold para estruturar a interface de utilizador.
    return Scaffold(
      // AppBar com o título "Registrar Mediador".
      appBar: AppBar(
        title: const Text('Registrar Mediador'),
      ),
      // Corpo do ecrã.
      body: Padding(
        // Espaçamento em todos os lados.
        padding: const EdgeInsets.all(16.0),
        // Coluna que dispõe os widgets verticalmente.
        child: Column(
          children: [
            // Campo de texto para o email.
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            // Campo de texto para a password.
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'Password'),
              // obscureText true para ocultar a password enquanto se digita.
              obscureText: true,
            ),
            const SizedBox(height: 20),
            // Se _loading for verdadeiro, mostra um CircularProgressIndicator,
            // caso contrário, mostra um ElevatedButton para registar o mediador.
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text('Registrar'),
                  ),
          ],
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
