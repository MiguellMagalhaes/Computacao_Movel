// Importação das bibliotecas necessárias para interagir com o Firestore e para construir a interface do utilizador.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Classe [ResponderOrcamentoScreen], que apresenta uma interface para o mediador
/// responder a um orçamento específico, atribuindo valores para várias seguradoras.
class ResponderOrcamentoScreen extends StatefulWidget {
  // Identificador único do orçamento que será respondido.
  final String orcamentoId;

  // Construtor que recebe o [orcamentoId].
  const ResponderOrcamentoScreen({super.key, required this.orcamentoId});

  @override
  State<ResponderOrcamentoScreen> createState() =>
      _ResponderOrcamentoScreenState();
}

/// Classe que mantém o estado de [ResponderOrcamentoScreen].
class _ResponderOrcamentoScreenState extends State<ResponderOrcamentoScreen> {
  // Mapa para armazenar os dados do orçamento obtidos do Firestore.
  Map<String, dynamic>? orcamentoData;
  // Variável booleana para indicar se estamos a carregar dados ou a processar uma acção.
  bool _loading = true;

  // Mapa que associa o ID de cada seguradora ao respectivo TextEditingController.
  // Permite que cada seguradora tenha um campo onde o utilizador insira o valor do seguro.
  Map<String, TextEditingController> valoresControllers = {};

  // Mapa que associa IDs de seguradoras aos seus nomes (ex: 'ID123' -> 'Seguradora XPTO').
  Map<String, String> seguradoraIdToName = {};

  // Chave global para gerir e validar o formulário.
  final _formKey = GlobalKey<FormState>();

  /// Método initState é chamado ao criar o widget pela primeira vez.
  /// Inicia o carregamento dos dados do orçamento e das seguradoras.
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Carrega os dados do orçamento e também lista todas as seguradoras para poder atribuir valores.
  Future<void> _loadData() async {
    // 1) Carrega o documento do orçamento a partir do Firestore usando o orcamentoId.
    final doc = await FirebaseFirestore.instance
        .collection('orcamentos')
        .doc(widget.orcamentoId)
        .get();

    // Verifica se o documento não existe.
    if (!doc.exists) {
      // Se não existir, mostra uma mensagem ao utilizador e volta atrás.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orçamento não encontrado.')),
        );
        Navigator.pop(context);
      }
      return;
    }

    // Se existir, guarda os dados do orçamento para uso posterior.
    orcamentoData = doc.data();

    // 2) Carrega todos os documentos da colecção 'seguradoras'.
    final seguradorasSnap =
        await FirebaseFirestore.instance.collection('seguradoras').get();

    // Para cada seguradora, guarda o seu nome num mapa e cria um TextEditingController.
    for (var sdoc in seguradorasSnap.docs) {
      // Guarda o nome ou um valor por omissão caso não exista.
      seguradoraIdToName[sdoc.id] = sdoc['nome'] as String? ?? 'Sem Nome';
      // Cria o controlador para inserir o valor do seguro para esta seguradora.
      valoresControllers[sdoc.id] = TextEditingController();
    }

    // Indica que o carregamento terminou.
    setState(() {
      _loading = false;
    });
  }

  /// Método que salva a resposta do mediador, atribuindo valores às seguradoras
  /// e aplicando um desconto, se necessário, com base na quantidade de apólices ativas do utilizador.
  Future<void> _salvarResposta() async {
    // 1) Verifica se o formulário é válido de acordo com as regras definidas.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2) Cria um mapa para associar ID da seguradora -> valor introduzido.
    final Map<String, double> valoresSeguradoras = {};
    valoresControllers.forEach((segId, ctrl) {
      final valorStr = ctrl.text.trim();
      if (valorStr.isNotEmpty) {
        final valor = double.tryParse(valorStr);
        if (valor != null) {
          valoresSeguradoras[segId] = valor;
        }
      }
    });

    // Se nenhum valor foi inserido, interrompe a operação.
    if (valoresSeguradoras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insira pelo menos um valor.')),
      );
      return;
    }

    // Indica que estamos em modo de carregamento.
    setState(() {
      _loading = true;
    });

    try {
      // 3) Obtém o userId (ID do utilizador) a partir dos dados do orçamento.
      final userId = orcamentoData?['userId'];
      if (userId == null) {
        // Se não houver userId, mostra mensagem e interrompe.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID não encontrado no orçamento.')),
        );
        setState(() {
          _loading = false;
        });
        return;
      }

      // 4) Consulta quantas apólices ativas este utilizador já possui,
      // para aplicar a lógica de desconto.
      final apolicesSnap = await FirebaseFirestore.instance
          .collection('apolices')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'ativa')
          .get();

      // Número de apólices ativas do utilizador.
      final count = apolicesSnap.size;
      double desconto = 0.0;

      // 5) Define o valor do desconto com base na quantidade de apólices ativas.
      if (count >= 3) {
        // Se o utilizador tiver 3 ou mais apólices ativas, desconto é de 10%.
        desconto = 0.10;
      } else if (count >= 2) {
        // Se tiver 2 apólices ativas, desconto é de 5%.
        desconto = 0.05;
      }

      // 6) Aplica o desconto, se existir, a cada valor introduzido.
      if (desconto > 0.0) {
        valoresSeguradoras.forEach((segId, valorBase) {
          final valorComDesconto = valorBase * (1 - desconto);
          valoresSeguradoras[segId] = valorComDesconto;
        });
      }

      // 7) Atualiza o documento do orçamento no Firestore, atribuindo o mapa de valoresSeguradoras,
      // definindo 'status' como 'respondido' e guardando o desconto aplicado.
      await FirebaseFirestore.instance
          .collection('orcamentos')
          .doc(widget.orcamentoId)
          .update({
        'valoresSeguradoras': valoresSeguradoras,
        'status': 'respondido',
        'descontoAplicado': desconto,
      });

      // Mostra mensagem de sucesso e volta ao ecrã anterior.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orçamento respondido com sucesso.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Em caso de erro, mostra uma mensagem com informação adicional.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar resposta: $e')),
      );
    }

    // Desativa o estado de carregamento, se o widget ainda estiver montado.
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  /// Liberta os recursos dos controladores de texto quando o widget é removido.
  @override
  void dispose() {
    for (var c in valoresControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Método que constrói o widget principal do ecrã de resposta ao orçamento.
  @override
  Widget build(BuildContext context) {
    // Se ainda está a carregar dados, mostra um ecrã de carregamento.
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Se não foi possível carregar o documento, mostra uma mensagem de erro.
    if (orcamentoData == null) {
      return const Scaffold(
        body: Center(child: Text('Erro ao carregar o orçamento')),
      );
    }

    // Obtém o tipo de seguro dos dados do orçamento.
    final tipoSeguro =
        orcamentoData!['tipoSeguro'] as String? ?? 'Desconhecido';

    // Widget que apresentará os detalhes do orçamento, conforme o tipo de seguro.
    Widget detalhesTipo;

    switch (tipoSeguro) {
      case 'Habitação':
        final morada = (orcamentoData!['morada'] ?? '').toString();
        final anoConstrucao = orcamentoData!['anoConstrucao']?.toString() ?? '';
        detalhesTipo = Text(
          'Habitação\nMorada: $morada\nAno de Construção: $anoConstrucao',
          style: const TextStyle(fontSize: 16),
        );
        break;

      case 'Vida':
        final anoNascimento = orcamentoData!['anoNascimento']?.toString() ?? '';
        final historico = (orcamentoData!['historicoDoencas'] ?? '').toString();
        detalhesTipo = Text(
          'Vida\nAno Nascimento: $anoNascimento\nHistórico: $historico',
          style: const TextStyle(fontSize: 16),
        );
        break;

      case 'Automóvel':
        final marca = (orcamentoData!['marca'] ?? '').toString();
        final modelo = (orcamentoData!['modelo'] ?? '').toString();
        final anoFabrico = orcamentoData!['anoFabrico']?.toString() ?? '';
        detalhesTipo = Text(
          'Automóvel\nMarca: $marca\nModelo: $modelo\nAno Fabrico: $anoFabrico',
          style: const TextStyle(fontSize: 16),
        );
        break;

      case 'Trabalho':
        final nomeEmpresa = (orcamentoData!['nomeEmpresa'] ?? '').toString();
        final moradaEmpresa =
            (orcamentoData!['moradaEmpresa'] ?? '').toString();
        final setorEmpresa = (orcamentoData!['setorEmpresa'] ?? '').toString();
        detalhesTipo = Text(
          'Trabalho\nEmpresa: $nomeEmpresa\nMorada: $moradaEmpresa\nSetor: $setorEmpresa',
          style: const TextStyle(fontSize: 16),
        );
        break;

      default:
        detalhesTipo = const Text(
          'Tipo não reconhecido.',
          style: TextStyle(fontSize: 16),
        );
    }

    // Constrói o ecrã principal.
    return Scaffold(
      appBar: AppBar(
        title: Text('Responder Orçamento ($tipoSeguro)'),
        backgroundColor: Colors.blueAccent,
      ),
      // Espaçamento interno para o conteúdo.
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Mostra os detalhes específicos do tipo de seguro.
            detalhesTipo,
            const SizedBox(height: 24),
            const Text(
              'Insira valores para cada seguradora:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Formulário para introduzir valores para cada seguradora, usando uma ListView.
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  // Para cada seguradora, cria um campo de texto para inserir o valor do seguro.
                  children: valoresControllers.entries.map((entry) {
                    final segId = entry.key; // ID da seguradora
                    final ctrl = entry.value; // TextEditingController
                    // Obtém o nome da seguradora a partir do mapa seguradoraIdToName.
                    final segNome = seguradoraIdToName[segId] ?? 'Seguradora';

                    // Cada campo de texto para inserir o valor.
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: ctrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Valor para Seguradora $segNome',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(
                                12.0), // Espaçamento para alinhar o símbolo
                            child: Text(
                              '€',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        // Validação básica: não pode estar vazio e tem de ser número.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira um valor';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Por favor, insira um valor válido';
                          }
                          return null;
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Botão para salvar a resposta ou indicador de carregamento.
            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _salvarResposta,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar Resposta'),
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
    );
  }
}

// Trabalho realizado por:
// -> Miguel Magalhães;
// -> Nº:2021103166;
// -> Unidade Curricular de Computação Móvel;
// -> Licenciatura em Engenharia informática;
// -> ISPGAYA
