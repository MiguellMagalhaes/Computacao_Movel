// Importa a biblioteca dart:convert para manipular dados em formato JSON.
// Importa a biblioteca http para fazer requisições HTTP.
import 'dart:convert';
import 'package:http/http.dart' as http;

// Classe que fornece métodos estáticos para interagir com a API de veículos (NHTSA).
class CarApiService {
  // URL base para as chamadas à API.
  static const _baseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles';

  /// Retorna a lista de marcas (makes) para o tipo "car".
  static Future<List<String>> getCarMakes() async {
    // Constrói a URL com o endpoint específico para marcas de carros, em formato JSON.
    final url = Uri.parse('$_baseUrl/GetMakesForVehicleType/car?format=json');
    try {
      // Faz a requisição GET à API.
      final response = await http.get(url);
      // Verifica se o código de status é 200 (OK).
      if (response.statusCode == 200) {
        // Converte a resposta do servidor de JSON para Map.
        final data = jsonDecode(response.body);
        // Extrai a lista de resultados do Map.
        final List results = data['Results'];
        // Converte cada item da lista para a string contida em 'MakeName'.
        final makes =
            results.map((item) => item['MakeName'].toString()).toList();
        // Ordena a lista de marcas por ordem alfabética.
        makes.sort((a, b) => a.toString().compareTo(b.toString()));
        // Retorna a lista convertida para List<String>.
        return List<String>.from(makes);
      } else {
        // Se o código de status não for 200, lança uma excepção com a mensagem de falha.
        throw Exception(
            'Falha ao obter marcas de carros: ${response.statusCode}');
      }
    } catch (e) {
      // Em caso de erro (e.g. problemas de rede), lança uma excepção com a mensagem de erro.
      throw Exception('Erro ao obter marcas de carros: $e');
    }
  }

  /// Retorna a lista de modelos para uma dada marca (make).
  static Future<List<String>> getModelsForMake(String makeName) async {
    // Constrói a URL para obter os modelos de uma determinada marca, em formato JSON.
    final url = Uri.parse('$_baseUrl/GetModelsForMake/$makeName?format=json');
    try {
      // Faz a requisição GET à API.
      final response = await http.get(url);
      // Verifica se o código de status é 200 (OK).
      if (response.statusCode == 200) {
        // Converte a resposta do servidor de JSON para Map.
        final data = jsonDecode(response.body);
        // Extrai a lista de resultados do Map.
        final List results = data['Results'];
        // Converte cada item para a string contida em 'Model_Name'.
        final models =
            results.map((item) => item['Model_Name'].toString()).toList();
        // Ordena a lista de modelos por ordem alfabética.
        models.sort((a, b) => a.toString().compareTo(b.toString()));
        // Retorna a lista convertida para List<String>.
        return List<String>.from(models);
      } else {
        // Se o código de status não for 200, lança uma excepção com a mensagem de falha.
        throw Exception(
            'Falha ao obter modelos para a marca $makeName: ${response.statusCode}');
      }
    } catch (e) {
      // Em caso de erro (e.g. problemas de rede), lança uma excepção com a mensagem de erro.
      throw Exception('Erro ao obter modelos para a marca $makeName: $e');
    }
  }
}

// Trabalho realizado por:
// -> Miguel Magalhães;
// -> Nº:2021103166;
// -> Unidade Curricular de Computação Móvel;
// -> Licenciatura em Engenharia informática;
// -> ISPGAYA
