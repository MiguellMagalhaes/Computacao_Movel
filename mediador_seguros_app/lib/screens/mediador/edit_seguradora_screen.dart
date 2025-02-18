// Importação das bibliotecas necessárias para interagir com o Firestore,
// construir a interface do utilizador e utilizar o modelo 'Seguradora'.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mediador_seguros_app/models/seguradora_model.dart';

/// Classe que representa o ecrã para editar uma seguradora já existente.
/// Recebe um objeto do tipo [Seguradora] através do construtor.
class EditSeguradoraScreen extends StatefulWidget {
  // Objeto do tipo [Seguradora] que será editado.
  final Seguradora seguradora;

  // Construtor que recebe a seguradora como parâmetro obrigatório.
  const EditSeguradoraScreen({super.key, required this.seguradora});

  @override
  State<EditSeguradoraScreen> createState() => _EditSeguradoraScreenState();
}

/// Estado da classe [EditSeguradoraScreen].
class _EditSeguradoraScreenState extends State<EditSeguradoraScreen> {
  // Controladores de texto para o nome e os tipos de seguro.
  final _nomeController = TextEditingController();
  final _tiposController = TextEditingController();

  // Indica se está a ocorrer uma operação de carregamento (por exemplo, atualização no Firestore).
  bool _loading = false;

  // Chave global que permite validar o formulário.
  final _formKey = GlobalKey<FormState>();

  /// Método chamado quando o widget é inicializado pela primeira vez.
  /// Aqui, preenchemos os controladores de texto com os dados existentes da seguradora.
  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.seguradora.nome;
    // Junta todos os tipos numa única string, separados por ", ".
    _tiposController.text = widget.seguradora.tipos.join(', ');
  }

  /// Método assíncrono para atualizar a seguradora no Firestore.
  Future<void> _editSeguradora() async {
    // Valida o formulário (verifica se todos os campos cumprem as regras definidas).
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Ativa o estado de carregamento.
    setState(() {
      _loading = true;
    });

    // Obtém o nome da seguradora e converte a string de tipos numa lista.
    final nome = _nomeController.text.trim();
    final tipos =
        _tiposController.text.trim().split(',').map((t) => t.trim()).toList();

    // Atualiza o documento da seguradora no Firestore usando o id existente.
    await FirebaseFirestore.instance
        .collection('seguradoras')
        .doc(widget.seguradora.id)
        .update({
      'nome': nome,
      'tipos': tipos,
    });

    // Desativa o estado de carregamento.
    setState(() {
      _loading = false;
    });

    // Se o widget ainda estiver montado, apresenta uma mensagem de sucesso e volta atrás na navegação.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seguradora atualizada com sucesso!')),
      );
      Navigator.pop(context);
    }
  }

  /// Método chamado quando o widget é removido da árvore de widgets.
  /// Liberta os controladores de texto para evitar fugas de memória.
  @override
  void dispose() {
    _nomeController.dispose();
    _tiposController.dispose();
    super.dispose();
  }

  /// Método de construção do widget principal que apresenta o ecrã de edição.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Seguradora'),
        backgroundColor: Colors.blueAccent,
      ),
      // Permite a rolagem caso o conteúdo seja maior que o ecrã.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        // Cartão que envolve o formulário de edição.
        child: Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            // Form para agrupar os campos e utilizar validação.
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(
                    Icons.edit,
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
                    // Regras de validação para este campo.
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
                    // Regras de validação para este campo.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira os tipos de seguro';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Botão para salvar as alterações ou indicador de carregamento, consoante o estado.
                  _loading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _editSeguradora,
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar Alterações'),
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
