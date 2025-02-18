// lib/main.dart

// Importações necessárias para inicializar o Firebase, gerir temas, preferências de utilizador e telas.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importações das telas de Login e Home.
import 'package:mediador_seguros_app/screens/login/login_screen.dart';
import 'package:mediador_seguros_app/screens/home/home_screen.dart';

// Importações das telas do Mediador.
import 'package:mediador_seguros_app/screens/mediador/seguradoras_list_screen.dart';
import 'package:mediador_seguros_app/screens/mediador/pedidos_orcamento_list_screen.dart';
import 'package:mediador_seguros_app/screens/mediador/apolices_ativas_mediador_screen.dart';

// Importações das telas do Cliente.
import 'package:mediador_seguros_app/screens/cliente/pedir_orcamento_screen.dart';
import 'package:mediador_seguros_app/screens/cliente/ver_orcamentos_screen.dart';
import 'package:mediador_seguros_app/screens/cliente/apolices_ativas_cliente_screen.dart';

// Importação da tela Splash.
import 'package:mediador_seguros_app/screens/splash/splash_screen.dart';

/// Ponto de entrada principal da aplicação.
void main() async {
  // Garante que os widgets estejam vinculados antes de prosseguir.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as opções para a plataforma corrente.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Carrega a preferência de tema (Dark/Light) antes de iniciar a aplicação.
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  // Executa a aplicação Flutter, passando a preferência de tema.
  runApp(MediadorSegurosApp(isDarkMode: isDarkMode));
}

/// Classe principal da aplicação, que recebe a preferência de tema (Dark/Light).
class MediadorSegurosApp extends StatefulWidget {
  /// Indica se o tema escuro está ativo.
  final bool isDarkMode;

  /// Construtor que recebe a preferência de tema.
  const MediadorSegurosApp({Key? key, required this.isDarkMode})
      : super(key: key);

  @override
  State<MediadorSegurosApp> createState() => MediadorSegurosAppState();
}

/// Estado da classe [MediadorSegurosApp], responsável por gerir o tema e as rotas.
class MediadorSegurosAppState extends State<MediadorSegurosApp> {
  // Indica o estado atual do tema (escuro ou claro).
  late bool _isDarkMode;

  /// Método chamado ao inicializar o widget pela primeira vez.
  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  /// Alterna entre tema claro e escuro, atualizando as preferências do utilizador.
  void toggleTheme(bool isDark) async {
    setState(() {
      _isDarkMode = isDark;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  /// Método principal que constrói a aplicação com o tema selecionado.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mediador Seguros',
      debugShowCheckedModeBanner: false,
      // Aplica o tema de acordo com o estado atual (_isDarkMode).
      theme: _isDarkMode ? _darkTheme : _lightTheme,

      // Define a rota inicial como a SplashScreen.
      initialRoute: '/splash',
      // Mapa de rotas para navegação interna.
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),

        // Rotas específicas do Mediador.
        '/seguradoras': (context) => const SeguradorasListScreen(),
        '/pedidosOrcamento': (context) => const PedidosOrcamentoListScreen(),
        '/apolicesAtivasMediador': (context) =>
            const ApolicesAtivasMediadorScreen(),

        // Rotas específicas do Cliente.
        '/pedirOrcamento': (context) => const PedirOrcamentoScreen(),
        '/verOrcamentos': (context) => const VerOrcamentosScreen(),
        '/apolicesAtivasCliente': (context) =>
            const ApolicesAtivasClienteScreen(),
      },
    );
  }

  /// Tema claro (Light Theme).
  ThemeData get _lightTheme => ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.white,
      );

  /// Tema escuro (Dark Theme).
  ThemeData get _darkTheme => ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.grey[800],
      );
}

// Trabalho realizado por:
// -> Miguel Magalhães;
// -> Nº:2021103166;
// -> Unidade Curricular de Computação Móvel;
// -> Licenciatura em Engenharia informática;
// -> ISPGAYA
