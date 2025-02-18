// lib/screens/settings/settings_screen.dart

// Importação do pacote Flutter material.
import 'package:flutter/material.dart';
// Importação da tela de Informações Pessoais.
import 'package:mediador_seguros_app/screens/settings/personal_info_screen.dart';

/// Tela de configurações (Settings), onde o utilizador pode alterar o tema (claro/escuro)
/// e aceder às suas informações pessoais.
class SettingsScreen extends StatefulWidget {
  /// Indica se o modo escuro (dark mode) está activado.
  final bool isDarkMode;

  /// Função que é chamada quando o utilizador alterna entre modo claro e escuro.
  final Function(bool) onThemeChanged;

  /// Papel (role) do utilizador (e.g., 'cliente' ou 'mediador').
  final String userRole;

  /// Construtor que recebe o estado do modo escuro, a função de alteração de tema
  /// e o papel do utilizador como parâmetros obrigatórios.
  const SettingsScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.userRole,
  }) : super(key: key);

  /// Cria o estado para [SettingsScreen].
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

/// Estado de [SettingsScreen], responsável por gerir o que é exibido
/// e manusear as alterações de tema (claro/escuro).
class _SettingsScreenState extends State<SettingsScreen> {
  // Variável local para manter o estado do modo escuro.
  late bool _isDarkMode;

  /// Método chamado quando o widget é inicializado.
  @override
  void initState() {
    super.initState();
    // Atribui o valor inicial do modo escuro proveniente do widget pai.
    _isDarkMode = widget.isDarkMode;
  }

  /// Função que trata a alteração do modo escuro (escuta o SwitchListTile).
  void _handleThemeChange(bool value) {
    // Actualiza o estado local.
    setState(() {
      _isDarkMode = value;
    });
    // Notifica o widget pai ou a aplicação principal sobre a mudança de tema.
    widget.onThemeChanged(value);
  }

  /// Método que constrói (build) o widget principal da tela de configurações.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra de aplicação com título "Configurações".
      appBar: AppBar(
        title: const Text('Configurações'),
        // Define a cor de fundo com base no tema actual da aplicação.
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      // Corpo da tela organizado numa ListView.
      body: ListView(
        children: [
          // Item de toggle para Modo Escuro/Modo Claro.
          SwitchListTile(
            title: const Text('Modo Escuro'),
            secondary: Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            value: _isDarkMode,
            onChanged: _handleThemeChange,
          ),
          // Linha divisória entre opções.
          const Divider(height: 1),

          // Opção para "Informações Pessoais".
          // Ao clicar, navega para a tela [PersonalInfoScreen].
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Informações Pessoais'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PersonalInfoScreen(),
                ),
              );
            },
          ),
        ],
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
