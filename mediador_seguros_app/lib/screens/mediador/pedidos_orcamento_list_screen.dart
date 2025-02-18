// Importa as bibliotecas necessárias para interagir com o Firestore e para criar a interface gráfica.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// Importa a tela de ResponderOrcamentoScreen, para onde o utilizador será redirecionado ao clicar num pedido.
import 'package:mediador_seguros_app/screens/mediador/responder_orcamento_screen.dart';

/// Ecrã (screen) que lista os pedidos de orçamento pendentes para o mediador.
class PedidosOrcamentoListScreen extends StatelessWidget {
  // Construtor padrão, com chave opcional.
  const PedidosOrcamentoListScreen({super.key});

  /// Método que constrói o widget principal do ecrã.
  @override
  Widget build(BuildContext context) {
    // Cria uma referência para a colecção 'orcamentos' no Firestore.
    final orcamentosRef = FirebaseFirestore.instance.collection('orcamentos');

    // Retorna um Scaffold para estruturar a tela.
    return Scaffold(
      appBar: AppBar(
        // Título exibido no topo da aplicação.
        title: const Text('Pedidos de Orçamento Pendentes'),
        backgroundColor: Colors.blueAccent,
      ),
      // Corpo do Scaffold constituído por um StreamBuilder que observa
      // a colecção 'orcamentos' filtrada pelo campo 'status' = 'pendente'.
      body: StreamBuilder<QuerySnapshot>(
          stream:
              orcamentosRef.where('status', isEqualTo: 'pendente').snapshots(),
          builder: (context, snapshot) {
            // Caso não haja dados a apresentar (ou ainda não estejam carregados),
            // exibe um indicador de progresso (CircularProgressIndicator).
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            // Obtém a lista de documentos a partir do snapshot.
            final docs = snapshot.data!.docs;
            // Verifica se a lista está vazia (nenhum pedido pendente).
            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhum pedido pendente.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            // Se existirem documentos, apresenta-os numa ListView.
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                // Converte cada documento num mapa de chave-valor.
                final data = docs[index].data() as Map<String, dynamic>;
                // Obtém o tipo de seguro ou define 'Desconhecido' caso não esteja definido.
                final tipo = data['tipoSeguro'] as String? ?? 'Desconhecido';
                // Obtém a data de criação, convertendo-a de Timestamp para DateTime, se existir.
                final dataCriacao = data['dataCriacao'] != null
                    ? (data['dataCriacao'] as Timestamp).toDate()
                    : null;

                // Retorna um Card que apresenta as informações relevantes do orçamento pendente.
                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    // Ícone que identifica o estado do orçamento como pendente.
                    leading: Icon(
                      Icons.pending_actions,
                      color: Colors.orangeAccent,
                      size: 40,
                    ),
                    // Título que mostra o tipo de seguro.
                    title: Text(
                      'Orçamento: $tipo',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    // Subtítulo que contém detalhes adicionais, como ID e data de criação.
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('ID: ${docs[index].id}'),
                        if (dataCriacao != null)
                          Text(
                              'Criado em: ${dataCriacao.day}/${dataCriacao.month}/${dataCriacao.year}'),
                      ],
                    ),
                    // Ícone que indica que pode navegar para outra tela.
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    // Ao clicar no Card, navega para a tela de ResponderOrcamentoScreen,
                    // passando o ID do orçamento para posterior manipulação.
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ResponderOrcamentoScreen(
                                  orcamentoId: docs[index].id)));
                    },
                  ),
                );
              },
            );
          }),
    );
  }
}

// Trabalho realizado por:
// -> Miguel Magalhães;
// -> Nº:2021103166;
// -> Unidade Curricular de Computação Móvel;
// -> Licenciatura em Engenharia informática;
// -> ISPGAYA
