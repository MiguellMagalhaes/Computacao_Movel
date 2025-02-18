// Importação do pacote foundation do Flutter, que disponibiliza funcionalidades essenciais,
// incluindo a função listEquals para comparação de listas.
import 'package:flutter/foundation.dart';

/// Representa uma seguradora.
@immutable
class Seguradora {
  /// O identificador único da seguradora.
  final String id;

  /// O nome da seguradora.
  final String nome;

  /// Lista com os tipos de seguro oferecidos pela seguradora.
  final List<String> tipos;

  /// Construtor para [Seguradora], recebe os campos [id], [nome] e [tipos] como obrigatórios.
  const Seguradora({
    required this.id,
    required this.nome,
    required this.tipos,
  });

  /// Cria uma instância de [Seguradora] a partir de um mapa e um ID.
  /// O parâmetro [id] é passado separadamente, e os restantes valores
  /// são obtidos do mapa [data].
  factory Seguradora.fromMap(String id, Map<String, dynamic> data) {
    return Seguradora(
      id: id,
      // Obtém o nome da seguradora do mapa. Caso não exista ou seja nulo, atribui '' (string vazia).
      nome: data['nome'] as String? ?? '',
      // Converte o campo 'tipos' do mapa para uma List<String>. Caso não exista, utiliza uma lista vazia.
      tipos: List<String>.from(data['tipos'] ?? []),
    );
  }

  /// Converte a instância de [Seguradora] para um mapa, retornando
  /// um `Map<String, dynamic>` com as chaves 'nome' e 'tipos'.
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'tipos': tipos,
    };
  }

  /// Sobrescreve o método [toString] para fornecer uma representação de texto da instância.
  @override
  String toString() => 'Seguradora(id: $id, nome: $nome, tipos: $tipos)';

  /// Sobrescreve o operador de igualdade para comparar duas instâncias de [Seguradora].
  @override
  bool operator ==(Object other) {
    // Verifica se ambas as referências apontam para o mesmo objeto.
    if (identical(this, other)) return true;

    // Verifica se o objeto [other] é do tipo [Seguradora] e compara os atributos.
    return other is Seguradora &&
        other.id == id &&
        other.nome == nome &&
        // listEquals compara os elementos de ambas as listas.
        listEquals(other.tipos, tipos);
  }

  /// Sobrescreve o método [hashCode], assegurando que
  /// duas instâncias iguais tenham o mesmo hash.
  @override
  int get hashCode => id.hashCode ^ nome.hashCode ^ tipos.hashCode;
}

// Trabalho realizado por:
// -> Miguel Magalhães;
// -> Nº:2021103166;
// -> Unidade Curricular de Computação Móvel;
// -> Licenciatura em Engenharia informática;
// -> ISPGAYA
