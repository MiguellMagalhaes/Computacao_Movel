// Importações necessárias para interagir com o Firestore e para construir a interface de utilizador.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// Importa o modelo [Seguradora] para a representação das seguradoras.
import 'package:mediador_seguros_app/models/seguradora_model.dart';
// Importa a tela (screen) para adicionar uma nova seguradora.
import 'package:mediador_seguros_app/screens/mediador/add_seguradora_screen.dart';
// Importa a tela (screen) para editar uma seguradora existente.
import 'package:mediador_seguros_app/screens/mediador/edit_seguradora_screen.dart';

/// Tela que lista as seguradoras existentes, permite adicionar novas seguradoras,
/// editar ou deletar as já existentes.
class SeguradorasListScreen extends StatefulWidget {
  /// Construtor padrão da tela, aceita uma chave opcional.
  const SeguradorasListScreen({super.key});

  /// Cria o estado da tela [SeguradorasListScreen].
  @override
  State<SeguradorasListScreen> createState() => _SeguradorasListScreenState();
}

class _SeguradorasListScreenState extends State<SeguradorasListScreen> {
  // Referência para a colecção 'seguradoras' no Firestore.
  final CollectionReference seguradorasRef =
      FirebaseFirestore.instance.collection('seguradoras');

  /// Método assíncrono para apagar uma seguradora, dado o seu ID.
  /// Solicita confirmação antes de efetuar a deleção no Firestore.
  Future<void> _deleteSeguradora(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Deleção'),
        content: const Text('Tem certeza que deseja deletar esta seguradora?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deletar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    // Se o utilizador confirmar (confirm == true), apaga o documento
    // e exibe uma mensagem de sucesso.
    if (confirm == true) {
      await seguradorasRef.doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seguradora deletada com sucesso!')),
      );
    }
  }

  /// Constrói o widget principal da tela que exibe a lista de seguradoras.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar com o título "Seguradoras".
      appBar: AppBar(
        title: const Text('Seguradoras'),
        backgroundColor: Colors.blueAccent,
      ),
      // Corpo constituído por um StreamBuilder para observar a colecção 'seguradoras'.
      body: StreamBuilder<QuerySnapshot>(
        stream: seguradorasRef.snapshots(),
        builder: (context, snapshot) {
          // Caso não haja dados (ou se ainda não foram carregados), mostra um indicador de progresso.
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Extrai a lista de documentos da colecção.
          final docs = snapshot.data!.docs;
          // Se a lista estiver vazia, mostra uma mensagem apropriada.
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma seguradora cadastrada.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // Converte cada documento num objeto [Seguradora] através do método fromMap.
          final seguradoras = docs
              .map((doc) => Seguradora.fromMap(
                  doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          // Constrói uma ListView para exibir as seguradoras.
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: seguradoras.length,
            itemBuilder: (context, index) {
              final seg = seguradoras[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // ListTile para mostrar informações sobre a seguradora
                // e oferecer opções de editar ou deletar.
                child: ListTile(
                  // Ícone (CircleAvatar) com a inicial do nome da seguradora.
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      seg.nome[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  // Título em negrito com o nome da seguradora.
                  title: Text(
                    seg.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // Subtítulo que apresenta os tipos de seguro separados por vírgula.
                  subtitle: Text("Tipos: ${seg.tipos.join(', ')}"),
                  // Ícones de editar e deletar.
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão para editar a seguradora.
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        tooltip: 'Editar Seguradora',
                        onPressed: () {
                          // Navega para a tela de edição, passando a seguradora atual como argumento.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditSeguradoraScreen(
                                seguradora: seg,
                              ),
                            ),
                          );
                        },
                      ),
                      // Botão para deletar a seguradora.
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Deletar Seguradora',
                        onPressed: () async {
                          await _deleteSeguradora(seg.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Botão flutuante para adicionar uma nova seguradora.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSeguradoraScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Seguradora',
        backgroundColor: Colors.blueAccent,
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
