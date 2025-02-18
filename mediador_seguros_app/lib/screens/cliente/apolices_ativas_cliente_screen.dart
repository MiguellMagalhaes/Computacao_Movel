// Importa a biblioteca cloud_firestore para aceder à base de dados do Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
// Importa a biblioteca firebase_auth para gerir a autenticação Firebase.
import 'package:firebase_auth/firebase_auth.dart';
// Importa a biblioteca flutter/material.dart para utilizar widgets do Flutter.
import 'package:flutter/material.dart';

// Classe que representa a tela (screen) das apólices ativas de um cliente.
// É um StatelessWidget, pois não mantém estado interno.
class ApolicesAtivasClienteScreen extends StatelessWidget {
  // Construtor que recebe uma chave opcional (super.key).
  const ApolicesAtivasClienteScreen({super.key});

  // Método assíncrono para cancelar a apólice, dado o seu ID.
  // Actualiza o documento na colecção 'apolices' definindo o seu status para 'cancelada'.
  Future<void> _cancelarApolice(String apoliceId) async {
    await FirebaseFirestore.instance
        .collection('apolices')
        .doc(apoliceId)
        .update({'status': 'cancelada'});
  }

  // Método assíncrono para antecipar o término da apólice, dado o seu ID.
  // Actualiza o documento na colecção 'apolices' definindo o status como 'terminada'
  // e a dataFim como a data/hora actual (Timestamp.now()).
  Future<void> _anteciparTermino(String apoliceId) async {
    await FirebaseFirestore.instance
        .collection('apolices')
        .doc(apoliceId)
        .update({'status': 'terminada', 'dataFim': Timestamp.now()});
  }

  // Método que constrói o widget principal da interface de utilizador.
  @override
  Widget build(BuildContext context) {
    // Obtém o utilizador actualmente autenticado no FirebaseAuth.
    final user = FirebaseAuth.instance.currentUser;
    // Verifica se o utilizador não está autenticado.
    if (user == null) {
      // Caso não exista um utilizador autenticado, retorna um Scaffold com mensagem de erro.
      return const Scaffold(
        body: Center(
          child: Text(
            'Usuário não logado',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    // Cria uma referência para a colecção 'apolices' no Firestore
    // filtrando apenas os documentos cuja userId seja igual ao UID do utilizador
    // e cujo status seja 'ativa'.
    final apolicesRef = FirebaseFirestore.instance
        .collection('apolices')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'ativa');

    // Retorna um Scaffold que representa a estrutura da página.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apólices Ativas'),
        backgroundColor: Colors.blueAccent,
      ),
      // Corpo do Scaffold constituído por um StreamBuilder para construir o UI
      // com base nas alterações na colecção 'apolices'.
      body: StreamBuilder<QuerySnapshot>(
        // Utiliza a referência criada anteriormente para observar as mudanças
        // (snapshot) em tempo real.
        stream: apolicesRef.snapshots(),
        // Função que constrói o UI consoante o estado do snapshot.
        builder: (context, snapshot) {
          // Verifica se ainda não foi obtido nenhum dado do servidor (i.e. se a Stream está vazia).
          if (!snapshot.hasData) {
            // Caso não haja dados, mostra um indicador de carregamento (loading).
            return const Center(child: CircularProgressIndicator());
          }
          // Obtém a lista de documentos da colecção a partir do snapshot.
          final docs = snapshot.data!.docs;
          // Verifica se não existem documentos (se a lista está vazia).
          if (docs.isEmpty) {
            // Caso não existam apólices ativas, mostra uma mensagem apropriada.
            return const Center(
              child: Text(
                'Não há apólices ativas.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // Se existirem documentos, constrói uma ListView para exibi-los.
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: docs.length,
            // Função que constrói cada item (Card) com base nos dados de cada documento.
            itemBuilder: (context, index) {
              // Converte o documento numa estrutura de mapa.
              final data = docs[index].data() as Map<String, dynamic>;
              // Obtém o tipo de seguro do mapa ou define 'Desconhecido' caso não exista.
              final tipo = data['tipoSeguro'] ?? 'Desconhecido';
              // Obtém o status do mapa ou define 'Ativa' caso não exista.
              final status = data['status'] ?? 'Ativa';
              // Verifica se existe data de término (dataFim), convertendo-a para DateTime caso exista.
              final dataFim = data['dataFim'] != null
                  ? (data['dataFim'] as Timestamp).toDate()
                  : null;

              // Cria um Card para cada documento, com texto e acções apropriadas.
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.security,
                    color: Colors.blueAccent,
                    size: 40,
                  ),
                  title: Text(
                    'Apólice: $tipo',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // Subtítulo contendo mais detalhes, como ID, data de término e status.
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('ID: ${docs[index].id}'),
                      if (dataFim != null)
                        Text(
                            'Data de Término: ${dataFim.day}/${dataFim.month}/${dataFim.year}'),
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          color: status == 'ativa'
                              ? Colors.green
                              : status == 'cancelada'
                                  ? Colors.red
                                  : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // Botão pop-up (3 pontos) para as acções de cancelar ou antecipar término.
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      // Se o utilizador escolher 'cancelar', chama o método _cancelarApolice.
                      if (value == 'cancelar') {
                        await _cancelarApolice(docs[index].id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Apólice cancelada com sucesso!')),
                        );
                      }
                      // Se o utilizador escolher 'antecipar', chama o método _anteciparTermino.
                      else if (value == 'antecipar') {
                        await _anteciparTermino(docs[index].id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Término antecipado com sucesso!')),
                        );
                      }
                    },
                    // Define os itens do menu pop-up.
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'cancelar',
                        child: Text('Cancelar Imediatamente'),
                      ),
                      const PopupMenuItem(
                        value: 'antecipar',
                        child: Text('Antecipar Término'),
                      ),
                    ],
                  ),
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
