// Importa a biblioteca cloud_firestore para interagir com a base de dados Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
// Importa a biblioteca firebase_auth para gerir a autenticação de utilizadores Firebase.
import 'package:firebase_auth/firebase_auth.dart';
// Importa a biblioteca flutter/material.dart para usar os widgets e temas do Material Design.
import 'package:flutter/material.dart';

// Widget com estado que representa a tela onde o utilizador escolhe uma seguradora.
// Recebe um [orcamentoId] como parâmetro obrigatório.
class EscolherSeguradoraScreen extends StatefulWidget {
  // Identificador do orçamento.
  final String orcamentoId;

  // Construtor que recebe a chave e o orcamentoId de forma obrigatória.
  const EscolherSeguradoraScreen({super.key, required this.orcamentoId});

  // Cria o estado do widget [EscolherSeguradoraScreen].
  @override
  State<EscolherSeguradoraScreen> createState() =>
      _EscolherSeguradoraScreenState();
}

// Classe que mantém o estado da tela de escolha de seguradora.
class _EscolherSeguradoraScreenState extends State<EscolherSeguradoraScreen> {
  // Mapa que guarda os dados do orçamento obtidos do Firestore.
  Map<String, dynamic>? orcamentoData;
  // Indica se os dados ainda estão a ser carregados.
  bool _loading = true;
  // Mapa que guarda os valores de cada seguradora, com o ID da seguradora como chave e o valor como double.
  Map<String, double>? valores;
  // String que guarda o tipo de seguro obtido do orçamento.
  String? tipoSeguro;

  // Método chamado quando o widget é inicializado pela primeira vez.
  // Invoca o método _loadOrcamento para carregar os dados do orçamento.
  @override
  void initState() {
    super.initState();
    _loadOrcamento();
  }

  // Método assíncrono para carregar os dados de um orçamento específico a partir do Firestore.
  Future<void> _loadOrcamento() async {
    // Obtém o documento do orçamento com base no ID recebido.
    final doc = await FirebaseFirestore.instance
        .collection('orcamentos')
        .doc(widget.orcamentoId)
        .get();

    // Verifica se o documento não existe.
    if (!doc.exists) {
      // Se o widget ainda estiver montado no ecrã, mostra uma mensagem e volta atrás.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orçamento não encontrado.')),
        );
        Navigator.pop(context);
      }
      return;
    }

    // Se o documento existir, guardamos os dados do orçamento numa variável local.
    orcamentoData = doc.data();
    // Convertemos o campo 'valoresSeguradoras' para um mapa de String e double.
    valores =
        Map<String, double>.from(orcamentoData?['valoresSeguradoras'] ?? {});
    // Guardamos o tipo de seguro no campo apropriado.
    tipoSeguro = orcamentoData?['tipoSeguro'];

    // Atualizamos o estado do widget para indicar que o carregamento terminou.
    setState(() {
      _loading = false;
    });
  }

  // Método assíncrono que permite ao utilizador escolher a seguradora para criar uma apólice.
  Future<void> _escolherSeguradora(String seguradoraId, double valor) async {
    // Verifica se existe um utilizador autenticado.
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Cria as variáveis com a data/hora actual e um ano depois.
    final agora = Timestamp.now();
    final umAnoDepois = Timestamp.fromDate(
      DateTime.now().add(const Duration(days: 365)),
    );

    // Adiciona uma nova apólice na colecção 'apolices' do Firestore.
    await FirebaseFirestore.instance.collection('apolices').add({
      'userId': user.uid,
      'seguradoraId': seguradoraId,
      'tipoSeguro': tipoSeguro,
      'dataInicio': agora,
      'dataFim': umAnoDepois,
      'status': 'ativa',
    });

    // Actualiza o estado do orçamento para "aceito" (aceite).
    await FirebaseFirestore.instance
        .collection('orcamentos')
        .doc(widget.orcamentoId)
        .update({'status': 'aceito'});

    // Se o widget ainda estiver montado, mostra uma mensagem e volta para a tela anterior.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seguradora escolhida e apólice criada!')),
      );
      Navigator.pop(context);
    }
  }

  // Método assíncrono para recusar o orçamento.
  Future<void> _recusarOrcamento() async {
    // Actualiza o documento do orçamento, definindo o status como 'recusado'.
    await FirebaseFirestore.instance
        .collection('orcamentos')
        .doc(widget.orcamentoId)
        .update({'status': 'recusado'});

    // Se o widget ainda estiver montado, mostra uma mensagem e volta à tela anterior.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Orçamento recusado.')),
      );
      Navigator.pop(context);
    }
  }

  // Método que constrói o widget principal do ecrã.
  @override
  Widget build(BuildContext context) {
    // Verifica se ainda estamos a carregar os dados (orcamentoData).
    if (_loading) {
      // Se sim, mostra um ecrã com indicador de progresso.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Caso os valores sejam nulos ou vazios, não há seguradoras disponíveis.
    if (valores == null || valores!.isEmpty) {
      // Mostra um Scaffold com AppBar e uma mensagem informando que não há valores.
      return Scaffold(
        appBar: AppBar(
          title: const Text('Escolher Seguradora'),
          backgroundColor: Colors.blueAccent,
          actions: [
            // Botão para recusar o orçamento.
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _recusarOrcamento,
            )
          ],
        ),
        body: const Center(
          child: Text('Não há valores de seguradoras disponíveis.'),
        ),
      );
    }

    // Obtém o desconto aplicado do mapa do orçamento, ou 0.0 caso não exista.
    final double desconto =
        (orcamentoData?['descontoAplicado'] ?? 0.0) as double;
    // Vai guardar informação do tipo: " (Desconto de 5%)" se o desconto for 0.05, etc.
    String descontoInfo = '';
    // Verifica se existe desconto.
    if (desconto > 0) {
      // Converte o valor em percentagem e formata. Ex.: 0.05 -> "5", 0.10 -> "10".
      final porcentagem = (desconto * 100).toStringAsFixed(0);
      descontoInfo = ' (Desconto de $porcentagem%)';
    }

    // Se existirem valores, mostra-os num Scaffold com uma lista.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolher Seguradora'),
        backgroundColor: Colors.blueAccent,
        actions: [
          // Botão para recusar o orçamento.
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _recusarOrcamento,
            tooltip: 'Recusar Orçamento',
          )
        ],
      ),
      // FutureBuilder para obter os documentos da colecção 'seguradoras'.
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('seguradoras').get(),
        builder: (context, snapshot) {
          // Verifica se ainda não há dados (snapshot em carregamento).
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Lista de documentos de seguradoras retornados pelo Firestore.
          final segDocs = snapshot.data!.docs;
          // Cria um mapa para relacionar o ID da seguradora aos dados do respectivo documento.
          final nomeSegMap = {for (var d in segDocs) d.id: d.data()};

          // Filtra apenas as seguradoras que ainda existem e cujos valores constam no orcamento.
          final lista = valores!.entries
              .where((e) => nomeSegMap.containsKey(e.key))
              .toList();

          // Verifica se a lista está vazia (ou seja, se nenhuma seguradora do orçamento existe).
          if (lista.isEmpty) {
            return const Center(
              child: Text('Nenhuma das seguradoras existe mais.'),
            );
          }

          // Constrói a lista de Cards com as seguradoras disponíveis.
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: lista.length,
              itemBuilder: (context, index) {
                // ID da seguradora.
                final segId = lista[index].key;
                // Valor associado a essa seguradora.
                final valor = lista[index].value;

                // Dados da seguradora obtidos do Firestore (nome, etc.).
                final segData = nomeSegMap[segId] as Map<String, dynamic>;
                // Tenta obter o campo 'nome'; se não existir, mostra o ID.
                final nomeSeg = segData['nome'] ?? segId;

                // String que mostra o valor formatado e a informação de desconto, se existir.
                final valorStr =
                    'Valor: ${valor.toStringAsFixed(2)}€$descontoInfo';

                // Cria um Card para apresentar cada seguradora.
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    // Cria um avatar com a primeira letra do nome da seguradora.
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        nomeSeg[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    // Nome da seguradora em texto destacado.
                    title: Text(
                      nomeSeg,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    // Mostra o valor estimado da apólice e a informação de desconto.
                    subtitle: Text(valorStr),
                    // Ícone que indica que se pode avançar para escolher a seguradora.
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    // Ao clicar no ListTile, chama o método para escolher a seguradora.
                    onTap: () {
                      _escolherSeguradora(segId, valor);
                    },
                  ),
                );
              },
            ),
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
