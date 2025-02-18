// Ficheiro gerado pela FlutterFire CLI.
// ignore_for_file: type=lint

// Importação do pacote firebase_core para inicialização do Firebase.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
// Importação de bibliotecas Flutter para verificar a plataforma-alvo e se é web.
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Classe com as configurações [FirebaseOptions] por defeito (Default) para utilizar com as apps Firebase.
///
/// Exemplo de uso:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  /// Devolve as [FirebaseOptions] actuais com base na plataforma.
  static FirebaseOptions get currentPlatform {
    // Verifica se a app está a ser executada na web.
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions não foram configuradas para web - '
        'poderá reconfigurar isto executando novamente o FlutterFire CLI.',
      );
    }
    // Verifica a plataforma alvo (Android, iOS, etc.).
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions não foram configuradas para macOS - '
          'poderá reconfigurar isto executando novamente o FlutterFire CLI.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions não foram configuradas para Windows - '
          'poderá reconfigurar isto executando novamente o FlutterFire CLI.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions não foram configuradas para Linux - '
          'poderá reconfigurar isto executando novamente o FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não são suportadas para esta plataforma.',
        );
    }
  }

  /// Opções de configuração do Firebase para Android.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD1CXgOljQD0JjmP216FKVP9JInqXEb4_M',
    appId: '1:706347410826:android:d22368f556fcc8a80e5473',
    messagingSenderId: '706347410826',
    projectId: 'mediadordeseguros-1cac5',
    storageBucket: 'mediadordeseguros-1cac5.firebasestorage.app',
  );

  /// Opções de configuração do Firebase para iOS.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA8vNDaCyXuwYlS46HuRqoJe5ttUuOz4oE',
    appId: '1:706347410826:ios:e4fdb32f7e06cfef0e5473',
    messagingSenderId: '706347410826',
    projectId: 'mediadordeseguros-1cac5',
    storageBucket: 'mediadordeseguros-1cac5.firebasestorage.app',
    iosBundleId: 'com.example.mediadorSegurosApp',
  );
}

// Trabalho realizado por:
// -> Miguel Magalhães;
// -> Nº:2021103166;
// -> Unidade Curricular de Computação Móvel;
// -> Licenciatura em Engenharia informática;
// -> ISPGAYA
