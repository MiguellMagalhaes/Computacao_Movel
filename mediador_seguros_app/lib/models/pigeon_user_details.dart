// Importação do pacote foundation do Flutter, que disponibiliza, entre outros, a anotação @immutable.
import 'package:flutter/foundation.dart';

/// Representa os detalhes do utilizador (usuário).
@immutable
class PigeonUserDetails {
  /// O email do utilizador.
  final String email;

  /// O papel do utilizador (e.g., 'cliente', 'mediador').
  final String role;

  /// Construtor constante para [PigeonUserDetails].
  /// Utiliza os parâmetros obrigatórios `email` e `role`.
  const PigeonUserDetails({
    required this.email,
    required this.role,
  });

  /// Cria uma instância de [PigeonUserDetails] a partir de um mapa.
  /// Caso os valores 'email' ou 'role' não existam no mapa, é atribuído '' (string vazia).
  factory PigeonUserDetails.fromMap(Map<String, dynamic> map) {
    return PigeonUserDetails(
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? '',
    );
  }

  /// Converte a instância de [PigeonUserDetails] para um mapa.
  /// Retorna um `Map<String, dynamic>` com as chaves 'email' e 'role'.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
    };
  }

  /// Sobrescreve o método [toString] para retornar uma string
  /// representativa do objeto [PigeonUserDetails].
  @override
  String toString() => 'PigeonUserDetails(email: $email, role: $role)';

  /// Sobrescreve o operador de igualdade para comparar instâncias de [PigeonUserDetails].
  @override
  bool operator ==(Object other) {
    // Verifica se são a mesma instância.
    if (identical(this, other)) return true;

    // Verifica se 'other' é do tipo PigeonUserDetails e compara os campos 'email' e 'role'.
    return other is PigeonUserDetails &&
        other.email == email &&
        other.role == role;
  }

  /// Sobrescreve o método [hashCode] para garantir que objetos
  /// com o mesmo 'email' e 'role' produzam o mesmo hash.
  @override
  int get hashCode => email.hashCode ^ role.hashCode;
}

// Trabalho realizado por:
// -> Miguel Magalhães;
// -> Nº:2021103166;
// -> Unidade Curricular de Computação Móvel;
// -> Licenciatura em Engenharia informática;
// -> ISPGAYA
