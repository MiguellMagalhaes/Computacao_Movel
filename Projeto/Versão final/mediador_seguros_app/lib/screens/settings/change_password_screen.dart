// lib/screens/settings/change_password_screen.dart

// Importações necessárias para a utilização de widgets e funcionalidades do Flutter.
import 'package:flutter/material.dart';
// Importação da biblioteca do Firebase para autenticação de utilizadores.
import 'package:firebase_auth/firebase_auth.dart';

// Classe que representa a tela (screen) para alterar a senha (password) do utilizador.
class ChangePasswordScreen extends StatefulWidget {
  // Construtor padrão, com chave opcional.
  const ChangePasswordScreen({super.key});

  // Cria o estado associado a este widget.
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

// Classe que mantém o estado de [ChangePasswordScreen].
class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Instância do FirebaseAuth para gerir a autenticação.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controladores de texto para recolher a senha atual, a nova senha e a confirmação da nova senha.
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // Chave global do formulário para validações.
  final _formKey = GlobalKey<FormState>();

  // Indica se está a decorrer uma operação de carregamento (por exemplo, alterar a senha).
  bool _loading = false;

  // Método assíncrono para alterar a senha do utilizador.
  Future<void> _changePassword() async {
    // Primeiro, valida o formulário. Se estiver inválido, não prossegue.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Obtém o utilizador atual através do FirebaseAuth.
    final user = _auth.currentUser;
    // Se não existir utilizador autenticado, mostra uma mensagem de erro e sai.
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.')),
      );
      return;
    }

    // Define o estado para carregamento.
    setState(() {
      _loading = true;
    });

    try {
      // Cria as credenciais com o email do utilizador atual e a senha atual digitada.
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPassController.text.trim(),
      );

      // Reautentica o utilizador para garantir que a senha atual está correta.
      await user.reauthenticateWithCredential(cred);

      // Atualiza a senha do utilizador para a nova senha digitada.
      await user.updatePassword(_newPassController.text.trim());

      // Mostra uma mensagem de sucesso.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso.')),
      );

      // Volta ao ecrã anterior.
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Se ocorrer uma exceção do FirebaseAuth, mostra uma mensagem adaptada ao tipo de erro.
      String message = 'Erro ao alterar senha.';
      if (e.code == 'wrong-password') {
        message = 'Senha atual incorreta.';
      } else if (e.code == 'weak-password') {
        message = 'Senha muito fraca.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Se for outro tipo de erro, mostra uma mensagem de erro desconhecido.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro desconhecido.')),
      );
    }

    // Desativa o estado de carregamento.
    setState(() {
      _loading = false;
    });
  }

  // Método chamado quando este widget é removido da árvore de widgets,
  // libertando os recursos dos controladores de texto.
  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // Método principal de construção do widget, que retorna a interface de utilizador.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar com o título "Alterar Senha".
      appBar: AppBar(
        title: const Text('Alterar Senha'),
        // Define a cor de fundo de acordo com o tema atual, se existir.
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      // Padding para espaçar o conteúdo interior.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Form que utiliza a chave _formKey para validação.
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo de texto para a senha atual.
              TextFormField(
                controller: _currentPassController,
                decoration: const InputDecoration(
                  labelText: 'Senha Atual',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                // Validação para verificar se o campo não está vazio.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha atual.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo de texto para a nova senha.
              TextFormField(
                controller: _newPassController,
                decoration: const InputDecoration(
                  labelText: 'Nova Senha',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                // Validação para verificar se a nova senha não está vazia e tem pelo menos 6 caracteres.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma nova senha.';
                  }
                  if (value.length < 6) {
                    return 'A nova senha deve ter pelo menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Campo de texto para confirmar a nova senha.
              TextFormField(
                controller: _confirmPassController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Nova Senha',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                // Validação para garantir que a confirmação coincide com a nova senha.
                validator: (value) {
                  if (value != _newPassController.text) {
                    return 'As senhas não coincidem.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Botão para efetuar a alteração da senha ou indicador de carregamento.
              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Alterar Senha',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ],
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
