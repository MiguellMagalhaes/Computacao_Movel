// lib/widgets/main_drawer.dart

// Importa a biblioteca flutter/material.dart para usar widgets do Material Design.
import 'package:flutter/material.dart';
// Importa a tela de Configurações (SettingsScreen).
import 'package:mediador_seguros_app/screens/settings/settings_screen.dart';

/// Widget que representa o Drawer principal da aplicação.
/// Apresenta apenas uma opção para abrir as Configurações.
class MainDrawer extends StatelessWidget {
  // Indica se o tema atual está em modo escuro (dark mode).
  final bool isDarkMode;
  // Função que será chamada quando o tema for alterado.
  final Function(bool) onThemeChanged;

  /// Construtor que recebe [isDarkMode] e [onThemeChanged] como parâmetros obrigatórios.
  const MainDrawer({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  /// Método que constrói o widget Drawer.
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Drawer principal com uma ListView de itens.
      child: ListView(
        children: [
          // Cabeçalho do Drawer, com gradiente de cor e ícone de configurações.
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            // Coluna central que apresenta ícone e texto.
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.settings,
                  size: 64,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  'Configurações',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Única opção do Drawer: abrir a tela de Configurações.
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Abrir Configurações'),
            onTap: () {
              // Fecha o Drawer.
              Navigator.pop(context);
              // Navega para a tela de configurações (SettingsScreen).
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    isDarkMode: isDarkMode,
                    onThemeChanged: onThemeChanged,
                    userRole: '',
                  ),
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
