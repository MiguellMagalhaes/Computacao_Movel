// lib/services/auth_service.dart

// Importação das bibliotecas necessárias para utilizar o Firestore e a autenticação Firebase,
// além de importar o modelo PigeonUserDetails.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediador_seguros_app/models/pigeon_user_details.dart';

/// Classe que gere a autenticação e o registo de utilizadores (clientes e mediadores),
/// bem como a obtenção de papéis (roles) e detalhes do utilizador.
class AuthService {
  // Instâncias principais para aceder ao FirebaseAuth e ao FirebaseFirestore.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Método assíncrono para login do utilizador com [email] e [password].
  /// Retorna o [User] se for bem-sucedido ou lança uma excepção caso contrário.
  Future<User?> signIn(String email, String password) async {
    try {
      // Tenta fazer signIn com email e password através do FirebaseAuth.
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // Retorna o utilizador autenticado.
      return cred.user;
    } catch (e) {
      // Lança uma excepção caso ocorra algum erro durante o login.
      throw Exception('Erro ao fazer login: $e');
    }
  }

  /// Método assíncrono para registar um novo utilizador com papel de cliente.
  /// Cria o utilizador no FirebaseAuth e depois armazena dados no Firestore
  /// para manter o papel (role) e a data de criação.
  Future<User?> registerClient(String email, String password) async {
    try {
      // Cria o utilizador no FirebaseAuth.
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // Se o utilizador foi criado com sucesso, cria um documento na colecção 'users'.
      if (cred.user != null) {
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'email': email,
          'role': 'cliente',
          'dataCriacao': FieldValue.serverTimestamp(),
        });
      }
      return cred.user;
    } catch (e) {
      // Lança uma excepção caso ocorra algum erro durante o registo.
      throw Exception('Erro ao registrar cliente: $e');
    }
  }

  /// Método assíncrono para registar um novo utilizador com papel de mediador.
  /// Similar ao [registerClient], mas define o 'role' como 'mediador'.
  Future<User?> registerMediador(String email, String password) async {
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (cred.user != null) {
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'email': email,
          'role': 'mediador',
          'dataCriacao': FieldValue.serverTimestamp(),
        });
      }
      return cred.user;
    } catch (e) {
      throw Exception('Erro ao registrar mediador: $e');
    }
  }

  /// Método para terminar a sessão do utilizador atual (logout).
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Stream que notifica sobre mudanças no estado de autenticação (por exemplo, login/logout).
  Stream<User?> get userChanges => _auth.authStateChanges();

  /// Método assíncrono para obter o papel (role) do utilizador, dada a sua [uid].
  /// Retorna uma string com o papel se existir ou null caso não encontre.
  Future<String?> getUserRole(String uid) async {
    try {
      // Obtém o documento do utilizador na colecção 'users'.
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        // Retorna o campo 'role' do documento, se existir.
        return doc.data()?['role'];
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao obter papel do usuário: $e');
    }
  }

  /// Método assíncrono para obter todos os detalhes do utilizador,
  /// retornando um objeto [PigeonUserDetails] ou null caso não encontre.
  Future<PigeonUserDetails?> getUserDetails(String uid) async {
    try {
      // Obtém o documento do utilizador na colecção 'users'.
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      // Se o documento existir e tiver dados, cria um PigeonUserDetails a partir do mapa.
      if (doc.exists && data != null) {
        return PigeonUserDetails.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao obter detalhes do usuário: $e');
    }
  }
}

// Trabalho realizado por:
// -> Miguel Magalhães;
// -> Nº:2021103166;
// -> Unidade Curricular de Computação Móvel;
// -> Licenciatura em Engenharia informática;
// -> ISPGAYA
