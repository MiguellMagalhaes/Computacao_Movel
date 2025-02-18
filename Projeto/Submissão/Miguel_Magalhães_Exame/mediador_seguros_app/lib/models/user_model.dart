// Classe que representa os detalhes de um utilizador.
class PigeonUserDetails {
  // Propriedade que guarda o email do utilizador, podendo ser nulo.
  final String? email;

  // Propriedade que guarda o papel do utilizador (e.g., 'cliente', 'mediador'), podendo ser nulo.
  final String? role;

  // Construtor para criar uma instância de [PigeonUserDetails].
  // Recebe parâmetros opcionais (poderão ser nulos).
  PigeonUserDetails({this.email, this.role});

  // Fábrica para criar uma instância de [PigeonUserDetails] a partir de um mapa.
  // Converte o valor da chave 'email' e 'role' para String e atribui-os às propriedades.
  factory PigeonUserDetails.fromMap(Map<String, dynamic> map) {
    return PigeonUserDetails(
      email: map['email'] as String?,
      role: map['role'] as String?,
    );
  }
}

// Trabalho realizado por:
// -> Miguel Magalhães;
// -> Nº:2021103166;
// -> Unidade Curricular de Computação Móvel;
// -> Licenciatura em Engenharia informática;
// -> ISPGAYA
