// lib/screens/settings/personal_info_screen.dart

// Importações necessárias para criar a interface de utilizador com Flutter,
// e para interagir com a autenticação do Firebase.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Ecrã (screen) para exibir e alterar algumas informações pessoais do utilizador.
/// Neste exemplo, o nome não é persistido (apenas campo de texto local),
/// enquanto a senha pode ser efectivamente alterada no Firebase.
class PersonalInfoScreen extends StatefulWidget {
  // Construtor padrão, com chave opcional.
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

/// Classe que mantém o estado de [PersonalInfoScreen].
class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  // Instância de FirebaseAuth para gerir o utilizador actual.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controladores de texto para os campos de nome e senhas.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // Indica se estamos num processo de carregamento (por exemplo, ao alterar a senha).
  bool _loading = false;

  // Método chamado quando o widget é removido da árvore de widgets.
  // Liberta os recursos dos controladores de texto para evitar fugas de memória.
  @override
  void dispose() {
    _nameController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  /// Método assíncrono para salvar as alterações introduzidas pelo utilizador.
  /// Aqui, apenas a alteração de senha é efectivamente persistida no Firebase.
  Future<void> _saveChanges() async {
    // Se os campos de senha estiverem vazios, assume que não se quer alterar a senha
    // e simplesmente sai (voltando ao ecrã anterior).
    if (_currentPassController.text.isEmpty &&
        _newPassController.text.isEmpty &&
        _confirmPassController.text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    // Verifica se a nova senha coincide com a confirmação.
    if (_newPassController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }
    // Verifica se a nova senha tem pelo menos 6 caracteres (caso não esteja vazia).
    if (_newPassController.text.length < 6 &&
        _newPassController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nova senha deve ter pelo menos 6 caracteres.')),
      );
      return;
    }

    // Define o estado para carregamento (para mostrar indicador de progresso).
    setState(() {
      _loading = true;
    });

    // Obtém o utilizador actual do FirebaseAuth.
    final user = _auth.currentUser;
    // Caso não exista utilizador autenticado, não prossegue.
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.')),
      );
      setState(() {
        _loading = false;
      });
      return;
    }

    // Tenta reautenticar o utilizador com a sua senha actual (necessário para alterar a senha).
    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPassController.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      // Se a senha actual estiver errada ou ocorrer outro erro do Firebase, mostra uma mensagem.
      if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha atual incorreta.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na reautenticação: ${e.code}')),
        );
      }
      setState(() {
        _loading = false;
      });
      return;
    }

    // Se o campo de nova senha não estiver vazio, tenta alterar a senha no FirebaseAuth.
    if (_newPassController.text.isNotEmpty) {
      try {
        await user.updatePassword(_newPassController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada com sucesso.')),
        );
      } on FirebaseAuthException catch (e) {
        // Em caso de erro na alteração de senha, mostra a mensagem correspondente.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao alterar senha: ${e.code}')),
        );
      }
    } else {
      // Se não digitou nova senha, mostra uma notificação que nada foi alterado.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma senha nova inserida.')),
      );
    }

    // Desativa o estado de carregamento.
    setState(() {
      _loading = false;
    });
    // Retorna ao ecrã anterior.
    Navigator.pop(context);
  }

  /// Método principal de construção do widget (ecrã).
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra de topo (AppBar) com título "Informações Pessoais".
      appBar: AppBar(
        title: const Text('Informações Pessoais'),
        // Define a cor de fundo consoante o tema actual, se existir.
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      // SingleChildScrollView para permitir rolagem caso o conteúdo exceda o tamanho do ecrã.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar fictício (imagem padrão).
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  const AssetImage('assets/images/default_avatar.png'),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 16),

            // Campo de texto para o nome do utilizador (não persistido no Firebase).
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Campo de texto para a senha actual.
            TextField(
              controller: _currentPassController,
              decoration: const InputDecoration(
                labelText: 'Senha Atual',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true, // Esconde o texto introduzido.
            ),
            const SizedBox(height: 16),

            // Campo de texto para a nova senha.
            TextField(
              controller: _newPassController,
              decoration: const InputDecoration(
                labelText: 'Nova Senha',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Campo de texto para confirmar a nova senha.
            TextField(
              controller: _confirmPassController,
              decoration: const InputDecoration(
                labelText: 'Confirmar Nova Senha',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            // Botão para salvar as alterações, ou indicador de carregamento.
            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Salvar',
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
    );
  }
}

// Trabalho realizado por:
// -> Miguel Magalhães;
// -> Nº:2021103166;
// -> Unidade Curricular de Computação Móvel;
// -> Licenciatura em Engenharia informática;
// -> ISPGAYA
