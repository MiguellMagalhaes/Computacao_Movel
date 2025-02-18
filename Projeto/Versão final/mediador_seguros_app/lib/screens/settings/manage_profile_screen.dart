// lib/screens/settings/manage_profile_screen.dart

// Importações necessárias para a construção da interface e para interagir com o Firebase.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Tela para gestão do perfil do utilizador (nome, etc.).
class ManageProfileScreen extends StatefulWidget {
  // Construtor padrão, com chave opcional.
  const ManageProfileScreen({super.key});

  @override
  State<ManageProfileScreen> createState() => _ManageProfileScreenState();
}

/// Classe que mantém o estado de [ManageProfileScreen].
class _ManageProfileScreenState extends State<ManageProfileScreen> {
  // Instância do FirebaseAuth para obter o utilizador atual.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controlador para o campo de texto "nome".
  final TextEditingController _nameController = TextEditingController();

  // Indica se os dados ainda estão a ser carregados (true) ou se já podem ser exibidos (false).
  bool _loading = true;

  // Chave global do formulário para validações.
  final _formKey = GlobalKey<FormState>();

  /// Método para carregar o perfil do utilizador atual do Firestore.
  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    // Verifica se há um utilizador autenticado.
    if (user != null) {
      // Obtém o documento do utilizador na coleção 'usuarios' com base no UID.
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      // Se o documento existir, preenche o campo de texto com o nome do utilizador.
      if (doc.exists) {
        _nameController.text = doc['nome'] as String? ?? '';
      }
    }

    // Atualiza o estado para indicar que já carregamos os dados.
    setState(() {
      _loading = false;
    });
  }

  /// Método para salvar as alterações no perfil do utilizador.
  Future<void> _saveProfile() async {
    // Primeiro valida o formulário.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Indica que estamos num processo de salvamento (loading).
    setState(() {
      _loading = true;
    });

    final user = _auth.currentUser;
    if (user != null) {
      // Atualiza o campo 'nome' do documento do utilizador no Firestore.
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .update({'nome': _nameController.text.trim()});

      // Mostra uma mensagem de sucesso.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso.')),
      );
    }

    // Desativa o modo de carregamento.
    setState(() {
      _loading = false;
    });

    // Retorna à tela anterior.
    Navigator.pop(context);
  }

  /// Método chamado quando o widget é inserido na árvore de widgets.
  /// Carrega o perfil do utilizador (nome, etc.).
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Método chamado quando o widget é removido da árvore de widgets.
  /// Liberta os recursos (controladores de texto).
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Constrói o widget principal que representa esta tela de gestão de perfil.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar com o título "Gerenciar Perfil".
      appBar: AppBar(
        title: const Text('Gerenciar Perfil'),
        // Define a cor de fundo de acordo com o tema atual, se existir.
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      // Corpo que exibe um indicador de progresso enquanto carrega,
      // ou o formulário quando os dados estiverem disponíveis.
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              // Form para agrupar os campos e utilizar validações.
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo de texto para o nome do utilizador.
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      // Validação para garantir que o nome não seja vazio.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Botão para salvar as alterações ou indicador de carregamento,
                    // consoante o estado _loading.
                    _loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              child: const Text(
                                'Salvar Alterações',
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
