// Importação das bibliotecas necessárias para interagir com o Firestore e para construir
// a interface de utilizador com o Flutter.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Classe que representa o ecrã para adicionar uma nova seguradora.
// É um StatefulWidget porque precisa de manter algum estado (por exemplo, o _loading).
class AddSeguradoraScreen extends StatefulWidget {
  // Construtor padrão, com chave opcional.
  const AddSeguradoraScreen({super.key});

  // Cria o estado do widget [AddSeguradoraScreen].
  @override
  State<AddSeguradoraScreen> createState() => _AddSeguradoraScreenState();
}

// Classe que mantém o estado de [AddSeguradoraScreen].
class _AddSeguradoraScreenState extends State<AddSeguradoraScreen> {
  // Controladores para os campos de texto.
  // O _nomeController para o nome da seguradora e o _tiposController para os tipos de seguro.
  final _nomeController = TextEditingController();
  final _tiposController = TextEditingController();

  // Variável para indicar se estamos num processo de carregamento (ao adicionar seguradora).
  bool _loading = false;

  // Chave global para o formulário, utilizada na validação.
  final _formKey = GlobalKey<FormState>();

  // Função assíncrona que adiciona uma nova seguradora ao Firestore.
  Future<void> _addSeguradora() async {
    // Verifica se o formulário é válido antes de prosseguir.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Indica que estamos em modo de carregamento.
    setState(() {
      _loading = true;
    });

    // Obtém os valores dos campos de texto.
    final nome = _nomeController.text.trim();
    // Converte a string com tipos separados por vírgula numa lista de strings.
    final tipos =
        _tiposController.text.trim().split(',').map((t) => t.trim()).toList();

    // Adiciona o documento 'seguradora' à colecção 'seguradoras' no Firestore.
    await FirebaseFirestore.instance.collection('seguradoras').add({
      'nome': nome,
      'tipos': tipos,
    });

    // Desactiva o modo de carregamento.
    setState(() {
      _loading = false;
    });

    // Verifica se o widget ainda está montado, depois apresenta uma SnackBar e volta ao ecrã anterior.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seguradora adicionada com sucesso!')));
      Navigator.pop(context);
    }
  }

  // Método chamado quando o widget é removido da árvore de widgets.
  // Liberta os recursos dos controladores.
  @override
  void dispose() {
    _nomeController.dispose();
    _tiposController.dispose();
    super.dispose();
  }

  // Método que constrói o ecrã principal deste widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar com título e cor de fundo.
      appBar: AppBar(
        title: const Text('Adicionar Seguradora'),
        backgroundColor: Colors.blueAccent,
      ),
      // Corpo do ecrã com SingleChildScrollView para permitir scroll, caso o conteúdo ultrapasse o ecrã.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        // Cartão que envolve o formulário para dar destaque.
        child: Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            // Formulário que utiliza a chave _formKey para validação.
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Ícone ilustrativo no topo.
                  const Icon(
                    Icons.add_business,
                    size: 80,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 16),
                  // Campo de texto para o nome da seguradora.
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Seguradora',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    // Validação para garantir que o campo não esteja vazio.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome da seguradora';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Campo de texto para os tipos de seguro, separados por vírgula.
                  TextFormField(
                    controller: _tiposController,
                    decoration: const InputDecoration(
                      labelText: 'Tipos de Seguro (separados por vírgula)',
                      prefixIcon: Icon(Icons.list),
                      border: OutlineInputBorder(),
                    ),
                    // Validação para garantir que não esteja vazio.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira os tipos de seguro';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Botão para salvar ou indicador de progresso consoante o estado _loading.
                  _loading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _addSeguradora,
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
    );
  }
}

// Trabalho realizado por:
// -> Miguel Magalhães;
// -> Nº:2021103166;
// -> Unidade Curricular de Computação Móvel;
// -> Licenciatura em Engenharia informática;
// -> ISPGAYA
