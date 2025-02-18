// Importação do pacote de material design para Flutter, que contém componentes UI
// como botões, barras de navegação e outros widgets úteis para design.
// ignore_for_file: unused_import

import 'package:flutter/material.dart';

// Importação do pacote Firebase para inicialização do Firebase na aplicação.
import 'package:firebase_core/firebase_core.dart';

// Importação das opções de configuração do Firebase para diferentes plataformas.
import 'package:food_delivery_app/firebase_options.dart';

// Importação do modelo de dados 'restaurant', que representa um restaurante na aplicação.
import 'package:food_delivery_app/models/restaurant.dart';

// Importação do widget 'auth_gate' para controle de autenticação (login ou registro).
import 'package:food_delivery_app/services/auth/auth_gate.dart';

// Importação do 'provider', utilizado para gerenciar o estado da aplicação de forma eficiente.
import 'package:provider/provider.dart';

// Importação do arquivo que contém a lógica de autenticação, permitindo login ou registro.
import 'services/auth/login_or_register.dart';

// Importação do provedor de tema para controlar a aparência global da aplicação.
import 'theme/theme_provider.dart';

// Função principal que inicia a aplicação.
void main() async {
  // Garante que a inicialização do widget binding esteja pronta antes de rodar o app.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as configurações específicas para a plataforma em execução.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicia o aplicativo, utilizando o MultiProvider para gerenciar múltiplos provedores de estado.
  runApp(
    MultiProvider(
      // Lista de provedores a serem utilizados na aplicação.
      providers: [
        // Provedor de estado para controlar e fornecer o tema da aplicação.
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        // Provedor de estado para gerenciar os dados do restaurante.
        ChangeNotifierProvider(create: (context) => Restaurant()),
      ],
      // Define o widget raiz da aplicação, que é o MyApp.
      child: const MyApp(),
    ), // MultiProvider
  );
}

// Classe principal do aplicativo, que é um StatelessWidget.
// StatelessWidget significa que a UI dessa classe não muda após ser construída.
class MyApp extends StatelessWidget {
  // Construtor da classe.
  const MyApp({super.key});

  @override
  // Método que constrói o widget da aplicação.
  Widget build(BuildContext context) {
    // Retorna um MaterialApp, que é o widget raiz da aplicação.
    return MaterialApp(
      // Desativa o banner de modo de debug (o banner "debug" no canto superior direito).
      debugShowCheckedModeBanner: false,
      // Define a tela inicial da aplicação como o widget 'AuthGate' (controle de autenticação).
      home: const AuthGate(),
      // Define o tema global da aplicação com base no ThemeProvider.
      theme: Provider.of<ThemeProvider>(context).themeData,
    ); // MaterialApp
  }
}

// Projeto de Computação Móvel: Delivery App
// Trabalho realizado por:
// -> Miguel Magalhães, Nº2021103166;
// -> Fábio Sequeira, Nº2022102906.
// ISPGAYA