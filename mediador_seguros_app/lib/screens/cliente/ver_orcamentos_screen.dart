// Importa a biblioteca cloud_firestore para aceder à base de dados Firestore do Firebase.
import 'package:cloud_firestore/cloud_firestore.dart';
// Importa a biblioteca firebase_auth para gerir a autenticação de utilizadores.
import 'package:firebase_auth/firebase_auth.dart';
// Importa a biblioteca flutter/material.dart para construir a interface de utilizador.
import 'package:flutter/material.dart';
// Importa o ecrã (screen) de escolher seguradora para redireccionar o utilizador.
import 'package:mediador_seguros_app/screens/cliente/escolher_seguradora_screen.dart';

/// Classe responsável por apresentar os orçamentos respondidos ao utilizador.
class VerOrcamentosScreen extends StatelessWidget {
  /// Construtor padrão, que aceita uma chave opcional (super.key).
  const VerOrcamentosScreen({super.key});

  /// Método que constrói o widget principal do ecrã.
  @override
  Widget build(BuildContext context) {
    // Obtém o utilizador actual a partir do FirebaseAuth.
    final user = FirebaseAuth.instance.currentUser;
    // Se não existir utilizador autenticado, retorna um Scaffold a informar o facto.
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Usuário não logado',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    // Cria a referência para a colecção 'orcamentos', filtrando apenas os documentos
    // do utilizador actual (user.uid) e cujo status seja 'respondido'.
    final orcamentosRef = FirebaseFirestore.instance
        .collection('orcamentos')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'respondido');

    // Retorna um Scaffold que contém a AppBar e o corpo com um StreamBuilder.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos Respondidos'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Observa em tempo real as alterações nos orçamentos que cumpram os critérios definidos.
        stream: orcamentosRef.snapshots(),
        // O builder recebe o contexto e o snapshot que contém os dados ou o estado da stream.
        builder: (context, snapshot) {
          // Se o snapshot ainda não tem dados, mostra um indicador de carregamento.
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // Armazena a lista de documentos (orçamentos) num array (docs).
          final docs = snapshot.data!.docs;
          // Se não houver documentos, mostra uma mensagem a informar que não há orçamentos respondidos.
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Não há orçamentos respondidos.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // Caso existam documentos, constrói uma ListView para os exibir.
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              // Extrai o mapa de dados do documento actual.
              final data = docs[index].data() as Map<String, dynamic>;
              // Obtém o tipo de seguro (ou 'Desconhecido' se não existir campo).
              final tipo = data['tipoSeguro'] ?? 'Desconhecido';
              // Obtém o status do orçamento (ou 'Respondido' se não existir campo).
              final status = data['status'] ?? 'Respondido';

              // Verifica se existe algum desconto aplicado e converte-o para double (0.0 se não existir).
              final desconto = (data['descontoAplicado'] ?? 0.0) as double;
              // Cria uma string para apresentar o desconto aplicado (se existir).
              String descontoInfo = '';
              if (desconto > 0) {
                // Converte o valor em percentagem (ex. 0.05 -> "5").
                final porcentagem = (desconto * 100).toStringAsFixed(0);
                descontoInfo = '\nDesconto aplicado: $porcentagem%';
              }

              // Retorna um Card para cada documento (orçamento), com ícone, título e subtítulo.
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.assignment,
                    color: Colors.blueAccent,
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
                  // Subtítulo que mostra o ID do documento, o status e informações de desconto (se existirem).
                  subtitle: Text(
                    'ID: ${docs[index].id}\n'
                    'Status: $status$descontoInfo',
                  ),
                  // Ícone que indica ao utilizador a possibilidade de navegar para outra tela.
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  // Ao clicar no Card, navega para a tela de EscolherSeguradoraScreen,
                  // passando o ID do orçamento como parâmetro.
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EscolherSeguradoraScreen(
                          orcamentoId: docs[index].id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
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
