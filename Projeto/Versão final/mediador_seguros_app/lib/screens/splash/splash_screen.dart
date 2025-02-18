// lib/screens/splash/splash_screen.dart

// Importações necessárias do Flutter, do FirebaseAuth e das telas (Login e Home).
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediador_seguros_app/screens/login/login_screen.dart';
import 'package:mediador_seguros_app/screens/home/home_screen.dart';

/// Tela (screen) inicial (SplashScreen) que aparece ao iniciar a aplicação.
/// Fica visível por alguns segundos antes de redirecionar o utilizador.
class SplashScreen extends StatefulWidget {
  /// Construtor padrão, com chave opcional.
  const SplashScreen({Key? key}) : super(key: key);

  /// Cria o estado associado a esta tela.
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// Estado da [SplashScreen].
class _SplashScreenState extends State<SplashScreen> {
  /// Método chamado quando o widget é inicializado.
  /// Agenda um Timer de 3 segundos para verificar a autenticação do utilizador.
  @override
  void initState() {
    super.initState();
    // Após 3 segundos, chama a função _checkUser para decidir se vai para Home ou Login.
    Timer(const Duration(seconds: 3), _checkUser);
  }

  /// Método que verifica se existe um utilizador autenticado.
  /// Se existir, navega para a [HomeScreen], caso contrário navega para a [LoginScreen].
  void _checkUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  /// Método que constrói o widget principal (UI) desta tela.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Define a cor de fundo como #3F6484.
      backgroundColor: const Color(0xFF3F6484),
      body: Center(
        // Coluna central com imagem e texto.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo maior (assumindo que existe em assets/images/logo.png).
            Image.asset(
              'assets/images/logo.png',
              height: 220,
            ),
            const SizedBox(height: 16),
            // Slogan em itálico, de cor branca e maior.
            const Text(
              'A sua segurança é a nossa prioridade',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontStyle: FontStyle.italic,
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
