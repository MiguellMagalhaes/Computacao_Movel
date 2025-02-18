// Importa as bibliotecas necessárias para interagir com o Firestore e para criar a interface de utilizador.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Ecrã (screen) que apresenta as apólices ativas para o mediador.
/// É um StatelessWidget, pois não necessita de manter estado interno.
class ApolicesAtivasMediadorScreen extends StatelessWidget {
  // Construtor padrão, com chave opcional.
  const ApolicesAtivasMediadorScreen({super.key});

  /// Método que constrói o widget principal do ecrã.
  @override
  Widget build(BuildContext context) {
    // Cria uma referência para a colecção 'apolices' no Firestore,
    // filtrando apenas as apólices cujo campo 'status' é igual a 'ativa'.
    final apolicesRef = FirebaseFirestore.instance
        .collection('apolices')
        .where('status', isEqualTo: 'ativa');

    // Retorna um Scaffold com AppBar e corpo definido pelo StreamBuilder para observação em tempo real.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apólices Ativas'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Observa em tempo real as alterações na colecção 'apolices' que tenham status 'ativa'.
        stream: apolicesRef.snapshots(),
        // Constrói o UI com base no estado do snapshot.
        builder: (context, snapshot) {
          // Verifica se ainda não foi obtido nenhum dado do servidor.
          if (!snapshot.hasData) {
            // Apresenta um indicador de carregamento enquanto a stream está a ser obtida.
            return const Center(child: CircularProgressIndicator());
          }

          // Obtém a lista de documentos de apólices a partir do snapshot.
          final docs = snapshot.data!.docs;

          // Se não existirem documentos, mostra uma mensagem indicando que não há apólices ativas.
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma apólice ativa.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // Se existirem documentos, apresenta-os numa ListView.
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              // Converte o documento numa estrutura de mapa.
              final data = docs[index].data() as Map<String, dynamic>;

              // Obtém os campos relevantes, definindo valores padrão caso não existam.
              final tipo = data['tipoSeguro'] ?? 'Desconhecido';
              final userId = data['userId'] ?? 'Não Identificado';
              final seguradoraId = data['seguradoraId'] ?? 'Não Identificada';

              // Converte os campos Timestamp em DateTime, caso existam.
              final dataInicio = data['dataInicio'] != null
                  ? (data['dataInicio'] as Timestamp).toDate()
                  : null;
              final dataFim = data['dataFim'] != null
                  ? (data['dataFim'] as Timestamp).toDate()
                  : null;

              // Cria um Card para cada apólice, mostrando informações relevantes.
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.security,
                    color: Colors.blueAccent,
                    size: 40,
                  ),
                  title: Text(
                    'Tipo: $tipo',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // Subtítulo com alguns dados adicionais, como ID do utilizador, ID da seguradora
                  // e datas de início/término (se disponíveis).
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Usuário ID: $userId'),
                      Text('Seguradora ID: $seguradoraId'),
                      if (dataInicio != null)
                        Text(
                            'Início: ${dataInicio.day}/${dataInicio.month}/${dataInicio.year}'),
                      if (dataFim != null)
                        Text(
                            'Término: ${dataFim.day}/${dataFim.month}/${dataFim.year}'),
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
