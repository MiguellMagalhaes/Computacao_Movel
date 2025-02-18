// lib/screens/cliente/pedir_orcamento_screen.dart

// Importação das bibliotecas necessárias para funcionamento do Firestore, Autenticação,
// widgets do Material Design e serviços de API externos (CarApiService e OpenWeatherService).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Importação para a API do Carro.
import 'package:mediador_seguros_app/services/car_api_service.dart';
// Importação para a API de Clima.
import 'package:mediador_seguros_app/services/openweather_service.dart';

// Widget com estado que representa a tela para o cliente pedir um orçamento.
class PedirOrcamentoScreen extends StatefulWidget {
  // Construtor padrão, sem parâmetros adicionais, além de super.key.
  const PedirOrcamentoScreen({super.key});

  // Cria o estado para o widget [PedirOrcamentoScreen].
  @override
  State<PedirOrcamentoScreen> createState() => _PedirOrcamentoScreenState();
}

// Classe que gere o estado de [PedirOrcamentoScreen].
class _PedirOrcamentoScreenState extends State<PedirOrcamentoScreen> {
  // Estado inicial do tipo de seguro selecionado, por omissão 'Habitação'.
  String _tipoSelecionado = 'Habitação';

  // Controladores de texto para recolher dados do formulário de acordo com o tipo de seguro.
  final _moradaController = TextEditingController();
  final _anoConstrucaoController = TextEditingController();
  final _anoNascimentoController = TextEditingController();
  final _historicoDoencasController = TextEditingController();
  final _anoFabricoController = TextEditingController();

  // Listas e variáveis para o tipo "Automóvel".
  List<String> _marcas = [];
  String? _marcaSelecionada;
  List<String> _modelos = [];
  String? _modeloSelecionado;
  bool _carregandoMarcas = false;
  bool _carregandoModelos = false;

  // Controladores de texto para o tipo "Trabalho".
  final _nomeEmpresaController = TextEditingController();
  final _moradaEmpresaController = TextEditingController();
  final _setorEmpresaController = TextEditingController();

  // Variável de controlo de carregamento para feedback ao utilizador.
  bool _loading = false;

  // Chave global para validar o formulário.
  final _formKey = GlobalKey<FormState>();

  // Para a segunda API (OpenWeather) quando for tipo "Habitação".
  final _cidadeController = TextEditingController();
  // Objecto que receberá os dados do clima.
  Map<String, dynamic>? _weatherData;

  // Método que limpa os controladores quando o widget deixa de existir (boa prática).
  @override
  void dispose() {
    _moradaController.dispose();
    _anoConstrucaoController.dispose();
    _anoNascimentoController.dispose();
    _historicoDoencasController.dispose();
    _anoFabricoController.dispose();
    _nomeEmpresaController.dispose();
    _moradaEmpresaController.dispose();
    _setorEmpresaController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  // Carrega a lista de marcas caso o tipo selecionado seja "Automóvel".
  Future<void> _carregarMarcasSeNecessario() async {
    // Verifica se o tipo selecionado é "Automóvel", a lista de marcas está vazia
    // e ainda não foi iniciado o carregamento.
    if (_tipoSelecionado == 'Automóvel' &&
        _marcas.isEmpty &&
        !_carregandoMarcas) {
      if (!mounted) return;
      setState(() {
        _carregandoMarcas = true;
      });
      try {
        // Chama a CarApiService para obter a lista de marcas.
        final marcas = await CarApiService.getCarMakes();
        if (mounted) {
          setState(() {
            _marcas = marcas;
          });
        }
      } catch (e) {
        // Em caso de erro, mostra uma mensagem.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar marcas: $e')),
          );
        }
      }
      // Finaliza o carregamento, permitindo ao UI voltar ao estado normal.
      if (mounted) {
        setState(() {
          _carregandoMarcas = false;
        });
      }
    }
  }

  // Carrega a lista de modelos para a marca selecionada no tipo "Automóvel".
  Future<void> _carregarModelosParaMarca(String make) async {
    if (!mounted) return;
    setState(() {
      _carregandoModelos = true;
      _modelos = [];
      _modeloSelecionado = null;
    });
    try {
      // Chama a CarApiService para obter a lista de modelos da marca.
      final models = await CarApiService.getModelsForMake(make.toLowerCase());
      if (mounted) {
        setState(() {
          _modelos = models;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar modelos: $e')),
        );
      }
    }
    if (mounted) {
      setState(() {
        _carregandoModelos = false;
      });
    }
  }

  // Método para buscar o clima através do OpenWeather, específico para o tipo "Habitação".
  Future<void> _buscarClima() async {
    // Verifica se o campo cidade está preenchido.
    if (_cidadeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira uma cidade.')),
      );
      return;
    }

    // Busca os dados de clima via OpenWeatherService.
    final data =
        await OpenWeatherService.fetchWeather(_cidadeController.text.trim());
    if (data != null) {
      setState(() {
        _weatherData = data;
      });
    } else {
      // Caso não seja possível obter o clima, exibe um alerta.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível obter o clima.')),
      );
    }
  }

  // Constrói os campos específicos de cada tipo de seguro, retornando um widget apropriado.
  Widget _camposEspecificos() {
    switch (_tipoSelecionado) {
      case 'Habitação':
        // Campos específicos para seguro de Habitação.
        return Column(
          children: [
            // Campos para a segunda API (OpenWeather) - cidade e botão "Ver Clima".
            TextFormField(
              controller: _cidadeController,
              decoration: const InputDecoration(
                labelText: 'Cidade da Habitação',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _buscarClima,
              child: const Text('Ver Clima'),
            ),
            // Se já foi buscado algum dado de clima, mostra as informações.
            if (_weatherData != null) ...[
              const SizedBox(height: 8),
              Text(
                'Clima em ${_weatherData!["name"]}:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Temperatura: ${_weatherData!["main"]["temp"]}°C'),
              Text('Descrição: ${_weatherData!["weather"][0]["description"]}'),
              const SizedBox(height: 16),
            ],
            // Campo para Morada.
            TextFormField(
              controller: _moradaController,
              decoration: const InputDecoration(
                labelText: 'Morada',
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a morada';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Campo para Ano de Construção.
            TextFormField(
              controller: _anoConstrucaoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ano de Construção',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                // Validação: o valor não pode ser maior que o ano atual.
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um ano válido';
                }
                final ano = int.tryParse(value);
                if (ano == null) {
                  return 'Por favor, insira um ano numérico';
                }
                final anoAtual = DateTime.now().year;
                if (ano > anoAtual) {
                  return 'O ano de construção não pode ser maior que $anoAtual';
                }
                return null;
              },
            ),
          ],
        );

      case 'Vida':
        // Campos específicos para seguro de Vida.
        return Column(
          children: [
            // Ano de Nascimento.
            TextFormField(
              controller: _anoNascimentoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ano de Nascimento',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                // Verifica se o campo foi preenchido e se é um valor numérico.
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) == null) {
                  return 'Por favor, insira um ano válido';
                }
                final ano = int.parse(value);
                final anoAtual = DateTime.now().year;
                final idade = anoAtual - ano;

                // Limita a idade a 100 anos.
                if (idade > 100) {
                  return 'Não é permitido ter mais de 100 anos.';
                }
                // Verifica se o ano não é maior que o atual.
                if (idade < 0) {
                  return 'O ano não pode ser maior que o atual.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            // Histórico de Doenças.
            TextFormField(
              controller: _historicoDoencasController,
              decoration: const InputDecoration(
                labelText: 'Histórico de Doenças',
                prefixIcon: Icon(Icons.medical_services),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o histórico de doenças';
                }
                return null;
              },
            ),
          ],
        );

      case 'Automóvel':
        // Campos específicos para seguro Automóvel.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown de Marcas. Caso esteja a carregar as marcas, apresenta um indicador de progresso.
            _carregandoMarcas
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Selecione a Marca',
                      prefixIcon: Icon(Icons.directions_car),
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    value: _marcaSelecionada,
                    items: _marcas
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) async {
                      if (mounted) {
                        setState(() {
                          _marcaSelecionada = val;
                        });
                      }
                      // Carrega os modelos para a marca selecionada.
                      if (val != null) {
                        await _carregarModelosParaMarca(val);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione uma marca';
                      }
                      return null;
                    },
                  ),
            const SizedBox(height: 16),
            // Dropdown de Modelos para a marca selecionada.
            if (_marcaSelecionada != null)
              _carregandoModelos
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Selecione o Modelo',
                        prefixIcon: Icon(Icons.directions_car_filled),
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      hint: const Text('Selecione o Modelo'),
                      value: _modeloSelecionado,
                      items: _modelos
                          .map((md) =>
                              DropdownMenuItem(value: md, child: Text(md)))
                          .toList(),
                      onChanged: (val) {
                        if (mounted) {
                          setState(() {
                            _modeloSelecionado = val;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione um modelo';
                        }
                        return null;
                      },
                    ),
            const SizedBox(height: 16),
            // Ano de Fabrico.
            TextFormField(
              controller: _anoFabricoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ano de Fabrico',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                // Verifica se o ano está entre 1950 e 2025.
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um ano válido';
                }
                final ano = int.tryParse(value);
                if (ano == null) {
                  return 'Por favor, insira um ano numérico';
                }
                if (ano < 1950 || ano > 2025) {
                  return 'O ano de fabrico deve estar entre 1950 e 2025';
                }
                return null;
              },
            ),
          ],
        );

      case 'Trabalho':
        // Campos específicos para seguro de Trabalho.
        return Column(
          children: [
            // Nome da Empresa.
            TextFormField(
              controller: _nomeEmpresaController,
              decoration: const InputDecoration(
                labelText: 'Nome da Empresa',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o nome da empresa';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Morada da Empresa.
            TextFormField(
              controller: _moradaEmpresaController,
              decoration: const InputDecoration(
                labelText: 'Morada da Empresa',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a morada da empresa';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Setor da Empresa.
            TextFormField(
              controller: _setorEmpresaController,
              decoration: const InputDecoration(
                labelText: 'Setor da Empresa',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o setor da empresa';
                }
                return null;
              },
            ),
          ],
        );

      // Caso o tipo selecionado não seja um dos acima, retorna um widget vazio.
      default:
        return const SizedBox();
    }
  }

  // Método assíncrono que envia o pedido de orçamento para o Firestore.
  Future<void> _pedirOrcamento() async {
    // Valida o formulário através das regras de validação definidas em cada campo.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    // Verifica se existe um utilizador autenticado.
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não logado')),
        );
        setState(() {
          _loading = false;
        });
      }
      return;
    }

    // Mapa de dados que será enviado para o Firestore.
    final data = {
      'userId': user.uid,
      'tipoSeguro': _tipoSelecionado,
      'status': 'pendente',
    };

    // Adiciona campos específicos dependendo do tipo de seguro selecionado.
    switch (_tipoSelecionado) {
      case 'Habitação':
        data['morada'] = _moradaController.text.trim();
        data['anoConstrucao'] =
            int.tryParse(_anoConstrucaoController.text.trim())?.toString() ??
                '';
        data['cidade'] = _cidadeController.text.trim();
        break;

      case 'Vida':
        data['anoNascimento'] =
            int.tryParse(_anoNascimentoController.text.trim())?.toString() ??
                '';
        data['historicoDoencas'] = _historicoDoencasController.text.trim();
        break;

      case 'Automóvel':
        // Verifica se marca, modelo e ano de fabrico estão preenchidos.
        if (_marcaSelecionada == null ||
            _modeloSelecionado == null ||
            _anoFabricoController.text.trim().isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Selecione marca, modelo e ano de fabrico'),
              ),
            );
            setState(() {
              _loading = false;
            });
          }
          return;
        }
        data['marca'] = _marcaSelecionada!;
        data['modelo'] = _modeloSelecionado!;
        data['anoFabrico'] =
            int.tryParse(_anoFabricoController.text.trim())?.toString() ?? '';
        break;

      case 'Trabalho':
        data['nomeEmpresa'] = _nomeEmpresaController.text.trim();
        data['moradaEmpresa'] = _moradaEmpresaController.text.trim();
        data['setorEmpresa'] = _setorEmpresaController.text.trim();
        break;
    }

    // Adiciona o documento na colecção 'orcamentos' do Firestore.
    await FirebaseFirestore.instance.collection('orcamentos').add(data);

    if (!mounted) return;
    setState(() {
      _loading = false;
    });

    // Mostra um feedback ao utilizador e retorna para a tela anterior.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Orçamento solicitado com sucesso!')),
    );
    Navigator.pop(context);
  }

  // Método build que constrói o ecrã principal.
  @override
  Widget build(BuildContext context) {
    // Se o tipo selecionado for "Automóvel", tentamos carregar as marcas se necessário.
    if (_tipoSelecionado == 'Automóvel') {
      _carregarMarcasSeNecessario();
    }

    // Estrutura de página principal com AppBar e formulário para pedir orçamento.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedir Orçamento'),
        backgroundColor: Colors.blueAccent,
      ),
      // SingleChildScrollView permite que o utilizador faça scroll caso o conteúdo seja extenso.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // Form principal com chave global de validação.
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Dropdown para escolher o tipo de seguro.
              DropdownButtonFormField<String>(
                value: _tipoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Seguro',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Habitação', child: Text('Habitação')),
                  DropdownMenuItem(value: 'Vida', child: Text('Vida')),
                  DropdownMenuItem(
                      value: 'Automóvel', child: Text('Automóvel')),
                  DropdownMenuItem(value: 'Trabalho', child: Text('Trabalho')),
                ],
                onChanged: (val) {
                  // Atualiza o estado quando o utilizador muda o tipo selecionado.
                  if (mounted && val != null) {
                    setState(() {
                      _tipoSelecionado = val;
                      // Se deixar de ser "Automóvel", limpa as variáveis correspondentes.
                      if (_tipoSelecionado != 'Automóvel') {
                        _marcaSelecionada = null;
                        _modeloSelecionado = null;
                        _marcas.clear();
                        _modelos.clear();
                      }
                      // Reseta a informação do clima caso já tenha sido carregada para Habitação.
                      _weatherData = null;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione um tipo de seguro';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Constrói dinamicamente os campos específicos conforme o tipo de seguro.
              _camposEspecificos(),
              const SizedBox(height: 20),
              // Botão para enviar o pedido ou indicador de carregamento.
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _pedirOrcamento,
                      icon: const Icon(Icons.send),
                      label: const Text('Enviar Pedido'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
