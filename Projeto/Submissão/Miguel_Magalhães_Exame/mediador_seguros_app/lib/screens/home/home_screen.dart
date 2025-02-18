// lib/screens/home/home_screen.dart

// Importação da biblioteca firebase_auth para gerir a autenticação de utilizadores no Firebase.
import 'package:firebase_auth/firebase_auth.dart';
// Importação da biblioteca flutter/material.dart para construir a interface de utilizador.
import 'package:flutter/material.dart';
// Importa a tela (screen) de login.
import 'package:mediador_seguros_app/screens/login/login_screen.dart';
// Importa o serviço de autenticação personalizado.
import 'package:mediador_seguros_app/services/auth_service.dart';
// Importa o widget de Menu Lateral (Drawer).
import 'package:mediador_seguros_app/widgets/main_drawer.dart';
// Importa o ficheiro principal, onde é gerido o tema (claro/escuro).
import 'package:mediador_seguros_app/main.dart';

// Importações das telas a serem apresentadas no body consoante o tipo de utilizador (mediador ou cliente).
import 'package:mediador_seguros_app/screens/mediador/seguradoras_list_screen.dart';
import 'package:mediador_seguros_app/screens/mediador/pedidos_orcamento_list_screen.dart';
import 'package:mediador_seguros_app/screens/mediador/apolices_ativas_mediador_screen.dart';
import 'package:mediador_seguros_app/screens/cliente/pedir_orcamento_screen.dart';
import 'package:mediador_seguros_app/screens/cliente/ver_orcamentos_screen.dart';
import 'package:mediador_seguros_app/screens/cliente/apolices_ativas_cliente_screen.dart';

/// [HomeScreen] é a tela principal, onde se decide o que mostrar consoante
/// o tipo de utilizador (mediador ou cliente).
class HomeScreen extends StatefulWidget {
  /// Construtor padrão, sem receber parâmetros além de super.key.
  const HomeScreen({super.key});

  /// Cria o estado para o [HomeScreen].
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Classe que gere o estado da [HomeScreen].
class _HomeScreenState extends State<HomeScreen> {
  // Instancia o serviço de autenticação personalizado.
  final AuthService _authService = AuthService();
  // Guarda o papel (role) do utilizador, que pode ser 'mediador' ou 'cliente'.
  String? _role;
  // Variável para mostrar um indicador de carregamento enquanto obtemos a role do utilizador.
  bool _loading = true;

  /// Método chamado ao iniciar o widget, chama o _checkRole para determinar a role do utilizador.
  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  /// Método assíncrono que verifica o papel do utilizador, redirecionando
  /// para a tela de login se não estiver autenticado.
  Future<void> _checkRole() async {
    // Obtém o utilizador atualmente autenticado.
    final user = FirebaseAuth.instance.currentUser;
    // Se não existir utilizador autenticado, envia-o para a tela de Login.
    if (user == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }
    // Obtém a role (papel) do utilizador através do AuthService.
    final role = await _authService.getUserRole(user.uid);
    // Define o estado interno com a role do utilizador e para de carregar.
    if (mounted) {
      setState(() {
        _role = role;
        _loading = false;
      });
    }
  }

  /// Método assíncrono para efetuar o logout do utilizador.
  Future<void> _logout() async {
    // Chama o método signOut no serviço de autenticação.
    await _authService.signOut();
    // Após sair, direciona o utilizador para a tela de Login.
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  /// Método principal de construção (build) da interface.
  @override
  Widget build(BuildContext context) {
    // Se ainda estamos a carregar a role do utilizador, mostra um CircularProgressIndicator.
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Verifica se o tema atual é modo escuro (dark).
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Retorna o Scaffold principal da HomeScreen.
    return Scaffold(
      // AppBar com título e botão de logout no canto superior direito.
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),

      // Drawer lateral (MainDrawer) com a opção de mudar o tema.
      drawer: MainDrawer(
        isDarkMode: isDarkMode,
        onThemeChanged: (bool value) {
          // Obtém a referência para o estado de MediadorSegurosAppState e chama o método toggleTheme.
          final appState =
              context.findAncestorStateOfType<MediadorSegurosAppState>();
          if (appState != null) {
            appState.toggleTheme(value);
          }
        },
      ),

      // Corpo principal da HomeScreen. Verifica se o utilizador é 'mediador' ou não (assume-se 'cliente').
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // Se o papel for mediador, mostra um conjunto de opções diferentes.
        child: _role == 'mediador'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ícone grande no topo que simboliza um mediador (business_center).
                  const Icon(
                    Icons.business_center,
                    size: 100,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 20),
                  // Texto de boas-vindas ao mediador.
                  const Text(
                    'Bem-vindo Mediador!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Use o menu ou selecione uma opção abaixo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),

                  // Opções para o mediador.
                  // 1) Seguradoras
                  _buildBigOptionCard(
                    icon: Icons.apartment,
                    title: 'Seguradoras',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SeguradorasListScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // 2) Pedidos de Orçamento
                  _buildBigOptionCard(
                    icon: Icons.request_quote,
                    title: 'Pedidos de Orçamento',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PedidosOrcamentoListScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // 3) Apólices Ativas
                  _buildBigOptionCard(
                    icon: Icons.assignment,
                    title: 'Apólices Ativas',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ApolicesAtivasMediadorScreen(),
                        ),
                      );
                    },
                  ),
                ],
              )
            : // Caso contrário, assume-se que o papel é 'cliente'.
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ícone grande no topo que simboliza um cliente (person).
                  const Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 20),
                  // Texto de boas-vindas ao cliente.
                  const Text(
                    'Bem-vindo Cliente!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Use o menu ou selecione uma opção abaixo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),

                  // Opções para o cliente.
                  // 1) Pedir Orçamento
                  _buildBigOptionCard(
                    icon: Icons.attach_money,
                    title: 'Pedir Orçamento',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PedirOrcamentoScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // 2) Ver Orçamentos
                  _buildBigOptionCard(
                    icon: Icons.list,
                    title: 'Ver Orçamentos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VerOrcamentosScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // 3) Apólices Ativas
                  _buildBigOptionCard(
                    icon: Icons.assignment,
                    title: 'Apólices Ativas',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ApolicesAtivasClienteScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  /// Método auxiliar para construir um Card grande e elegante, com ícone e título,
  /// que executa uma ação [onTap] quando clicado.
  Widget _buildBigOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          // Row para posicionar o ícone à esquerda, o título ao centro e a seta (arrow_forward_ios) à direita.
          child: Row(
            children: [
              Icon(icon, size: 50, color: Colors.blueAccent),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 20,
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
